# herdr — cheatsheet do gregioos

Referência rápida do [herdr](https://herdr.dev) (terminal workspace manager
para agentes de AI). Instalado via flake input `github:ogulcancelik/herdr`
em `modules/core/packages.nix`. Config manual em `~/.config/herdr/config.toml`
(o herdr gerencia o próprio config — **não** está no nix; após editar, rode
`herdr server reload-config`).

## Prefix

`Ctrl-a` (igual ao tmux). Customizações ativas no config.toml:

| Atalho | Ação |
|---|---|
| `prefix \|` | Split vertical |
| `prefix /` | Last pane (vai-e-volta) |
| `prefix a` | Toggle sidebar |
| `prefix o` | Salta pro pane de origem da última notificação (toast) |
| `prefix alt+1..9` | Foca o agente N do sidebar |
| `prefix alt+g` | lazygit em pane temporário |
| `prefix Space` | **`notify-jump`** — salta pro último alerta unread |
| `prefix Shift+Space` | **`notify-pick`** — picker fzf em pane temporário |

## Notificações / fila de alertas

Mesmo sistema do tmux (ver `docs/tmux.md`), agora multi-mux. Quando o
Claude Code dispara os hooks `Stop`/`Notification`, o `claude-notify` chama
`notify-beep --queue`, que dentro do herdr:

1. Mostra **toast nativo** (`herdr notification show`) com som `done`
   (task terminou) ou `request` (pede permissão) — sem beep local duplicado
   (pw-play é só fallback). `prefix+o` salta pro pane de origem do toast.
2. Envia push pro ntfy.sh com contexto `herdr · workspace: X · tab: Y`.
3. Grava entry em `~/.local/state/notify-beep/queue.jsonl` com
   `mux: "herdr"` e `terminal_id` (handle durável — ids compactos tipo
   `w...-2` mudam quando panes fecham, então o jump re-resolve via
   `herdr pane list`).

| Atalho | Ação |
|---|---|
| `prefix Space` | `notify-jump` — foca o pane do último alerta unread (`herdr agent focus`); marca `read` |
| `prefix Shift+Space` | `notify-pick` — fzf com todas as notificações; Enter = saltar, ctrl-x = remover grupo, ctrl-a = limpar tudo |

Status no picker: 🔴 unread · 👀 read · 💀 dead (pane fechou). Entries herdr
aparecem como `workspace:tab`; entries tmux antigas como `sessão:janela.painel`
— os dois schemas convivem na mesma fila.

### Comandos relacionados

```sh
notify-beep --queue --sound request --title "⚠️ Permissão" "aprovação"  # enfileira
notify-jump                                  # mesma coisa que prefix+Space
notify-jump --id <ID>                        # salta para entry específico
notify-pick --list                           # lista crua (TSV)
cat ~/.local/state/notify-beep/queue.jsonl  # inspeção crua
```

## Agentes (nativo do herdr)

A integração claude↔herdr (`herdr integration install claude`, hook
`SessionStart` em `~/.claude/settings.json`) faz cada pane com Claude
reportar estado ao sidebar: `idle` / `working` / `blocked` / `done`.

```sh
herdr agent list                             # agentes detectados + status
herdr agent focus <terminal_id|nome>         # foca o pane do agente
herdr agent wait <target> --status idle      # bloqueia até o status
herdr wait agent-status <pane> --status done --timeout 60000
```

`prefix+alt+1..9` foca o agente N direto pelo sidebar — para "qual agente
preciso atender agora", o sidebar + toast nativo resolvem; a fila
(`notify-pick`) guarda o histórico de mensagens.

## wtree

`wtree <branch> --herdr` (ou auto-detect via `HERDR_ENV=1`) abre o worktree
como workspace herdr agrupado ao repo pai: tab `code` com split + tab `AI`
rodando `claude`. `wtree --rm <branch>` fecha o workspace antes de remover
o worktree. Ver `modules/scripts/wtree.nix`.

## Ambiente dentro de um pane

| Variável | Conteúdo |
|---|---|
| `HERDR_ENV=1` | Está dentro do herdr |
| `HERDR_PANE_ID` | Id legacy do pane (ex. `p_66`) — aceito por `herdr pane get` |
| `HERDR_SOCKET_PATH` | Socket da API (`~/.config/herdr/herdr.sock`) |

## Debug

```sh
herdr status                  # versão client/server, socket
herdr server reload-config    # aplica config.toml editado
herdr pane list | jq          # panes vivos (envelope .result.panes)
herdr integration status      # estado das integrações de agentes
```
