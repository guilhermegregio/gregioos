# GregioOS

NixOS flake com home-manager, Stylix e GNOME. Configuração pessoal para workstations.

## Estrutura

```
flake.nix                          # Entrada principal (nixos-unstable)
hosts/
  gregio-asus-tuf-f15/             # Host principal (Ghostty, Zen Browser)
    variables.nix                  # Variáveis do host (terminal, browser, git, etc.)
    hardware.nix
  gregio-note/                     # Host secundário (Kitty, Brave)
    variables.nix
    hardware.nix
modules/
  core/                            # Configuração do sistema
    boot.nix, services.nix, system.nix, packages.nix, hardware.nix
  drivers/                         # Drivers GPU (nvidia, amdgpu, intel)
  home/                            # Home-manager (user-level)
    default.nix                    # Importa todos os módulos home
    dconf.nix, stylix.nix, zsh.nix, bash.nix, git.nix, ...
profiles/
  nvidia-laptop/default.nix        # Único perfil ativo — importa drivers + core
wallpapers/
```

## Hosts

Cada host define variáveis em `hosts/<host>/variables.nix` (terminal, browser, gitEmail, etc.). O host ativo é definido em `flake.nix` na variável `host`.

## Comandos essenciais

| Comando            | Ação                                      |
| ------------------ | ----------------------------------------- |
| `fr`               | `nh os switch --hostname <profile>` — rebuild |
| `fu`               | `nh os switch --hostname <profile> --update` — rebuild + update flake |
| `nix flake check`  | Validar sintaxe do flake                  |
| `ncg`              | Garbage collect + reboot                  |

## Fluxo de trabalho

1. Editar módulo
2. `nix flake check` — validar sintaxe
3. `fr` — aplicar rebuild
4. Testar

## Pontos de atenção

- **Teclado**: layout `us` variante `intl` + `lv3:caps_switch` (CapsLock como AltGr). Configurado em `modules/core/services.nix` (xkb) e `modules/home/dconf.nix` (GNOME). Manter ambos sincronizados.
- **Console**: `console.useXkbConfig = true` em `system.nix` herda o xkb — não usar `consoleKeyMap` separado.
- **NixOS unstable**: opções deprecadas mudam frequentemente — checar changelogs ao atualizar.
- **Novo módulo home-manager**: importar em `modules/home/default.nix`.
- **Perfil**: `nvidia-laptop` é o único perfil; importa `hosts/<host>/hardware.nix` + `modules/drivers` + `modules/core`.

## Convenções de commit

Prefixos: `feat:`, `fix:`, `chore:`
