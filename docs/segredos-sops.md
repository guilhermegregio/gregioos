# Ativar o sops-nix no Mac de trabalho

Tira `MOBILE_PLATFORM_GITHUB_TOKEN` e companhia do `environment.variables` —
que hoje geram `/etc/zshenv`, legível por qualquer processo — e passa a
versioná-los cifrados no repo, decriptados na ativação para `/run/secrets`
com permissão `0400`.

> ⚠️ **A branch `sops` não avalia até o passo 3.** O código do wire já está
> commitado, mas ele aponta para `secrets/tokens.yaml`, que só existe depois
> que você o criar — e o flake só enxerga arquivos trackeados pelo git. Rode os
> passos em ordem; não tente `fr` antes do passo 4.

Tudo aqui roda **no Mac de trabalho** (`CV9NF4V0H6`), onde está a sua chave.

---

## Passo 1 — a chave age

O sops usa chaves age. Dá para derivar uma da sua chave SSH, evitando
gerenciar mais um par:

```bash
cd ~/gregioos
git fetch origin && git checkout sops

# a pública — vai para o .sops.yaml, é pública mesmo
nix shell "nixpkgs#ssh-to-age" -c ssh-to-age < ~/.ssh/id_ed25519.pub

# a privada, que o CLI do sops usa para editar. NUNCA vai para o repo.
mkdir -p ~/.config/sops/age
nix shell "nixpkgs#ssh-to-age" -c \
  ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

> Se você não tem `~/.ssh/id_ed25519`, gere com
> `ssh-keygen -t ed25519 -C "guilherme.gregio@stone"` antes.

## Passo 2 — o `.sops.yaml`

Declara **quem pode decriptar**. É público e vai para o repo.

Inclua desde já a chave do NixOS, não só a do Mac: sem ela você só consegue
editar os segredos estando no Mac de trabalho. A chave age do
`gregio-asus-tuf-f15` já está derivada abaixo (é pública — vem da
`id_ed25519.pub` daquela máquina):

```bash
cd ~/gregioos
WORK=$(nix shell "nixpkgs#ssh-to-age" -c ssh-to-age < ~/.ssh/id_ed25519.pub)
NIXOS=age12x8xeu48w8vkw7z3kvpwgwu32cy3vmjcpq30jyp058z7hhxyhvzs59r5g7

cat > .sops.yaml <<EOF
keys:
  - &work  $WORK
  - &nixos $NIXOS

creation_rules:
  - path_regex: secrets/.*\.yaml\$
    key_groups:
      - age:
          - *work
          - *nixos
EOF
cat .sops.yaml
```

Cada chave listada consegue decriptar de forma independente — não é um esquema
de "n de m".

Quando o `nxt-os-01` existir, a chave dele entra na lista e você roda
`sops updatekeys secrets/tokens.yaml`. **Só é obrigatório para máquinas que vão
consumir segredos**: uma máquina que só edita precisa estar na lista; uma que
decripta na ativação, se não estiver, falha o switch.

### Editar os segredos a partir do NixOS

Uma vez que a chave acima esteja no `.sops.yaml`, no NixOS basta ter a
privada onde o CLI procura:

```bash
mkdir -p ~/.config/sops/age
nix shell "nixpkgs#ssh-to-age" -c \
  ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

sops secrets/tokens.yaml    # edita de qualquer uma das máquinas
```

Isso é só para **editar**. Para o NixOS *consumir* segredos na ativação seria
preciso `inputs.sops-nix.nixosModules.sops` no `mkNixos` e declarar
`sops.secrets` — hoje não há segredo nenhum do lado Linux, então não está
feito.

## Passo 3 — os segredos

Abre o `$EDITOR`. Escreva YAML puro, com **estes três nomes** (o config os
referencia):

```bash
mkdir -p secrets
nix shell "nixpkgs#sops" -c sops secrets/tokens.yaml
```

```yaml
mobile_platform_github_token: ghp_o-valor-real
custom_github_pat_package: ghp_o-outro-valor
temp_tap_sdk_ios_token: o-terceiro-valor
```

Ao salvar, o sops reescreve o arquivo com os **valores** cifrados e as
**chaves** em claro — por isso o diff no git continua legível.

```bash
head -4 secrets/tokens.yaml   # deve mostrar ENC[AES256_GCM,...]
git add -A                    # obrigatório: o flake não vê arquivo untracked
```

## Passo 4 — aplicar

```bash
fr
```

## Passo 5 — verificar

Em um **terminal novo**:

```bash
ls -l /run/secrets/                    # os 3 segredos, 0400, dono você
ls -l /run/secrets/rendered/dev-env    # o arquivo que o zsh dá source
echo $MOBILE_PLATFORM_GITHUB_TOKEN     # o valor real

