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

    list_mode=false
    if [ "''${1:-}" = "--list" ]; then
      list_mode=true
    fi

    notify() {
      if [ -n "''${TMUX:-}" ]; then
        tmux display-message "$1"
      else
        echo "$1" >&2
      fi
    }

    # Gera o TSV: <id>\t<linha formatada>
    # Agrupa entries por (session, window_idx, pane) e mostra a mais
    # recente como representante; status do grupo é o "pior" (unread > read > dead).
    gen_list() {
      if [ ! -s "$QUEUE_FILE" ]; then
        return 0
      fi
      local host
      host="$(hostname)"

      jq -s -r --arg h "$host" '
        [.[] | select(.host == $h)]
        | group_by([.session, .window_idx, .pane])
        | map(
            . as $group
            | (sort_by(.ts) | reverse | .[0]) as $latest
            | $latest + {
                _count: ($group | length),
                _group_status: (
                  if   ($group | any(.status == "unread")) then "unread"
                  elif ($group | any(.status == "read"))   then "read"
                  else                                          "dead"
                  end
                )
              }
          )
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
            if   ._group_status == "unread" then "🔴"
            elif ._group_status == "read"   then "👀"
            else                                 "💀"
            end
          ) as $icon
        | (if ._count > 1 then "(\(._count)) " else "    " end) as $count_str
        | "\(.id)\t\($icon) \($rel_pad)  \(.session):\(.window_idx).\(.pane)  \($count_str)\(.title) — \(.message)"
      ' "$QUEUE_FILE"
    }

    if $list_mode; then
      gen_list
      exit 0
    fi

    if [ ! -s "$QUEUE_FILE" ]; then
      notify "notify-pick: fila vazia"
      exit 0
    fi

    INITIAL="$(gen_list)"
    if [ -z "$INITIAL" ]; then
      notify "notify-pick: nenhuma notificação para $(hostname)"
      exit 0
    fi

    printf '%s\n' "$INITIAL" | fzf \
      --delimiter=$'\t' \
      --with-nth=2.. \
      --no-sort \
      --ansi \
      --prompt='🔔  ' \
      --header='enter: ir · ctrl-x: remover grupo · ctrl-a: limpar tudo · esc: cancelar' \
      --bind 'ctrl-x:execute-silent(notify-remove --id {1} --group)+reload(notify-pick --list)' \
      --bind 'ctrl-a:execute-silent(notify-remove --all)+reload(notify-pick --list)' \
      --bind 'enter:become(notify-jump --id {1})'
  '';
}
