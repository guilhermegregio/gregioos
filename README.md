# GregioOS

Configuração de três máquinas num flake só: dois MacBooks e um notebook Linux.
**NixOS** e **nix-darwin**, com **home-manager** compartilhado entre os dois
mundos — o ambiente de terminal é o mesmo em qualquer uma delas.

| host (attr do flake) | máquina | sistema |
| --- | --- | --- |
| `gregio-asus-tuf-f15` | ASUS TUF F15 | NixOS · x86_64 |
| `gregio-note` | notebook secundário | NixOS · x86_64 |
| `CV9NF4V0H6` | MacBook de trabalho | macOS · aarch64 |
| `nxt-os-01` | MacBook pessoal | macOS · aarch64 |

O attr **é o hostname real** da máquina. No macOS isso faz `darwin-rebuild
--flake .` resolver o host sozinho, sem `#nome`.

## Um comando só, nas três

```bash
fr    # rebuild
fu    # rebuild + atualiza os inputs do flake
```

Por baixo muda o backend — `nh os switch` no Linux, `nh darwin switch` no
macOS — mas o que se digita é sempre o mesmo. Era um requisito de projeto, não
um detalhe.

```bash
nix flake check --all-systems   # valida os quatro hosts
ncg                             # garbage collect + reboot (só NixOS)
```

---

## O que roda

### Nas três máquinas

Tudo abaixo vem de `modules/home/common` e é idêntico em Linux e macOS.

- **Shell** — zsh com [prezto](https://github.com/sorin-ionescu/prezto),
  [starship](https://starship.rs), fzf-tab, zoxide, direnv, carapace
- **Multiplexers** — [zellij](https://zellij.dev) e tmux com
  [sesh](https://github.com/joshmedeski/sesh); layouts prontos em
  `modules/home/common/zellij.nix`
- **Terminais** — [ghostty](https://ghostty.org) e wezterm
- **Editores** — Neovim (LazyVim, config em `modules/home/common/nvim/`) e
  [helix](https://helix-editor.com)
- **Git** — git com [delta](https://github.com/dandavison/delta), lazygit, tig,
  `gh` e `gh-dash`
- **CLI** — eza, fd, ripgrep, bat, jq, yq, httpie, yazi, btop, fastfetch
- **Segredos** — sops + ssh-to-age (ver [docs/segredos-sops.md](docs/segredos-sops.md))
- **[herdr](https://herdr.dev)** — multiplexer para agentes de IA

### Só no Linux

`modules/home/linux` e `modules/core`:

- **GNOME** com [Stylix](https://github.com/danth/stylix) (catppuccin-mocha),
  tema aplicado a GTK, Qt, terminais e editores de uma vez
- **Teclado** `us` variante `intl` com CapsLock como AltGr (`lv3:caps_switch`)
- kitty, zed, OBS Studio com plugins
- zen-browser, brave, chromium, obsidian, VS Code
- docker e libvirtd; drivers NVIDIA em `modules/drivers`

### Só no macOS

`modules/darwin` e `modules/home/darwin`:

- **[AeroSpace](https://github.com/nikitabobko/AeroSpace)** como window manager
  em tiling, com [JankyBorders](https://github.com/FelixKratz/JankyBorders)
  marcando a janela ativa
- **[Raycast](https://raycast.com)** como launcher
- **Touch ID no `sudo`**, inclusive dentro do zellij/tmux — o
  `pam_reattach` é o que faz funcionar no multiplexer
- Defaults do sistema declarados: dock, finder, NSGlobalDomain, repeat rate
- Apps via Homebrew cask: arc, zen, chrome, zed, dbeaver, obs, sf-symbols
- **Containers**: Docker Desktop no trabalho, [colima](https://github.com/abiosoft/colima)
  no pessoal — ver [a nota sobre o cliente `docker`](docs/nova-maquina-macos.md#containers)

---

## Estrutura

```
flake.nix                 # mkNixos e mkDarwin; um attr por host
hosts/<host>/             # o que é só daquela máquina
modules/
  core/                   # sistema NixOS
  drivers/                # GPU: nvidia, amdgpu, intel
  darwin/                 # sistema macOS: defaults, homebrew, touchid
  home/
    common/               # home-manager das TRÊS máquinas
    linux/                # dconf, stylix, kitty, zed, obs
    darwin/               # aerospace, nh, CLIs do mac
  scripts/                # derivations de scripts próprios
profiles/nvidia-laptop/   # hardware + drivers + core (NixOS)
secrets/                  # cifrado com sops; seguro no repo
dev/                      # ferramentas de manutenção do próprio repo
docs/                     # guias
```

### A regra: comum por padrão, específico por exceção

`modules/home/common` vale para as três máquinas. Uma coisa só sai de lá quando
**não pode** ficar:

| motivo | exemplo | onde vai |
| --- | --- | --- |
| a opção não existe na outra plataforma | `stylix.*` no macOS | `home/linux/stylix.nix` |
| o pacote não builda lá | ghostty em darwin | `package = null` no próprio módulo comum |
| o binário tem outro nome | `zeditor` no Linux, `zed` no cask | `optionalAttrs` dentro do módulo |
| é de uma máquina só | CA corporativa, tokens | `hosts/<host>/default.nix` |

`hosts/<host>/` **só acrescenta**. Se você copiar um módulo comum para dentro de
um host, o desenho saiu do lugar.

O dispatch de plataforma usa `hostPlatform`, vindo de `specialArgs` —
**nunca** `pkgs.stdenv` dentro de `imports`, que dá recursão infinita.

---

## Guias

- [Nova máquina macOS](docs/nova-maquina-macos.md) — do zero ao `fr`
- [Nova máquina NixOS](docs/nova-maquina-nixos.md)
- [Segredos com sops](docs/segredos-sops.md) — como editar e autorizar máquinas

## Se você quiser usar isto

O repo é público e pode ser clonado à vontade, mas ele descreve *estas*
máquinas. Para adaptar:

1. Troque os hosts em `flake.nix` pelos seus — o attr tem de ser o hostname real
2. Refaça `hosts/<host>/variables.nix` (nome, e-mail, terminal, browser)
3. No NixOS, gere o seu `hardware.nix` com `nixos-generate-config`
4. Apague `secrets/` e `.sops.yaml` — são cifrados para chaves que você não tem
5. Reveja `modules/darwin/homebrew.nix`, que é gosto pessoal

O que provavelmente vale a pena copiar independente do resto: o helper
`mkDarwin`/`mkNixos` do `flake.nix`, a separação `common/linux/darwin`, e o
`dev/hm-snapshot.sh` para validar refatorações.