# o teste que importa: o valor NÃO pode estar no store
rg -l "$MOBILE_PLATFORM_GITHUB_TOKEN" /nix/store 2>/dev/null || echo "ok: fora do store"
```

O último comando é o ponto do exercício. Se ele achar algo, o valor vazou para
o store em tempo de avaliação — o que o `sops.placeholder` existe para evitar.

## Passo 6 — commitar e mesclar

```bash
git commit -am "feat(darwin): tokens da Stone via sops-nix"
git push -u origin sops
```

O merge para a `main` pode ser feito daqui ou pelo NixOS.

---

## Trocar as chaves depois (ou: "cifrei com a chave errada")

`sops updatekeys` **só funciona se você conseguir decriptar o arquivo** — ele
decripta e recifra para os novos recipients. Se a chave que cifrou não está
mais à mão, ele falha com:

```
Failed to get the data key required to decrypt the SOPS file.
  ageXXXX: FAILED
    - identity did not match any of the recipients
```

### Caso A — você ainda tem a chave que cifrou

```bash
# corrija o .sops.yaml primeiro, depois:
nix shell "nixpkgs#sops" -c sops updatekeys secrets/tokens.yaml
```

### Caso B — não tem (ou os valores eram de teste): recrie

Cifrar não exige a privada, só as públicas do `.sops.yaml`. Então apagar e
refazer é seguro e mais rápido:

```bash
cd ~/gregioos

# 1. as duas chaves reais no .sops.yaml
WORK=$(nix shell "nixpkgs#ssh-to-age" -c ssh-to-age < ~/.ssh/id_ed25519.pub)
NIXOS=age12x8xeu48w8vkw7z3kvpwgwu32cy3vmjcpq30jyp058z7hhxyhvzs59r5g7
echo "work=$WORK"

cat > .sops.yaml <<EOF
keys:
  - &work  $WORK
  - &nixos $NIXOS

creation_rules:
  - path_regex: secrets/.*\.yaml\$
    key_groups:
      - age:
          - *work
          - *nixos
EOF

# 2. a privada onde o CLI a encontra — sem isto você cifra mas não reabre
mkdir -p ~/.config/sops/age
nix shell "nixpkgs#ssh-to-age" -c \
  ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# 3. joga fora o antigo e cria de novo
rm -f secrets/tokens.yaml
nix shell "nixpkgs#sops" -c sops secrets/tokens.yaml

# 4. confirme que ficou cifrado para as DUAS chaves
rg -o "age1[a-z0-9]{20,}" secrets/tokens.yaml | sort -u   # tem que listar 2

git add -A
```

> **Confira sempre o par.** O `.sops.yaml` diz para quem *novos* arquivos serão
> cifrados; os recipients de um arquivo **já existente** ficam dentro dele. Os
> dois divergem em silêncio — o comando do passo 4 é o que revela isso.

---

## Se algo der errado

| sintoma | causa provável |
|---|---|
| `file not found` no eval | o `secrets/tokens.yaml` não foi `git add`-ado |
| ativação falha ao decriptar | a chave em `age.sshKeyPaths` não é a que cifrou; confira `~/.ssh/id_ed25519` |
| `/run` não existe | o nix-darwin cria via `/etc/synthetic.conf`; reinicie e rode o switch de novo |
| variável vazia no shell | o `initContent` só entra em sessão nova; abra outro terminal |
| `identity did not match any of the recipients` | o arquivo foi cifrado para outra chave — ver "Trocar as chaves depois" |
| sops procura em `~/.ssh/id_rsa` e não acha | falta o `~/.config/sops/age/keys.txt`; passo 1 |

**Rotação de token:** `sops secrets/tokens.yaml`, edite, `git commit`, `fr`.
Nenhum passo manual na máquina.

**Backup da chave privada:** ela não está no repo, de propósito. Se você perder
a `~/.ssh/id_ed25519` sem outra chave autorizada no `.sops.yaml`, os valores
cifrados viram lixo e terão de ser recriados.
