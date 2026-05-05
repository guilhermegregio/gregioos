# nvim — cheatsheet do gregioos

Referência rápida da config em `modules/home/nvim/`. Cópia de
[`omerxx/dotfiles/nvim`](https://github.com/omerxx/dotfiles/tree/master/nvim),
base **LazyVim** + extras + plugins custom.

Config ativada via `modules/home/nvim.nix` — `programs.neovim.enable` +
`xdg.configFile.nvim` symlinkado para o repo (mutável: `:Lazy sync`
escreve in-place no `lazy-lock.json`).

## Leader & escape

`<leader>` = `<space>`. Toda referência a `<leader>X` significa "espaço
seguido de X".

| Atalho | Modo | Ação |
|---|---|---|
| `jj` / `jk` | insert | Sai para normal (Esc) |
| `<C-c>` | insert | Esc (default) |
| `:w` `:q` `:wq` `:q!` | command | Os de sempre |

## Bootstrap (primeira vez)

1. `nvim` — LazyVim clona `lazy.nvim` em `~/.local/share/nvim/lazy/` e
   abre o picker de plugins automaticamente.
2. `:Lazy sync` — instala/atualiza tudo do `lazy-lock.json`.
3. `:Mason` — abre o gerenciador de LSPs/formatters/linters; LazyVim
   instala automaticamente os definidos em `ensure_installed` (stylua,
   shellcheck, shfmt, flake8).
4. `:checkhealth` — sanity check (treesitter, LSP, providers).
5. `:LazyExtras` — UI para ligar/desligar extras (já vêm os do
   `lazyvim.json`).

## Plugins de produtividade (LazyVim defaults)

### File explorer & busca

| Atalho | Ação |
|---|---|
| `<leader>fe` / `<leader>e` | Abre **mini.files** (extra ativo) |
| `<leader>ff` | Find files (cwd) |
| `<leader>fF` | Find files (root) |
| `<leader>fr` | Recent files |
| `<leader>fb` | Buffers |
| `<leader>/` ou `<leader>sg` | Grep ao vivo (ripgrep) |
| `<leader>sw` | Grep da palavra sob o cursor |
| `<leader>fp` | **(custom)** Find files dentro do plugin root |
| `<leader>,` | Picker de buffers |
| `<leader>:` | Histórico de comandos |

### Navegação entre painéis (vim-tmux-navigator)

| Atalho | Ação |
|---|---|
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Move foco entre splits do nvim **e** painéis tmux de forma transparente |

### Buffers

| Atalho | Ação |
|---|---|
| `H` / `L` ou `<S-h>` / `<S-l>` | Buffer anterior / próximo |
| `[b` / `]b` | Idem |
| `<leader>bd` | Fecha buffer atual |
| `<leader>bo` | Fecha outros buffers |
| `<leader>bp` | Toggle pin no bufferline |

### Janelas / splits

| Atalho | Ação |
|---|---|
| `<leader>w-` ou `<C-w>s` | Split horizontal |
| `<leader>w\|` ou `<C-w>v` | Split vertical |
| `<leader>wd` ou `<C-w>q` | Fecha split |
| `<leader>w=` | Equaliza tamanhos |
| `<C-Up/Down/Left/Right>` | Redimensiona |

### Tabs

| Atalho | Ação |
|---|---|
| `<leader><tab><tab>` | Nova tab |
| `<leader><tab>l` / `<tab>h` | Próxima / anterior |
| `<leader><tab>d` | Fecha tab |

### Diagnostics & quickfix

| Atalho | Ação |
|---|---|
| `]d` / `[d` | Próximo / anterior diagnostic |
| `]e` / `[e` | Próximo / anterior erro |
| `]w` / `[w` | Próximo / anterior warning |
| `<leader>xx` | Toggle Trouble (diagnostics) |
| `<leader>xX` | Trouble (buffer) |
| `<leader>xL` | Trouble loclist |
| `<leader>xQ` | Trouble quickfix |

### LSP

| Atalho | Ação |
|---|---|
| `gd` | Goto definition |
| `gD` | Goto declaration |
| `gr` | References |
| `gI` | Implementation |
| `gy` | Type definition |
| `K` | Hover docs |
| `<leader>cr` | Rename |
| `<leader>ca` | Code action |
| `<leader>cf` | Format buffer (conform) |
| `<leader>cl` | LspInfo |
| `<leader>cd` | Line diagnostics |

#### Override TypeScript (custom)

| Atalho | Ação |
|---|---|
| `<leader>co` | TypescriptOrganizeImports |
| `<leader>cR` | TypescriptRenameFile |

### Git

| Atalho | Ação |
|---|---|
| `<leader>gg` | LazyGit (instalado no sistema) |
| `<leader>gG` | LazyGit cwd |
| `<leader>gb` | Git blame |
| `<leader>gB` | Browse na origem (forge) |
| `]h` / `[h` | Próximo / anterior hunk (gitsigns) |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghb` | Blame line |

### UI toggles

| Atalho | Ação |
|---|---|
| `<leader>uw` | Toggle wrap |
| `<leader>us` | Toggle spell |
| `<leader>ul` | Toggle line numbers |
| `<leader>uL` | Toggle relative numbers |
| `<leader>uc` | Toggle conceal |
| `<leader>uf` | Toggle auto-format global |
| `<leader>uF` | Toggle auto-format buffer |

### Movimento de linhas

| Atalho | Ação |
|---|---|
| `<A-j>` / `<A-k>` (visual e normal) | Move linha/seleção pra baixo/cima |
| `<` / `>` (visual) | Indenta mantendo seleção |

### Terminal embutido

| Atalho | Ação |
|---|---|
| `<C-/>` | Toggle terminal flutuante (snacks) |
| `<leader>ft` | Terminal cwd |
| `<leader>fT` | Terminal root |

## Plugins custom (deste config)

### opencode.nvim — IA inline

Plugin custom em `lua/plugins/opencode.lua`. Integra
[opencode](https://github.com/NickvanDyke/opencode.nvim) como popup IA.

| Atalho | Modo | Ação |
|---|---|---|
| `<leader>ot` | n | Toggle popup embedded |
| `<leader>oa` | n | Pergunta sobre `@cursor` (palavra sob cursor) |
| `<leader>oa` | v | Pergunta sobre `@selection` |
| `<leader>o+` | n | Adiciona `@buffer` ao prompt (append) |
| `<leader>o+` | v | Adiciona `@selection` ao prompt |
| `<leader>oe` | n | Explain `@cursor` e contexto |
| `<leader>on` | n | Nova session do opencode |
| `<leader>os` | n/v | Picker de prompts |
| `<S-C-u>` | n | Messages — half page up |
| `<S-C-d>` | n | Messages — half page down |

`vim.opt.autoread = true` é setado para auto-reload em mudanças.

### mini.surround — manipulação de delimitadores

Plugin em `lua/plugins/surround.lua`. Mappings customizados
(diferente do `s/d/r` padrão do mini):

| Atalho | Ação |
|---|---|
| `sa<motion><char>` | **a**dd surround (ex.: `saiw"` envolve palavra com aspas) |
| `sd<char>` | **d**elete surround (ex.: `sd"` remove aspas) |
| `gsr<old><new>` | **r**eplace surround |
| `gsf<char>` | **f**ind surround à direita |
| `gsF<char>` | find à esquerda |
| `gsh<char>` | **h**ighlight surround |
| `gsn<n>` | atualiza n_lines |

### conform.nvim — yaml K8s-friendly

Plugin em `lua/plugins/conform.lua`. Override do formatter de YAML para
`yamlfmt` com `-indentless_arrays=true` (ideal para Kubernetes/Helm).

```sh
:ConformInfo                # ver formatters disponíveis no buffer
:lua require("conform").format()  # formata buffer
```

### Treesitter parsers extras

Em `lua/plugins/example.lua` (sim, o nome é "example" mas está ativo):
caddy, bash, html, javascript, json, lua, markdown, markdown_inline,
python, query, regex, tsx, typescript, vim, yaml.

Comandos:

```sh
:TSUpdate
:TSInstall <lang>
:TSPlaygroundToggle    # se nvim-treesitter-playground estiver instalado
```

## Extras LazyVim ativos (`lazyvim.json`)

| Extra | O que adiciona |
|---|---|
| `coding.mini-surround` | mini.surround (já customizado acima) |
| `dap.core` | nvim-dap + dap-ui |
| `editor.harpoon2` | Harpoon 2 (jump rápido entre arquivos pinados) |
| `editor.mini-files` | mini.files como file explorer principal |
| `lang.docker` | Dockerfile/compose LSP + treesitter |
| `lang.go` | gopls + tools (custom config em `plugins/go.lua`) |
| `lang.helm` | helm_ls (templates K8s) |
| `lang.json` | jsonls + schemastore |
| `lang.markdown` | markdownlint, marksman, render |
| `lang.terraform` | terraformls + tflint |
| `lang.typescript` | tsserver + typescript.nvim |
| `lang.yaml` | yamlls + schemastore |

### Harpoon2 (jump rápido)

| Atalho | Ação |
|---|---|
| `<leader>H` | Adiciona arquivo atual à lista |
| `<leader>h` | Abre menu Harpoon |
| `<C-1>` … `<C-9>` | Pula para slot N |

### DAP

| Atalho | Ação |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle UI |
| `<leader>de` | Eval expression |

## Treesitter / LSP / formatters

### Mason — gerenciador de binários

```sh
:Mason             # UI principal
:MasonInstall <pkg>
:MasonUninstall <pkg>
:MasonUpdate
```

`ensure_installed` (auto-instala): `stylua`, `shellcheck`, `shfmt`,
`flake8`. Os LSPs dos extras (gopls, tsserver, helm_ls, terraformls,
yamlls, jsonls, dockerls, marksman) também entram aqui.

### LSP servers configurados manualmente

| Server | Onde | Notas |
|---|---|---|
| `pyright` | `plugins/example.lua` | Python types |
| `tsserver` | `plugins/example.lua` | + typescript.nvim wrapper |
| `gopls` | `plugins/go.lua` | unusedparams, staticcheck, gofumpt, completeUnimported |

## Lazy.nvim — gerência de plugins

| Comando | Ação |
|---|---|
| `:Lazy` | UI |
| `:Lazy sync` | Install + update + clean |
| `:Lazy update` | Atualiza plugins (mexe em `lazy-lock.json`) |
| `:Lazy restore` | Volta para versão do lock |
| `:Lazy clean` | Remove órfãos |
| `:Lazy profile` | Profiling de startup |
| `:Lazy log` | Log de mudanças |
| `<leader>l` | Atalho para `:Lazy` |
| `<leader>L` | LazyVim Changelog |

## Options ativos (`lua/config/options.lua`)

```lua
vim.opt.wrap = true            -- wrap longo (override do default)
vim.opt.foldmethod = "manual"  -- folds manuais
vim.g.codeium_os = "Darwin"    -- legado mac (ignorado em linux)
vim.g.codeium_arch = "arm64"
```

## Manutenção

```sh
# Recarregar config sem fechar o nvim
:source $MYVIMRC

# Reset total (apaga plugins, dados e cache)
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim

# Após editar a config no repo
fr             # rebuild do NixOS — só necessário se mudou nvim.nix
:Lazy sync     # atualiza plugins se mexeu em lua/

# Pinar versão de plugin após :Lazy update
git -C ~/gregioos add modules/home/nvim/lazy-lock.json
git -C ~/gregioos commit -m "chore: bump nvim plugins"
```

## Onde está cada coisa

```
modules/home/nvim/
├── init.lua                    # require("config.lazy")
├── lazyvim.json                # extras ativos do LazyVim
├── lazy-lock.json              # versões pinadas dos plugins
├── .neoconf.json               # config global do neoconf
├── stylua.toml                 # formatter Lua
└── lua/
    ├── config/
    │   ├── lazy.lua            # bootstrap + setup do lazy.nvim
    │   ├── options.lua         # vim.opt.* customs
    │   ├── keymaps.lua         # jj/jk → Esc
    │   └── autocmds.lua        # (vazio — só template)
    └── plugins/
        ├── conform.lua         # yamlfmt K8s-friendly
        ├── example.lua         # gruvbox, trouble, telescope, lsp ts/py, treesitter, mason
        ├── go.lua              # gopls config
        ├── opencode.lua        # IA inline (<leader>o*)
        └── surround.lua        # mini.surround com mappings sa/sd/gsr…
```

## Integração com tmux

Funciona junto com a config tmux do gregioos (`docs/tmux.md`):

- `<C-h/j/k/l>` navega entre splits nvim **e** painéis tmux sem prefix
- `prefix p` abre Floax (popup tmux) — útil para `lazygit`/`claude`
  fora do nvim sem perder posição
- Auto-restore de sessão nvim via tmux-resurrect (`@resurrect-strategy-nvim 'session'`)

## Referências

- LazyVim docs: <https://www.lazyvim.org/keymaps>
- Origem: <https://github.com/omerxx/dotfiles/tree/master/nvim>
- Plugin opencode: <https://github.com/NickvanDyke/opencode.nvim>
- mini.nvim: <https://github.com/nvim-mini/mini.nvim>
