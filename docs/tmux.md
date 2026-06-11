# tmux — cheatsheet do gregioos

Referência rápida da config em `modules/home/tmux.nix`. Inspirada em
`omerxx/dotfiles` + `joshmedeski/sesh`. Roda em paralelo com zellij até
decidirmos remover.

## Prefix

`Ctrl-a` (não Ctrl-b). Leitura: `Ctrl-a` + `<tecla>` = "prefix + tecla".

## Painéis (splits)

| Atalho | Ação |
|---|---|
| `prefix \|` | Split vertical (preserva cwd) |
| `prefix -` | Split horizontal (preserva cwd) |
| `prefix x` | Mata o painel atual (sem confirmação) |
| `prefix z` | Zoom toggle no painel atual |
| `prefix S` | Toggle `synchronize-panes` (digita em todos os painéis) |
| `prefix {` / `}` | Move painel para esquerda/direita |
| `prefix !` | Move painel para janela própria |

> Nota: `prefix space` (default = cicla layouts) foi reassociado a
> `notify-jump` — ver [Notificações / fila de alertas](#notificações--fila-de-alertas).

### Navegação vim-aware (sem prefix!)

| Atalho | Ação |
|---|---|
| `Ctrl-h` `Ctrl-j` `Ctrl-k` `Ctrl-l` | Move foco entre painéis tmux **e** splits do nvim de forma transparente |

Funciona via `christoomey/vim-tmux-navigator` no nvim + plugin homônimo
no tmux. Detecta processo nvim/fzf no painel via regex `is_vim`.

### Resize

| Atalho | Ação |
|---|---|
| `prefix Ctrl-h/j/k/l` | Resize +5 na direção (com `-r`, repete sem prefix novo) |

## Janelas

| Atalho | Ação |
|---|---|
| `prefix c` | Nova janela |
| `prefix ,` | Renomear janela |
| `prefix n` / `p` | Próxima / anterior |
| `prefix 1`..`9` | Ir para janela N |
| `prefix &` | Mata janela |
| `prefix w` | Lista janelas (picker) |

## Sessões

| Atalho | Ação |
|---|---|
| `prefix T` | **sesh popup** — picker fancy com fzf-tmux (ver abaixo) |
| `prefix o` | **sessionx popup** — picker integrado com zoxide |
| `prefix s` | Lista sessões nativa do tmux |
| `prefix $` | Renomear sessão |
| `prefix d` | Detach |
| `prefix D` | Detach picker (escolhe qual cliente) |

### Popup sesh (prefix T)

Abre fzf-tmux 80%×70% com headers para troca rápida de fonte:

| Atalho dentro do popup | Fonte |
|---|---|
| `Ctrl-a` | Tudo (default — sesh list) |
| `Ctrl-t` | Apenas sessões tmux ativas |
| `Ctrl-g` | Apenas configs declaradas em `sesh.toml` |
| `Ctrl-x` | Diretórios do zoxide |
| `Ctrl-f` | Busca via `fd` em `~` (depth 2) |
| `Ctrl-d` | Mata a sessão tmux selecionada |
| `Tab` / `Shift-Tab` | Move cursor |

Config das sessões: `~/.config/sesh/sesh.toml` (gerado pelo módulo).

### sesh fora do tmux

`sesh` está em `home.packages`, então funciona como CLI universal:

```sh
sesh connect "$(sesh list | fzf)"   # sem tmux: cria sessão e attaca
sesh list -t                         # só tmux
sesh list -z                         # só zoxide
sesh last                            # última sessão
```

## Floax (scratch flutuante)

| Atalho | Ação |
|---|---|
| `prefix p` | Toggle floating pane (80%×80%, border magenta) |

Popup persistente para shell rápido / `claude` / `lazygit` sem sair do
layout principal. Ideal para perguntar algo ao Claude Code sem perder o
foco do editor.

## Modo cópia (vi)

| Atalho | Ação |
|---|---|
| `prefix [` | Entra em modo cópia |
| `v` | Inicia seleção (visual) |
| `V` | Seleção de linha |
| `Ctrl-v` | Seleção de bloco |
| `y` | Yank (vai pro clipboard via tmux-yank) |
| `q` / `Esc` | Sai |
| `prefix ]` | Cola |
| `/` `?` `n` `N` | Busca regex (forward/backward, próxima/anterior) |

Scrollback = 1.000.000 linhas (suficiente para diff longo do Claude).

## tmux-thumbs (hint mode estilo vimium)

Mostra hints sobre tokens (paths, hashes, URLs); digite as letras para copiar.

O bind default (`prefix space`) foi reassociado a `notify-jump`. Para usar
thumbs, verifique o mapeamento atual com `prefix ?` ou rebinde explicitamente
em `tmux.nix`.

## tmux-fzf (menu universal)

| Atalho | Ação |
|---|---|
| `prefix F` | Abre menu fzf com sessões/janelas/painéis/comandos/keybindings |

## fzf-tmux-url

| Atalho | Ação |
|---|---|
| `prefix u` | Lista URLs visíveis no scrollback; Enter abre no browser |

## Persistência (resurrect + continuum)

- **Auto-save** a cada 10min (`@continuum-save-interval '10'`).
- **Auto-restore** ao iniciar (`@continuum-restore 'on'`).
- Estratégia nvim: salva sessão do nvim (precisa `:mksession`).
- Captura conteúdo dos painéis (scrollback é restaurado).

| Atalho | Ação |
|---|---|
| `prefix Ctrl-s` | Save manual |
| `prefix Ctrl-r` | Restore manual |

Snapshots em `~/.local/share/tmux/resurrect/`.

## Logging

| Atalho | Ação |
|---|---|
| `prefix L` | Toggle pipe-pane → `~/.claude-logs/<sess>-<win>-<pane>-YYYYMMDD.log` |

Útil para auditoria de sessões com Claude Code. `display-message` mostra
qual painel está logando.

## Notificações / fila de alertas

Sistema de fila de alertas integrado com `notify-beep --queue` (NixOS package).
Quando o Claude Code dispara o hook `Notification`/`Stop`, grava um entry em
`~/.local/state/notify-beep/queue.jsonl` com a session/window/pane atual.

> A fila é multi-mux: entries têm campo `mux` (`tmux`/`herdr`) e convivem no
> mesmo arquivo. Para o lado herdr (toast nativo, `prefix+Space`/`prefix+Shift+Space`,
> handle por `terminal_id`), ver [docs/herdr.md](./herdr.md).

| Atalho | Ação |
|---|---|
| `prefix Space` | **`notify-jump`** — salta direto para o último alerta `unread` do host atual; marca como `read` |
| `prefix Ctrl-Space` | **`notify-pick`** — popup fzf 80%×70% com todas as notificações ordenadas por data; Enter = switch + marca read |

Status no picker: 🔴 unread · 👀 read · 💀 dead (session/window foi fechada).
Se o pane alvo morreu, a entry é marcada `dead` e o atalho mostra
`display-message` em vez de saltar.

### Comandos relacionados

```sh
notify-beep --queue --title "⚠️ Permissão" "aprovação"   # enfileira manualmente
notify-jump                                              # mesma coisa que prefix+Space
notify-jump --id <ID>                                    # salta para entry específico
notify-pick                                              # mesma coisa que prefix+Ctrl+Space
cat ~/.local/state/notify-beep/queue.jsonl              # inspeção crua
```

Hooks do Claude Code já configurados em `~/.claude/settings.json` (eventos
`Notification` com matchers `permission_prompt`/`idle_prompt` e `Stop`).

## Status bar

Catppuccin mocha (fork omerxx). Layout:
- **Esquerda**: nome da sessão (com ícone)
- **Centro**: janelas (número + nome, com fill)
- **Direita**: cwd basename + hora (HH:MM)

Border do painel ativo: magenta. Inativo: brightblack.

## Claude Code dentro do tmux

Settings já habilitados para evitar atritos:
- `allow-passthrough on` → OSC 9 (notificações), OSC 52 (clipboard)
- `set-clipboard on` → copy via app
- `S-Enter` → emite `[13;2u` (Shift+Enter quebra linha no Claude)
- `terminal-features ",sync"` → DECSET 2026 (reduz flicker)
- `extended-keys on` → suporte a kitty keyboard protocol
- Variável recomendada: `export CLAUDE_CODE_NO_FLICKER=1` no zshrc para
  forçar alt-screen buffer

## Sessões nomeadas comuns (workflow)

```sh
# entrar no projeto via sesh (cria + attacha)
sesh connect gregioos

# layout multi-pane manual rapidão
tmux new -s dev -c ~/code/proj \
  \; send-keys 'nvim .' C-m \
  \; split-window -h -p 40 \
  \; send-keys 'claude' C-m \
  \; split-window -v -p 40 \
  \; send-keys 'pnpm dev' C-m \
  \; select-pane -L
```

## Reset / debug

```sh
tmux kill-server                    # fecha tudo
tmux source ~/.config/tmux/tmux.conf  # recarrega config (após fr)
prefix :                            # entra em command-mode
prefix ?                            # lista todos os keybindings ativos
```

## Comparação rápida com zellij

| Ação | zellij (Ctrl-Space modo) | tmux (prefix Ctrl-a) |
|---|---|---|
| Split horizontal | `_` | `\|` |
| Split vertical | `-` | `-` |
| Navegar painel | `h/j/k/l` | `Ctrl-h/j/k/l` (sem prefix!) |
| Sessões | `s` (session-manager) | `T` (sesh) ou `o` (sessionx) |
| Detach | `Ctrl-d` | `d` |
| Zoom | `z` | `z` |
| Nova janela | `c` | `c` |
| Renomear janela | `,` | `,` |
| Sair do modo | `Esc` | (sempre fora — sem modos) |

tmux **não tem modos** (Normal/Tmux/Resize); todo bind passa por
prefix exceto navegação vim-aware (`Ctrl-h/j/k/l`) e os triggers
diretos (Floax via `@floax-bind 'p'` ainda exige prefix; thumbs idem).
