{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "wtree";

  runtimeInputs = with pkgs; [
    bash
    git
    fd
    coreutils
    findutils
    util-linux
  ];

  text = ''
    COMMAND="create"
    BRANCH=""
    BASE="main"
    USE_EXISTING=false
    FORCE=false
    MULTIPLEXER=""

    print_usage() {
      cat <<'HELP'
    uso: wtree <branch> [opcoes]            # cria worktree + sessao no multiplexer
         wtree --rm <branch> [-f]           # remove worktree, branch e sessao

    Cria um git worktree em ~/code/worktrees/<repo>-<branch>, copia
    qualquer .env* (.envrc, .env, .env.local, .env.production, .env.staging,
    etc.), roda direnv allow + pnpm install e abre sessao no multiplexer
    (auto-detect via $TMUX/$ZELLIJ; default tmux) com a tab AI ja rodando
    claude.

    Modo create (default):
      --base <branch>   Branch base ao criar nova (default: main)
      --existing        Usar branch ja existente em vez de criar

    Modo remove:
      --rm              Ativa modo de remocao
      -f, --force       Forca git worktree remove -f e git branch -D

    Outros:
      --tmux            Forca uso de tmux (override do auto-detect)
      --zellij          Forca uso de zellij (override do auto-detect)
      -h, --help        Mostra este help
    HELP
    }

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --rm)
          COMMAND="remove"
          shift
          ;;
        --base)
          BASE="''${2:-}"
          if [[ -z "$BASE" ]]; then
            echo "wtree: --base requer valor" >&2
            exit 2
          fi
          shift 2
          ;;
        --existing)
          USE_EXISTING=true
          shift
          ;;
        -f|--force)
          FORCE=true
          shift
          ;;
        --tmux)
          if [[ -n "$MULTIPLEXER" && "$MULTIPLEXER" != "tmux" ]]; then
            echo "wtree: --tmux conflita com --zellij" >&2
            exit 2
          fi
          MULTIPLEXER="tmux"
          shift
          ;;
        --zellij)
          if [[ -n "$MULTIPLEXER" && "$MULTIPLEXER" != "zellij" ]]; then
            echo "wtree: --zellij conflita com --tmux" >&2
            exit 2
          fi
          MULTIPLEXER="zellij"
          shift
          ;;
        -h|--help)
          print_usage
          exit 0
          ;;
        --*)
          echo "wtree: flag desconhecida: $1" >&2
          exit 2
          ;;
        *)
          if [[ -z "$BRANCH" ]]; then
            BRANCH="$1"
          else
            echo "wtree: argumento extra: $1" >&2
            exit 2
          fi
          shift
          ;;
      esac
    done

    if [[ -z "$BRANCH" ]]; then
      print_usage >&2
      exit 2
    fi

    if ! SOURCE_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
      echo "wtree: nao esta em um git repo" >&2
      exit 2
    fi

    if [[ -z "$MULTIPLEXER" ]]; then
      if [[ -n "''${TMUX:-}" ]]; then
        MULTIPLEXER="tmux"
      elif [[ -n "''${ZELLIJ:-}" ]]; then
        MULTIPLEXER="zellij"
      else
        MULTIPLEXER="tmux"
      fi
    fi

    REPO_NAME=$(basename "$SOURCE_ROOT")
    SAFE_BRANCH="''${BRANCH//\//-}"
    WORKTREE_BASE="$HOME/code/worktrees"
    WORKTREE_DIR="$WORKTREE_BASE/''${REPO_NAME}-''${SAFE_BRANCH}"
    SESSION_NAME="''${REPO_NAME}-''${SAFE_BRANCH}"

    if [[ "$COMMAND" == "remove" ]]; then
      if [[ "$SOURCE_ROOT" == "$WORKTREE_DIR" ]]; then
        echo "wtree: nao da pra remover de dentro do proprio worktree" >&2
        echo "    cd para outro worktree (ex: o repo principal) e tente de novo" >&2
        exit 2
      fi

      echo "==> kill sessao do multiplexer '$SESSION_NAME'"
      tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
      zellij kill-session "$SESSION_NAME" >/dev/null 2>&1 || true
      zellij delete-session "$SESSION_NAME" >/dev/null 2>&1 || true

      if [[ -d "$WORKTREE_DIR" ]]; then
        echo "==> git worktree remove $WORKTREE_DIR"
        if $FORCE; then
          git -C "$SOURCE_ROOT" worktree remove -f "$WORKTREE_DIR"
        else
          if ! err=$(git -C "$SOURCE_ROOT" worktree remove "$WORKTREE_DIR" 2>&1); then
            echo "wtree: falha ao remover worktree:" >&2
            echo "    $err" >&2
            echo "    use -f para forcar" >&2
            exit 1
          fi
        fi
      else
        echo "==> worktree nao existe em $WORKTREE_DIR (skip)"
      fi

      echo "==> git branch -d $BRANCH"
      if $FORCE; then
        if ! err=$(git -C "$SOURCE_ROOT" branch -D "$BRANCH" 2>&1); then
          echo "    (branch nao existia: $err)"
        fi
      else
        if ! err=$(git -C "$SOURCE_ROOT" branch -d "$BRANCH" 2>&1); then
          echo "wtree: branch nao removida:" >&2
          echo "    $err" >&2
          echo "    use -f para forcar (git branch -D)" >&2
          exit 1
        fi
      fi

      echo "==> pronto. worktree, branch e sessao do multiplexer removidos"
      exit 0
    fi

    if [[ -e "$WORKTREE_DIR" ]]; then
      echo "wtree: $WORKTREE_DIR ja existe" >&2
      exit 1
    fi

    mkdir -p "$WORKTREE_BASE"

    echo "==> git worktree add $WORKTREE_DIR"
    if $USE_EXISTING; then
      git -C "$SOURCE_ROOT" worktree add "$WORKTREE_DIR" "$BRANCH"
    else
      git -C "$SOURCE_ROOT" worktree add -b "$BRANCH" "$WORKTREE_DIR" "$BASE"
    fi

    echo "==> copiando .env*"
    copied=0
    while IFS= read -r -d "" envfile; do
      rel="''${envfile#"$SOURCE_ROOT"/}"
      dest="$WORKTREE_DIR/$rel"
      mkdir -p "$(dirname "$dest")"
      cp "$envfile" "$dest"
      echo "    $rel"
      copied=$((copied + 1))
    done < <(fd -H -I -t f \
      -E node_modules -E .git -E .next -E .direnv -E .nx -E .turbo -E .cache -E dist -E build \
      '^\.env' "$SOURCE_ROOT" --print0)
    if [[ $copied -eq 0 ]]; then
      echo "    (nenhum arquivo encontrado)"
    fi

    if command -v direnv >/dev/null 2>&1 && [[ -f "$WORKTREE_DIR/.envrc" ]]; then
      echo "==> direnv allow"
      (cd "$WORKTREE_DIR" && direnv allow)
    fi

    if command -v pnpm >/dev/null 2>&1 && [[ -f "$WORKTREE_DIR/package.json" ]]; then
      echo "==> pnpm install"
      (cd "$WORKTREE_DIR" && pnpm install)
    fi

    cd "$WORKTREE_DIR"

    if [[ "$MULTIPLEXER" == "tmux" ]]; then
      echo "==> abrindo tmux sessao $SESSION_NAME"

      if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "wtree: sessao tmux '$SESSION_NAME' ja existe — anexando"
      else
        tmux new-session -d -s "$SESSION_NAME" -n "code" -c "$WORKTREE_DIR"
        tmux split-window -h -t "$SESSION_NAME:code" -c "$WORKTREE_DIR"
        tmux select-pane -t "$SESSION_NAME:code.1"

        tmux new-window -t "$SESSION_NAME" -n "AI" -c "$WORKTREE_DIR" "zsh -ic claude"
        tmux select-window -t "$SESSION_NAME:AI"
      fi

      if [[ -n "''${TMUX:-}" ]]; then
        tmux switch-client -t "$SESSION_NAME"
      else
        exec tmux attach -t "$SESSION_NAME"
      fi
    else
      LAYOUT_FILE="$HOME/.config/zellij/layouts/wtree.kdl"
      if [[ ! -f "$LAYOUT_FILE" ]]; then
        echo "wtree: layout nao encontrado em $LAYOUT_FILE" >&2
        echo "wtree: rebuilde o sistema (nixos-rebuild switch) para gerar." >&2
        exit 1
      fi

      echo "==> abrindo zellij sessao $SESSION_NAME"

      if [[ -n "''${ZELLIJ:-}" ]]; then
        # zellij precisa de TTY: usa script(1) como pty falso e setsid pra
        # destacar do terminal atual. A sessao roda detached em background
        # ate o switch-session abaixo "puxar" o cliente pra ela.
        # PTY generoso (300x100) pra sessao nao iniciar pequena. zellij
        # reajusta pro tamanho real do terminal externo automaticamente
        # quando o client conecta via switch-session.
        setsid -f script -qfec \
          "stty rows 100 cols 300; zellij --session '$SESSION_NAME' --new-session-with-layout '$LAYOUT_FILE'" \
          /dev/null </dev/null >/dev/null 2>&1 || true

        # esperar a sessao aparecer no list-sessions (max ~3s)
        for _ in $(seq 1 30); do
          if zellij list-sessions -s 2>/dev/null | grep -qx "$SESSION_NAME"; then
            break
          fi
          sleep 0.1
        done

        echo "==> switch-session $SESSION_NAME"
        zellij action switch-session "$SESSION_NAME"
      else
        exec zellij --session "$SESSION_NAME" --new-session-with-layout "$LAYOUT_FILE"
      fi
    fi
  '';
}
