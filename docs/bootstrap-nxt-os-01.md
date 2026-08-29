# Bootstrap do `nxt-os-01` — MacBook pessoal

Máquina zerada até `fr` funcionando. **A ordem importa**: cada fase depende da
anterior.

Este roteiro já vem com as correções que custaram tempo na migração do Mac de
trabalho — quoting do zsh, `sudo`, `backupFileExtension`, CA por runtime. Se
algo divergir do que está aqui, é sinal de máquina diferente, não de erro no
texto.

## Antes de tudo

- [ ] Decidir o hostname: **`nxt-os-01`** (é o attr no `flake.nix`)
- [ ] Saber o username — `whoami` depois do primeiro login. O flake assume
      **`gregio`**; se for outro, ajuste em `flake.nix` (`darwinConfigurations.nxt-os-01`)
- [ ] Ter acesso à chave SSH do GitHub, ou estar pronto para gerar uma

---

## 1. Ferramentas base do macOS

```bash
xcode-select --install
softwareupdate --install-rosetta --agree-to-license
```

O primeiro traz o `git`, sem o qual não se clona nada. O Rosetta é necessário
para casks x86 — instale mesmo achando que não vai precisar.

## 2. Instalar o Nix

Instalador oficial multi-user, ou o da Determinate Systems **escolhendo Nix
upstream** quando ele perguntar. Não escolha o "Determinate Nix": ele gerencia o
próprio daemon e conflita com o nix-darwin.

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

**Abra um terminal novo** — o PATH só entra em sessão nova.

```bash
nix run nixpkgs#cowsay -- ok
```

> `nix-shell -p` falhando com "file 'nixpkgs' was not found" é **esperado** e não
> é erro de instalação: os instaladores modernos não inscrevem channels. O config
> resolve depois, via `nix.nixPath`.

## 3. Hostname

Use exatamente o nome do attr — assim `darwin-rebuild --flake .` resolve sozinho:

```bash
sudo scutil --set ComputerName   nxt-os-01
sudo scutil --set HostName       nxt-os-01
sudo scutil --set LocalHostName  nxt-os-01
```

## 4. Chave SSH e clone

```bash
ssh-keygen -t ed25519 -C "guilherme@pessoal"   # SEM passphrase, ver nota
cat ~/.ssh/id_ed25519.pub                       # adicionar no GitHub

git clone https://github.com/guilhermegregio/gregioos.git ~/gregioos
cd ~/gregioos
```

> ⚠️ **Sem passphrase.** O sops não suporta chave SSH protegida por senha, e é
> essa chave que vai decriptar os segredos. Se preferir uma chave com senha para
> o git, gere **outra** sem senha só para o sops.

> O caminho tem de ser `~/gregioos`: é o que está no `NH_FLAKE` e no symlink do
> nvim.

## 5. Conferir o GID do nixbld

```bash
dscl . -read /Groups/nixbld PrimaryGroupID
```

Se der 350, `hosts/nxt-os-01/default.nix` já está certo. Instalações antigas
usavam 30000 — nesse caso ajuste `ids.gids.nixbld` e commite.

## 6. Containers — já resolvido

Nada a decidir aqui, mas vale saber o desenho:

| | trabalho | pessoal |
|---|---|---|
| runtime | Docker Desktop (cask) | **colima** (nix) |
| cliente `docker` | vem do Desktop, em `/usr/local/bin` | vem do nix |

O `colima` sobe a VM, mas **não** fornece o binário com que se fala com ela —
no macOS quem costuma instalar o cliente é o Docker Desktop. Como aqui ele não
existe, `docker` e `docker-compose` estão declarados em
`hosts/nxt-os-01/default.nix`.

Depois do switch, para subir a VM na primeira vez:

```bash
colima start
docker context ls    # deve mostrar `colima` como ativo
docker run --rm hello-world
```

## 7. Primeiro build

Sem `sudo`, sem ativar nada — pega erro de avaliação e de download antes de
tocar no sistema.

```bash
nix build ".#darwinConfigurations.nxt-os-01.system"
```

> ⚠️ **As aspas não são decoração.** O prezto liga `EXTENDED_GLOB` no zsh, onde
> `#` é operador de repetição, e `nix build .#foo` morre com
> `zsh: no matches found` antes de o nix rodar.

Esta é a fase demorada — foram ~7 GiB no Mac de trabalho.

## 8. Primeiro switch

O `darwin-rebuild` ainda não existe, então use o resultado do build:

