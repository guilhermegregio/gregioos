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

Declara quem pode decriptar. É público e vai para o repo. O comando abaixo
monta o arquivo já com a sua chave:

```bash
cd ~/gregioos
PUB=$(nix shell "nixpkgs#ssh-to-age" -c ssh-to-age < ~/.ssh/id_ed25519.pub)
cat > .sops.yaml <<EOF
keys:
  - &work $PUB

creation_rules:
  - path_regex: secrets/.*\.yaml\$
    key_groups:
      - age:
          - *work
EOF
cat .sops.yaml
```

Quando o `nxt-os-01` existir, a chave dele entra nessa lista e você roda
`sops updatekeys secrets/tokens.yaml` — sem isso, a máquina nova não decripta
e o switch falha na ativação.

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

## Se algo der errado

| sintoma | causa provável |
|---|---|
| `file not found` no eval | o `secrets/tokens.yaml` não foi `git add`-ado |
| ativação falha ao decriptar | a chave em `age.sshKeyPaths` não é a que cifrou; confira `~/.ssh/id_ed25519` |
| `/run` não existe | o nix-darwin cria via `/etc/synthetic.conf`; reinicie e rode o switch de novo |
| variável vazia no shell | o `initContent` só entra em sessão nova; abra outro terminal |

**Rotação de token:** `sops secrets/tokens.yaml`, edite, `git commit`, `fr`.
Nenhum passo manual na máquina.

**Backup da chave privada:** ela não está no repo, de propósito. Se você perder
a `~/.ssh/id_ed25519` sem outra chave autorizada no `.sops.yaml`, os valores
cifrados viram lixo e terão de ser recriados.
