# Nova máquina macOS

Do zero até `fr` funcionando. **A ordem importa** — cada passo depende do
anterior.

Já rodou duas vezes: na migração do MacBook de trabalho e no bootstrap do
pessoal. As armadilhas anotadas aqui apareceram de verdade.

## Antes

- **Hostname** — vai ser o attr no `flake.nix`. Escolha antes de começar.
- **Username** — `whoami` depois do primeiro login. Precisa bater com o que o
  `flake.nix` declara para o host.
- **Chave SSH** — gere **sem passphrase** se a máquina for decriptar segredos: o
  sops não suporta chave protegida por senha.

---

## 1. Ferramentas base

```bash
xcode-select --install
softwareupdate --install-rosetta --agree-to-license
```

O primeiro traz o `git`. O Rosetta é necessário para casks x86 — instale mesmo
achando que não vai precisar.

## 2. Nix

Instalador oficial multi-user, ou o da Determinate Systems **escolhendo Nix
upstream**. Não escolha o "Determinate Nix": ele gerencia o próprio daemon e
conflita com o nix-darwin.

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

**Abra um terminal novo** — o PATH só entra em sessão nova. Depois:

```bash
nix run nixpkgs#cowsay -- ok
```

> `nix-shell -p` falhando com `file 'nixpkgs' was not found` é **esperado**: os
> instaladores modernos não inscrevem channels. O config resolve depois, com
> `nix.nixPath`.

## 3. Hostname

Use o mesmo nome do attr — assim `--flake .` resolve sozinho:

```bash
sudo scutil --set ComputerName   <host>
sudo scutil --set HostName       <host>
sudo scutil --set LocalHostName  <host>
```

## 4. Clonar

O caminho **precisa** ser `~/gregioos`: é o que está no `NH_FLAKE` e no symlink
do Neovim.

```bash
ssh-keygen -t ed25519 -C "seu@email"    # sem passphrase (ver "Antes")
cat ~/.ssh/id_ed25519.pub                # adicionar no GitHub

git clone https://github.com/guilhermegregio/gregioos.git ~/gregioos
cd ~/gregioos
```

## 5. Conferir o host no flake

```bash
whoami                                    # bate com o username do host?
dscl . -read /Groups/nixbld PrimaryGroupID
```

O GID costuma ser 350; instalações antigas de Nix usavam 30000. Se divergir,
ajuste `ids.gids.nixbld` em `hosts/<host>/default.nix`. Se o username divergir,
corrija no `flake.nix` — e **commite antes do build**: o flake só enxerga o que
está no git.

## 6. Build

Sem `sudo`, sem ativar nada — pega erro de avaliação e download antes de tocar
no sistema.

```bash
nix build ".#darwinConfigurations.<host>.system"
```

> ⚠️ **As aspas não são decoração.** O prezto liga `EXTENDED_GLOB` no zsh, onde
> `#` é operador de repetição, e `nix build .#foo` morre com
> `zsh: no matches found` antes de o nix rodar.

É o passo demorado — foram ~7 GiB na primeira máquina.

## 7. Switch

O `darwin-rebuild` ainda não existe, então use o que o build produziu:

```bash
sudo env PATH=$PATH ./result/sw/bin/darwin-rebuild switch --flake ".#<host>"
```

> **`sudo -E` não funciona aqui.** O sudoers do macOS traz `env_reset`, e o `-E`
> exige a permissão `SETENV`; sem ela o ambiente é descartado e o
> `darwin-rebuild` nem é encontrado. Passe o PATH explicitamente.

