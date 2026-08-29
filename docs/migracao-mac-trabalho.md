# Roteiro — migrar o Mac de trabalho para o gregioos

Fase 4 do plano multi-host: tira o `CV9NF4V0H6` do `~/code/dotfiles@nixpkgs` e o
passa para este repo, branch `multi-host`.

**Nada aqui é irreversível.** O nix-darwin guarda as gerações antigas; a seção
[Rollback](#rollback) volta tudo em um comando.

## O que já foi verificado por eval

Não precisa conferir na máquina:

| | resultado |
|---|---|
| casks e brews | **paridade total** com o dotfiles — o `cleanup = "zap"` não remove nada |
| pacotes CLI | 54, nenhum do dotfiles faltando (`eza`, `fd`, `ripgrep`, `herdr`, `tig`, `yazi`, `colima`, …) |
| CA e tokens | presentes só neste host; o Mac pessoal não os herda |
| `fr`/`fu` | `nh darwin switch --hostname CV9NF4V0H6` |

O build do passo 3 deve produzir a derivação
`nmm6cbaxigywf54k627l1r7jslx76p0a-darwin-system-26.05.c3e90c8.drv`. Hash
diferente significa que o repo está em outro commit — volte ao passo 2.

---

## Passo 0 — no NixOS, antes de ir para o Mac

A branch ainda é local. Sem isto, o Mac não tem o que clonar:

```bash
cd ~/code/worktrees/gregioos-multi-host
git push -u origin multi-host
git log --oneline -1 origin/multi-host   # 991e5c2
```

---

## Passo 1 — anotar o estado atual

No Mac, **antes de mexer em nada**. É o que permite o diff do passo 4 e o rollback.

```bash
# guarda o system atual
readlink -f /run/current-system | tee ~/system-antes-da-migracao.txt

# o que está instalado hoje, para comparar depois
ls /Applications | sort > ~/apps-antes.txt
brew list > ~/brew-antes.txt 2>/dev/null
```

---

## Passo 2 — clonar o gregioos

O caminho **precisa** ser `~/gregioos`: é o que está em
`modules/home/darwin/nh.nix` (`NH_FLAKE`) e no symlink do nvim. Não é
`~/.gregioos` — o runbook antigo dizia isso e mudou.

```bash
git clone https://github.com/guilhermegregio/gregioos.git ~/gregioos
cd ~/gregioos
git checkout multi-host
git log --oneline -1        # 991e5c2 fix(darwin): CLIs do dia a dia...
```

> O `~/code/dotfiles` **fica onde está** — é o caminho de volta. Só é aposentado
> na fase 7, depois de alguns dias de uso.

---

## Passo 3 — build, sem tocar no sistema

O passo demorado. Só baixa e compila; não altera nada da máquina.

```bash
cd ~/gregioos
nix build .#darwinConfigurations.CV9NF4V0H6.system
```

Se reclamar de certificado, exporte a CA e repita:

```bash
export NIX_SSL_CERT_FILE=/etc/ssl/certs/combined-ca.pem
```

**Espere um download grande.** O lock do gregioos usa outro nixpkgs
(`nixos-unstable`, 26.05) do que o dotfiles usava (master), então boa parte do
que está no store não serve. No setup anterior foram ~7 GiB.

Se der erro, veja [Problemas conhecidos](#problemas-conhecidos).

---

## Passo 4 — revisar o que vai mudar

Aqui você decide se segue.

```bash
nix run nixpkgs#nvd -- diff "$(cat ~/system-antes-da-migracao.txt)" ./result
```

**Esperado ver:** muita mudança de versão (é outro nixpkgs), mais as entradas de
`zsh-prezto`, `sesh`, `carapace` e `delta`, que vêm do gregioos e o dotfiles não
tinha.

**Não deveria aparecer:** desaparecimento de `herdr`, `eza`, `fd`, `ripgrep`,
`neovim` ou `colima`.

> **Ponto de parada.** Se algo importante sumir, pare aqui — até este momento
> nada foi alterado na máquina.

---

## Passo 5 — o switch

O `darwin-rebuild` já existe nesta máquina, então não precisa do
`./result/sw/bin/`. O `-E` preserva a variável da CA para o sudo; sem ele o
switch pode falhar no meio, quando o daemon for buscar algo.

```bash
cd ~/gregioos
sudo -E darwin-rebuild switch --flake .#CV9NF4V0H6
```

### Se reclamar de arquivos em `/etc`

O nix-darwin não sobrescreve o que não criou:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
```

⚠️ Esse arquivo contém o `ssl-cert-file` do Netskope. Mover é seguro **porque** o
host declara a opção e o switch a recria — mas confirme antes:

```bash
rg ssl-cert-file ~/gregioos/hosts/CV9NF4V0H6/default.nix
```

Depois rode o switch de novo.

### Se travar em `Homebrew bundle...`

Provavelmente é download de cask grande (`android-studio`, `docker-desktop`,
`intellij-idea-ce`). Diagnostique em outro terminal:

```bash
ps aux | rg "brew|curl|installer" | rg -v rg
```

Interromper o `brew bundle` é seguro — o sistema Nix já foi ativado a essa altura.

---

## Passo 6 — confiar no tap do aerospace

Taps de terceiros exigem confirmação manual, não é declarativo. Caminho absoluto
de propósito: o `brew` só entra no PATH depois que a ativação do home-manager
completa.

```bash
/opt/homebrew/bin/brew trust nikitabobko/tap
```

---

## Passo 7 — smoke test

**Abra um terminal novo** — o PATH e o zsh só mudam em sessão nova.

```bash
# o comando do dia a dia, agora igual ao do NixOS
alias fr

# CA corporativa preservada
echo $NIX_SSL_CERT_FILE
nix flake metadata github:nixos/nixpkgs

# tokens da Stone
env | rg "MOBILE_PLATFORM|TEMP_TAP|CUSTOM_GITHUB"

# CLIs que a migração poderia ter levado embora
for c in eza fd rg herdr tig yazi colima gh nvim zellij; do
  command -v $c >/dev/null && echo "ok    $c" || echo "FALTA $c"
done

# o erro do runbook antigo — resolvido por nix.nixPath
nix-shell -p hello --run hello
```

No visual: aerospace organizando as janelas, ghostty com a JetBrainsMono Nerd
Font, prompt do starship, e Touch ID dentro do zellij (abra um e rode `sudo -v`).

> O `fr` usa `NH_FLAKE`, então funciona de qualquer diretório. Rodá-lo agora
> reaplica a mesma config — é a melhor confirmação de que o ciclo fechou.

---

## Passo 8 — usar por alguns dias

Antes do merge (fase 5), rode a máquina normalmente por 2–3 dias. O que observar:

- Algum comando do dia a dia que sumiu ou mudou de comportamento.
- Config do zsh, git e zellij: agora vem do gregioos, não do dotfiles — pode
  haver diferença de aliases ou de tema.
- O `fr` como rebuild do dia a dia, no lugar do `darwin-rebuild` manual.

Anote o que incomodar; vira a task 3.2 do plano (união fina de conteúdo com o
dotfiles), que ficou deliberadamente para depois desta fase.

---

## Rollback

O `~/code/dotfiles` continua intacto, então voltar é sempre possível:

```bash
sudo "$(cat ~/system-antes-da-migracao.txt)/sw/bin/darwin-rebuild" switch \
  --flake ~/code/dotfiles#CV9NF4V0H6
```

Ou liste as gerações e escolha:

```bash
darwin-rebuild --list-generations
sudo darwin-rebuild switch --switch-generation <n>
```

---

## Problemas conhecidos

Todos já apareceram no setup de 28/08/2026. Os dois últimos estão aqui só porque
o runbook antigo os registra — não devem ocorrer.

| erro | causa e solução |
|---|---|
| `SSL peer certificate ... self-signed` | Netskope. `export NIX_SSL_CERT_FILE=/etc/ssl/certs/combined-ca.pem` |
| `curl: (22) ... 403` em crates.io | Não é o Netskope: é o Fastly recusando o IP do proxy. O nixpkgs do lock já usa `static.crates.io` |
| `Build user group has mismatching GID` | `dscl . -read /Groups/nixbld PrimaryGroupID` — se não for 350, ajuste `ids.gids.nixbld` em `hosts/CV9NF4V0H6/default.nix` |
| `Refusing to load formula ... untrusted tap` | passo 6, `brew trust` |
| `--toc-depth has been removed` | descasamento nix-darwin × nixpkgs. Não deve ocorrer: o input está pinado em `nix-darwin-26.05` |
| `nodePackages has been removed` | código antigo com nixpkgs novo. Não deve ocorrer: este repo não usa `nodePackages` |

---

## Depois desta fase

1. **Fase 4B** — sops-nix: tirar os tokens do `environment.variables` (hoje ainda
   são placeholders `<REPLACE>`, igual ao dotfiles). Exige a chave SSH desta
   máquina, por isso vem depois.
2. **Fase 5** — merge para a `main` e, só então, o `fr` no NixOS: o symlink do
   nvim aponta para um caminho que só existe lá.
3. **Fase 6** — bootstrap do `nxt-os-01`, o Mac pessoal.
