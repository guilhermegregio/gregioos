{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "notify-pick";

  runtimeInputs = with pkgs; [
    bash
    coreutils
    jq
    fzf
    tmux
  ];

  text = ''
    QUEUE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/notify-beep"
    QUEUE_FILE="$QUEUE_DIR/queue.jsonl"

    notify() {
      if [ -n "''${TMUX:-}" ]; then
        tmux display-message "$1"
      else
        echo "$1" >&2
      fi
    }

    if [ ! -s "$QUEUE_FILE" ]; then
      notify "notify-pick: fila vazia"
      exit 0
    fi

    HOST="$(hostname)"

    # Cada linha: <id>\t<emoji> <rel>  <session>:<win>.<pane>  <title> — <message>
    # Ordenado do mais recente para o mais antigo.
    LINES="$(jq -s -r --arg h "$HOST" '
      map(select(.host == $h))
      | sort_by(.ts) | reverse
      | .[]
      | ((now - (.ts | fromdateiso8601)) | floor) as $diff
      | (
          if   $diff < 60    then "\($diff)s"
          elif $diff < 3600  then "\(($diff/60)|floor)m"
          elif $diff < 86400 then "\(($diff/3600)|floor)h"
          else                    "\(($diff/86400)|floor)d"
          end
        ) as $rel
      | (($rel + "    ")[0:4]) as $rel_pad
      | (
          if   .status == "unread" then "🔴"
          elif .status == "read"   then "👀"
          elif .status == "dead"   then "💀"
          else                          "❔"
          end
        ) as $icon
      | "\(.id)\t\($icon) \($rel_pad)  \(.session):\(.window_idx).\(.pane)  \(.title) — \(.message)"
    ' "$QUEUE_FILE")"

    if [ -z "$LINES" ]; then
      notify "notify-pick: nenhuma notificação para $HOST"
      exit 0
    fi

    SELECTED="$(printf '%s\n' "$LINES" | fzf \
      --delimiter=$'\t' \
      --with-nth=2.. \
      --no-sort \
      --ansi \
      --prompt='🔔  ' \
      --header='enter: ir · esc: cancelar')" || true

    if [ -z "$SELECTED" ]; then
      exit 0
    fi

    SELECTED_ID="''${SELECTED%%$'\t'*}"

    exec notify-jump --id "$SELECTED_ID"
  '';
}