**Espere reclamação de arquivos em `/etc`** — o nix-darwin não sobrescreve o que
não criou:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo mv /etc/zshrc        /etc/zshrc.before-nix-darwin
sudo mv /etc/bashrc       /etc/bashrc.before-nix-darwin
```

E rode o switch de novo.

## 8. Homebrew

O módulo `homebrew.*` gerencia o bundle, **não instala** o brew. Se não existir,
instale antes do switch.

Taps de terceiros exigem confirmação manual — não é declarativo:

```bash
/opt/homebrew/bin/brew trust nikitabobko/tap
```

Caminho absoluto de propósito: o `brew` só entra no PATH depois que a ativação
do home-manager completa, e ela não completa enquanto o bundle falhar.

## 9. Segredos

Só se a máquina for **consumir** segredos. Ver
[segredos-sops.md](./segredos-sops.md).

## 10. Verificação

Abra um **terminal novo**:

```bash
darwin-rebuild --version
alias fr                    # nh darwin switch --hostname <host>
fr                          # deve dizer "No version or size changes"

for c in eza fd rg herdr tig yazi gh nvim zellij sops; do
  command -v $c >/dev/null && echo "ok    $c" || echo "FALTA $c"
done

nix-shell -p hello --run hello   # nix.nixPath declarado
```

No visual: AeroSpace organizando as janelas, ghostty com JetBrainsMono Nerd
Font, prompt do starship, e Touch ID funcionando dentro do zellij (`sudo -v`).

---

## Containers

O desenho difere por máquina:

| | Docker Desktop | colima |
| --- | --- | --- |
| runtime | cask | pacote nix |
| cliente `docker` | vem junto | **precisa vir do nix** |

O colima sobe a VM mas **não** fornece o binário com que se fala com ela — no
macOS quem costuma instalar o cliente é o Docker Desktop. Numa máquina sem
Desktop, declare `docker` e `docker-compose` em `hosts/<host>/default.nix`.

```bash
colima start          # uma vez por boot; não sobe sozinho
docker context ls
docker run --rm hello-world
```

Automatizar com `launchd.user.agents` é possível (`--foreground` + `KeepAlive`),
mas a VM consome RAM e bateria permanentemente. Em laptop, sob demanda costuma
ser melhor.

## Coisas que nunca serão declarativas

1. Xcode CLT e Nix (passos 1 e 2)
2. Chave SSH no GitHub (passo 4)
3. `brew trust` de cada tap de terceiro (passo 8)
4. Autorizar a chave nos segredos
5. Login em apps de GUI

## Problemas conhecidos

| erro | causa e solução |
| --- | --- |
| `zsh: no matches found: .#...` | `EXTENDED_GLOB` do prezto. Quote: `".#attr"` |
| `darwin-rebuild: command not found` sob sudo | use `sudo env PATH=$PATH`, não `sudo -E` |
| `Build user group has mismatching GID` | passo 5; ajuste `ids.gids.nixbld` |
| `Refusing to load formula ... untrusted tap` | passo 8, `brew trust` |
| `... would be clobbered` | arquivo que o home-manager não criou. O `backupFileExtension` já está declarado e renomeia para `.backup`; se aparecer, o config saiu do lugar |
| travado em `Homebrew bundle...` | cask grande baixando sem barra de progresso. `ps aux \| rg "brew\|curl"`. Interromper é seguro: o sistema Nix já foi ativado |
| `nix-darwin X with Nixpkgs Y` | as releases têm de casar. Rode `nix flake update` (sobe os dois juntos), nunca só um |
| aliases antigos após um switch | sessões abertas antes do switch mantêm os aliases velhos. Abra um terminal novo |

### Atrás de proxy corporativo (TLS inspection)

Monte o bundle combinado e aponte a CA — **cada runtime lê a sua variável**:

```bash
sudo mkdir -p /etc/ssl/certs
cat /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    "/Library/Application Support/<Agente>/data/cacert.pem" \
  | sudo tee /etc/ssl/certs/combined-ca.pem > /dev/null

export NIX_SSL_CERT_FILE=/etc/ssl/certs/combined-ca.pem
```

No config, declare no host (nunca no comum): `NIX_SSL_CERT_FILE`,
`SSL_CERT_FILE`, `CURL_CA_BUNDLE`, `REQUESTS_CA_BUNDLE`, **`GIT_SSL_CAINFO`**
(não `CAPATH`, que espera diretório) e **`NODE_EXTRA_CA_CERTS`** (o Node não lê
nenhuma das outras, e é ele que roda os LSPs do editor).
