# GregioOS

Configuração multi-host: **NixOS** (home-manager, Stylix, GNOME) e **macOS**
(nix-darwin, homebrew, aerospace), num flake só.

## Hosts

| attr do flake | máquina | sistema | usuário |
| --- | --- | --- | --- |
| `gregio-asus-tuf-f15` | ASUS TUF F15 | NixOS x86_64 | `gregio` |
| `gregio-note` | notebook secundário | NixOS x86_64 | `gregio` |
| `CV9NF4V0H6` | MacBook de trabalho | darwin aarch64 | `guilherme.gregio` |
| `nxt-os-01` | MacBook pessoal | darwin aarch64 | a confirmar |

O attr **é o hostname real**, então no macOS `darwin-rebuild --flake .` resolve
sem `#nome`. Cada host tem `hosts/<host>/variables.nix`; o que é só daquela
máquina fica em `hosts/<host>/default.nix` e nunca no comum.

## Estrutura

```
flake.nix                    # mkNixos e mkDarwin, um attr por host
hosts/<host>/                # variables.nix + (hardware.nix | default.nix)
modules/
  core/                      # sistema NixOS
  drivers/                   # GPU (nvidia, amdgpu, intel)
  darwin/                    # sistema macOS: defaults, homebrew, touchid
  home/
    common/                  # home-manager das TRÊS máquinas
    linux/                   # dconf, stylix, kitty, zed, obs
    darwin/                  # aerospace, herdr, nh, pacotes CLI do mac
  scripts/                   # derivations de scripts (wtree, notify-*, ...)
profiles/nvidia-laptop/      # importa hardware + drivers + core (NixOS)
dev/hm-snapshot.sh           # compara o perfil home-manager entre dois estados
docs/                        # guias: nova máquina (macOS/NixOS), segredos
```

## Comandos essenciais

Os mesmos nas três máquinas — muda só o backend, por plataforma:

| Comando           | Ação                                             |
| ----------------- | ------------------------------------------------ |
| `fr`              | rebuild (`nh os switch` no Linux, `nh darwin switch` no macOS) |
| `fu`              | o mesmo, com `--update` do flake                 |
| `nix flake check --all-systems` | valida todos os hosts               |
| `ncg`             | garbage collect + reboot (**só NixOS**)          |

## Fluxo de trabalho

1. Editar módulo
2. `nix flake check` — validar sintaxe
3. `fr` — aplicar rebuild
4. Testar

## Pontos de atenção

- **Teclado**: layout `us` variante `intl` + `lv3:caps_switch` (CapsLock como AltGr). Configurado em `modules/core/services.nix` (xkb) e `modules/home/linux/dconf.nix` (GNOME). Manter ambos sincronizados.
- **Console**: `console.useXkbConfig = true` em `system.nix` herda o xkb — não usar `consoleKeyMap` separado.
- **Novo módulo home-manager**: importar em `modules/home/common/default.nix` (as três máquinas) ou no `linux/`/`darwin/` correspondente.
- **Perfil**: `nvidia-laptop` é o único perfil; importa `hosts/<host>/hardware.nix` + `modules/drivers` + `modules/core`.

### Multi-plataforma — o que morde

- **Nunca use `pkgs` dentro de `imports`**: dá recursão infinita, porque são os imports que produzem o `config`. O dispatch de plataforma usa `hostPlatform`, vindo de specialArgs. Dentro do corpo do módulo, `pkgs.stdenv.isDarwin` é seguro.
- **`stylix` não existe no macOS**: nenhum módulo de `home/common` pode declarar `stylix.*`. Os alvos desligados ficam em `home/linux/stylix.nix`.
- **Pacote que não builda em darwin**: se o módulo aceitar `package = null` (caso do ghostty, que no mac vem do cask), use isso em vez de duplicar a config.
- **`system.stateVersion` do NixOS não se atualiza** — só marca a versão de instalação. `hosts/*/variables.nix` separa `systemStateVersion` de `homeStateVersion` justamente por isso.
- **nix-darwin e nixpkgs precisam casar de release**: o input está pinado em `nix-darwin-26.05`. Ao subir o `nixpkgs` no `fu`, suba a branch do `darwin` **no mesmo commit**, senão o eval quebra.
- **Refatoração estrutural muda o drvPath sem mudar nada**: separar módulos reordena listas. Para saber se algo mudou de verdade, compare com `dev/hm-snapshot.sh`.

### macOS, especificamente

- **Quote argumentos com `#`**: o prezto liga `EXTENDED_GLOB` e `nix build .#foo` morre em `zsh: no matches found`. Use `".#foo"`.
- **`sudo -E` não preserva o ambiente**: o sudoers do macOS traz `env_reset`. Use `sudo env PATH=$PATH darwin-rebuild …`.
- **`nh` no macOS vem do home-manager** (`modules/home/darwin/nh.nix`) — o nix-darwin não tem `programs.nh`.
- **Tokens da Stone** seguem como placeholders `<REPLACE>` em `hosts/CV9NF4V0H6`. A migração para sops-nix é a fase 4B do plano.

## Convenções de commit

Prefixos: `feat:`, `fix:`, `chore:`

## Referências

- **Multiplexer**: só o `herdr`. tmux e zellij foram removidos em 2026-08-29 — não eram usados. Os scripts em `modules/scripts/` ainda têm auto-detect para eles; é código morto tolerado, não suporte ativo.

> **Nota para quem clonou este repo:** o `CLAUDE.md` descreve *estas* máquinas.
> A tabela de hosts, os caminhos e as armadilhas valem para esta config — o que
> for reaproveitar, confira contra o seu próprio setup. Ver o `README.md`.
