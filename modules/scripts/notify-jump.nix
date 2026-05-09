{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "notify-jump";

  runtimeInputs = with pkgs; [
    bash
    coreutils
    jq
    tmux
    util-linux # flock
  ];

  text = ''
    QUEUE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/notify-beep"
    QUEUE_FILE="$QUEUE_DIR/queue.jsonl"
    LOCK_FILE="$QUEUE_DIR/queue.lock"

    target_id=""

    usage() {
      cat <<EOF
uso: notify-jump [--id ID]

Sem --id: salta para o último alerta "unread" do host atual.
Com --id: salta para o entry com esse id (independente de status).
EOF
    }

    while [[ "''${1:-}" == --* || "''${1:-}" == -h ]]; do
      case "$1" in
        --id)      target_id="''${2:-}"; shift 2 ;;
        --id=*)    target_id="''${1#--id=}"; shift ;;
        --help|-h) usage; exit 0 ;;
        *)
          echo "notify-jump: flag desconhecida: $1" >&2
          usage >&2
          exit 2
          ;;
      esac
    done

    notify() {
      if [ -n "''${TMUX:-}" ]; then
        tmux display-message "$1"
      else
        echo "$1" >&2
      fi
    }

    if [ ! -s "$QUEUE_FILE" ]; then
      notify "notify-jump: fila vazia"
      exit 0
    fi

    mkdir -p "$QUEUE_DIR"

    mark_status() {
      local id="$1" status="$2"
      local tmp
      tmp="$(mktemp "$QUEUE_FILE.tmp.XXXXXX")"
      jq -c --arg id "$id" --arg st "$status" \
        'if .id == $id then .status = $st else . end' \
        "$QUEUE_FILE" > "$tmp"
      mv "$tmp" "$QUEUE_FILE"
    }

    (
      flock -x 9

      HOST="$(hostname)"

      if [ -n "$target_id" ]; then
        ENTRY="$(jq -c -s --arg id "$target_id" \
          '[.[] | select(.id == $id)] | last // null' \
          "$QUEUE_FILE")"
      else
        ENTRY="$(jq -c -s --arg h "$HOST" \
          '[.[] | select(.status == "unread" and .host == $h)] | last // null' \
          "$QUEUE_FILE")"
      fi

      if [ "$ENTRY" = "null" ] || [ -z "$ENTRY" ]; then
        if [ -n "$target_id" ]; then
          notify "notify-jump: id '$target_id' não encontrado"
        else
          notify "notify-jump: fila vazia"
        fi
        exit 0
      fi

      ID="$(echo         "$ENTRY" | jq -r .id)"
      SESSION="$(echo    "$ENTRY" | jq -r .session)"
      WINDOW_IDX="$(echo "$ENTRY" | jq -r .window_idx)"
      PANE="$(echo       "$ENTRY" | jq -r .pane)"

      if ! tmux has-session -t "=$SESSION" 2>/dev/null; then
        mark_status "$ID" "dead"
        notify "notify-jump: session '$SESSION' morreu"
        exit 0
      fi

      if ! tmux select-window -t "=$SESSION:$WINDOW_IDX" 2>/dev/null; then
        mark_status "$ID" "dead"
        notify "notify-jump: window $SESSION:$WINDOW_IDX morreu"
        exit 0
      fi

      tmux switch-client -t "=$SESSION"
      tmux select-pane   -t "=$SESSION:$WINDOW_IDX.$PANE" 2>/dev/null || true
      mark_status "$ID" "read"
    ) 9>"$LOCK_FILE"
  '';
}