```bash
sudo env PATH=$PATH ./result/sw/bin/darwin-rebuild switch --flake ".#nxt-os-01"
```

> **`sudo -E` não funciona no macOS.** O sudoers traz `env_reset` e o `-E` exige
> `SETENV`; sem isso o ambiente é descartado e o `darwin-rebuild` nem é
> encontrado. Passe o PATH explicitamente.

**Espere reclamação de arquivos em `/etc`** — o nix-darwin não sobrescreve o que
não criou:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo mv /etc/zshrc        /etc/zshrc.before-nix-darwin
sudo mv /etc/bashrc       /etc/bashrc.before-nix-darwin
```

E rode o switch de novo.

> O `would be clobbered` do home-manager **não** deve aparecer: o
> `backupFileExtension` já está declarado, e ele renomeia para `.backup` sozinho.

## 9. Homebrew

O módulo `homebrew.*` gerencia o bundle, **não instala** o brew. Se ele não
existir, instale antes do switch. Taps de terceiros exigem confirmação manual:

```bash
/opt/homebrew/bin/brew trust nikitabobko/tap
```

Caminho absoluto de propósito: o `brew` só entra no PATH depois que a ativação
do home-manager completa.

## 10. Segredos (opcional)

Só se esta máquina for **consumir** segredos. Para apenas *editar* os do repo,
basta a chave estar no `.sops.yaml`.

```bash
ssh-to-age < ~/.ssh/id_ed25519.pub    # a age pública desta máquina
```

Cole no `.sops.yaml`, no lugar do `age1...` do slot `&nxt`, e **descomente as
duas linhas** — a de `keys` e a de `key_groups`. Esquecer a segunda é o erro
fácil: a chave fica declarada e ignorada.

Depois, **de uma máquina que já decripta** (o Mac de trabalho ou o NixOS):

```bash
sops updatekeys secrets/tokens.yaml
git commit -am "chore(sops): autoriza o nxt-os-01"
```

Detalhes em [`segredos-sops.md`](./segredos-sops.md); diagnóstico em
`./dev/sops-doctor.sh`.

## 11. Verificação

Abra um **terminal novo**:

```bash
darwin-rebuild --version
alias fr                      # nh darwin switch --hostname nxt-os-01
fr                            # deve dizer "No version or size changes"

for c in eza fd rg herdr tig yazi gh nvim zellij sops colima docker; do
  command -v $c >/dev/null && echo "ok    $c" || echo "FALTA $c"
done

nix-shell -p hello --run hello   # nix.nixPath declarado
```

**O teste que importa aqui:** nada da Stone pode ter vindo junto.

```bash
env | rg -i "MOBILE_PLATFORM|TEMP_TAP|CUSTOM_GITHUB"   # tem que ser vazio
echo $NIX_SSL_CERT_FILE   # ca-certificates.crt, NÃO combined-ca.pem
```

> `NIX_SSL_CERT_FILE` **existir** é normal — é o default do nix-darwin. O que
> não pode aparecer é o `combined-ca.pem` do Netskope.

No visual: aerospace organizando as janelas, ghostty com JetBrainsMono Nerd
Font, prompt do starship.

---

## Daqui em diante

```bash
fr    # rebuild
fu    # rebuild + update do flake
```

Os mesmos comandos das outras duas máquinas.

> Ao rodar `fu`, `nixpkgs` e `darwin` sobem **juntos** — o nix-darwin aborta o
> eval se as releases divergirem. É o que o `nix flake update` já faz.

## Passos que nunca serão declarativos

1. Xcode CLT e Nix (fases 1 e 2)
2. Chave SSH no GitHub (fase 4)
3. `brew trust` de cada tap de terceiro (fase 9)
4. Autorizar a chave nos segredos (fase 10)
5. Login em apps de GUI (1Password, Chrome, Slack)

## Problemas conhecidos

| erro | causa e solução |
|---|---|
| `zsh: no matches found: .#...` | `EXTENDED_GLOB` do prezto. Quote: `".#attr"` |
| `darwin-rebuild: command not found` sob sudo | use `sudo env PATH=$PATH`, não `sudo -E` |
| `Build user group has mismatching GID` | fase 5; ajuste `ids.gids.nixbld` |
| `Refusing to load formula ... untrusted tap` | fase 9, `brew trust` |
| travou em `Homebrew bundle...` | cask grande baixando. `ps aux \| rg "brew\|curl"`. Interromper é seguro — o sistema Nix já foi ativado |
| `nix-darwin X with Nixpkgs Y` | rode `nix flake update` (sobe os dois juntos), nunca só um |
