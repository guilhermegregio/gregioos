{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "notify-remove";

  runtimeInputs = with pkgs; [
    bash
    coreutils
    jq
    util-linux # flock
  ];

  text = ''
    QUEUE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/notify-beep"
    QUEUE_FILE="$QUEUE_DIR/queue.jsonl"
    LOCK_FILE="$QUEUE_DIR/queue.lock"

    target_id=""
    do_group=false
    do_all=false

    usage() {
      cat <<EOF
uso: notify-remove [flags]

flags:
  --id ID    remove a entry com esse id
  --group    (junto com --id) remove TODAS as entries do mesmo destino
             que essa entry — tmux: (session, window_idx, pane, host);
             herdr: (terminal_id, host)
  --all      limpa a fila inteira (truncate)
  -h, --help mostra esta ajuda
EOF
    }

    while [[ "''${1:-}" == --* || "''${1:-}" == -h ]]; do
      case "$1" in
        --id)      target_id="''${2:-}"; shift 2 ;;
        --id=*)    target_id="''${1#--id=}"; shift ;;
        --group)   do_group=true; shift ;;
        --all)     do_all=true; shift ;;
        --help|-h) usage; exit 0 ;;
        *)
          echo "notify-remove: flag desconhecida: $1" >&2
          usage >&2
          exit 2
          ;;
      esac
    done

    if ! $do_all && [ -z "$target_id" ]; then
      usage >&2
      exit 2
    fi

    if [ ! -e "$QUEUE_FILE" ]; then
      exit 0
    fi

    mkdir -p "$QUEUE_DIR"

    (
      flock -x 9

      if $do_all; then
        : > "$QUEUE_FILE"
        exit 0
      fi

      tmp="$(mktemp "$QUEUE_FILE.tmp.XXXXXX")"

      if $do_group; then
        # Encontra a entry-alvo, extrai a chave do grupo (por mux),
        # filtra fora todas as entries com esses mesmos campos.
        ENTRY="$(jq -c -s --arg id "$target_id" \
          '[.[] | select(.id == $id)] | last // null' \
          "$QUEUE_FILE")"

        if [ "$ENTRY" = "null" ] || [ -z "$ENTRY" ]; then
          rm -f "$tmp"
          exit 0
        fi

        MUX="$(echo  "$ENTRY" | jq -r '.mux // "tmux"')"
        HOST="$(echo "$ENTRY" | jq -r .host)"

        if [ "$MUX" = "herdr" ]; then
          TID="$(echo "$ENTRY" | jq -r '.terminal_id // ""')"

          jq -c \
            --arg t "$TID" \
            --arg h "$HOST" \
            'select(
               ((.mux // "tmux") != "herdr")
               or ((.terminal_id // "") != $t) or (.host != $h)
             )' \
            "$QUEUE_FILE" > "$tmp"
        else
          SESSION="$(echo "$ENTRY" | jq -r .session)"
          WIN="$(echo    "$ENTRY" | jq -r .window_idx)"
          PANE="$(echo   "$ENTRY" | jq -r .pane)"

          jq -c \
            --arg s "$SESSION" \
            --argjson w "$WIN" \
            --argjson p "$PANE" \
            --arg h "$HOST" \
            'select(
               ((.mux // "tmux") != "tmux")
               or (.session != $s) or (.window_idx != $w)
               or (.pane != $p) or (.host != $h)
             )' \
            "$QUEUE_FILE" > "$tmp"
        fi
      else
        jq -c --arg id "$target_id" \
          'select(.id != $id)' \
          "$QUEUE_FILE" > "$tmp"
      fi

      mv "$tmp" "$QUEUE_FILE"
    ) 9>"$LOCK_FILE"
  '';
}
