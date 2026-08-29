{ pkgs ? import <nixpkgs> {}, herdr ? null }:

let
  platformInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.sound-theme-freedesktop # bell.oga
  ] ++ pkgs.lib.optionals (herdr != null) [ herdr ];

  # Som tocado quando do_beep está ativo (Linux). No Mac usa afplay direto.
  bellSoundLinux =
    if pkgs.stdenv.hostPlatform.isLinux
    then "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/bell.oga"
    else "";
in
pkgs.writeShellApplication {
  name = "notify-beep";

  runtimeInputs = with pkgs; [
    bash
    nodejs
    jq
  ] ++ platformInputs;

  text = ''
    NTFY_TOPIC="alertas_gregio_cc"

    do_beep=true
    do_ntfy=true
    do_echo=true
    do_queue=false
    custom_title=""
    sound_hint="done"

    usage() {
      cat <<EOF
uso: notify-beep [flags] [mensagem...]

flags (todas combináveis):
  --title TXT  título da notificação (default: "Claude Code")
  --sound S    hint de som pro toast nativo do herdr: done|request (default: done)
  --no-beep    desabilita o som local
  --no-ntfy    desabilita o push pro ntfy.sh
  --queue      enfileira o alerta em ~/.local/state/notify-beep/queue.jsonl
               para uso com notify-jump (prefix+Space no tmux/herdr)
  -h, --help   mostra esta ajuda

o contexto (tmux/zellij/herdr/cmux) e o hostname são anexados no body da
notificação, não no título.

exemplo:
  notify-beep --queue --title "🔔 🤖 Claude Code - permission" "preciso de aprovação"
EOF
    }

    while [[ "''${1:-}" == --* || "''${1:-}" == -h ]]; do
      case "$1" in
        --title)   custom_title="''${2:-}"; shift 2 ;;
        --title=*) custom_title="''${1#--title=}"; shift ;;
        --sound)   sound_hint="''${2:-}"; shift 2 ;;
        --sound=*) sound_hint="''${1#--sound=}"; shift ;;
        --no-beep) do_beep=false; shift ;;
        --no-ntfy) do_ntfy=false; shift ;;
        --queue)   do_queue=true; shift ;;
        --help|-h) usage; exit 0 ;;
        --)        shift; break ;;
        *)
          echo "notify-beep: flag desconhecida: $1" >&2
          usage >&2
          exit 2
          ;;
      esac
    done

    MESSAGE="''${*:-🔔 Notificação do Claude Code}"

    PLATFORM="$(uname -s)"

    # --- Contexto do multiplexador de terminal ---
    CONTEXT=""

    TMUX_SESSION=""
    TMUX_WINDOW=""
    TMUX_WINDOW_IDX=""
    TMUX_PANE_IDX=""

    HERDR_TERMINAL_ID=""
    HERDR_WORKSPACE_ID=""
    HERDR_TAB_ID=""
    HERDR_COMPACT_PANE_ID=""
    HERDR_WS_LABEL=""
    HERDR_TAB_LABEL=""

    if [ -n "''${TMUX:-}" ] && command -v tmux > /dev/null 2>&1; then
      TMUX_SESSION="$(tmux display-message -p '#S')"
      TMUX_WINDOW="$(tmux display-message -p '#W')"
      TMUX_WINDOW_IDX="$(tmux display-message -p '#I')"
      TMUX_PANE_IDX="$(tmux display-message -p '#P')"
      CONTEXT="tmux · sessão: $TMUX_SESSION · janela: $TMUX_WINDOW · painel: $TMUX_PANE_IDX"
    elif [ -n "''${ZELLIJ:-}" ]; then
      ZELLIJ_TAB=""
      if command -v zellij > /dev/null 2>&1; then
        ZELLIJ_TAB="$(zellij action current-tab-info 2>/dev/null \
          | sed 's/.*name: "\([^"]*\)".*/\1/')"
      fi
      CONTEXT="zellij · sessão: ''${ZELLIJ_SESSION_NAME:-} · aba: $ZELLIJ_TAB · painel: ''${ZELLIJ_PANE_ID:-}"
    elif [ "''${HERDR_ENV:-}" = "1" ] && command -v herdr > /dev/null 2>&1; then
      HERDR_PANE_JSON="$(herdr pane get "''${HERDR_PANE_ID:-}" 2>/dev/null \
        | jq -c '.result.pane // empty' || true)"
      if [ -n "$HERDR_PANE_JSON" ]; then
        HERDR_TERMINAL_ID="$(jq -r '.terminal_id // ""' <<<"$HERDR_PANE_JSON")"
        HERDR_WORKSPACE_ID="$(jq -r '.workspace_id // ""' <<<"$HERDR_PANE_JSON")"
        HERDR_TAB_ID="$(jq -r '.tab_id // ""' <<<"$HERDR_PANE_JSON")"
        HERDR_COMPACT_PANE_ID="$(jq -r '.pane_id // ""' <<<"$HERDR_PANE_JSON")"
        HERDR_WS_LABEL="$(herdr workspace list 2>/dev/null \
          | jq -r --arg w "$HERDR_WORKSPACE_ID" \
              '.result.workspaces[] | select(.workspace_id == $w) | .label // ""' || true)"
        HERDR_TAB_LABEL="$(herdr tab list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
          | jq -r --arg t "$HERDR_TAB_ID" \
              '.result.tabs[] | select(.tab_id == $t) | .label // ""' || true)"
        CONTEXT="herdr · workspace: ''${HERDR_WS_LABEL:-?} · tab: ''${HERDR_TAB_LABEL:-?}"
      fi
    elif [ -n "''${CMUX_WORKSPACE_ID:-}" ]; then
      CONTEXT="cmux · workspace: $CMUX_WORKSPACE_ID · surface: ''${CMUX_SURFACE_ID:-?}"
    fi

    TITLE="''${custom_title:-Claude Code}"

    # --- Toast nativo do herdr ---
    # Substitui o som local quando dentro do herdr: o toast aparece na UI
    # (prefix+o salta pro pane de origem) e toca o som done/request.
    herdr_toast_ok=false
    if [ -n "$HERDR_TERMINAL_ID" ]; then
      toast_sound="$sound_hint"
      $do_beep || toast_sound="none"
      if herdr notification show "$TITLE" --body "$MESSAGE" \
           --sound "$toast_sound" > /dev/null 2>&1; then
        herdr_toast_ok=true
      fi
    fi

    # --- Beep (som local) ---
    if $do_beep && ! $herdr_toast_ok; then
      if [ "$PLATFORM" = "Darwin" ]; then
        afplay /System/Library/Sounds/Basso.aiff &
      elif command -v pw-play > /dev/null 2>&1; then
        pw-play '${bellSoundLinux}' &
      elif command -v paplay > /dev/null 2>&1; then
        paplay '${bellSoundLinux}' &
      else
        node -e 'process.stdout.write("\007")' || true
      fi
    fi

    # --- ntfy.sh ---
    # Usa a API JSON (em vez de headers HTTP) porque headers só aceitam
    # ByteString — emojis e UTF-8 fora de latin-1 quebram o fetch do Node.
    if $do_ntfy; then
      NTFY_BODY="$MESSAGE"
      if [ -n "$CONTEXT" ]; then
        NTFY_BODY="$NTFY_BODY"$'\n\n'"📍 $CONTEXT"
      fi
      NTFY_BODY="$NTFY_BODY"$'\n'"🏠 $(hostname)"

      NTFY_TOPIC="$NTFY_TOPIC" NTFY_BODY="$NTFY_BODY" TITLE="$TITLE" node -e "
        fetch('https://ntfy.sh/', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            topic: process.env.NTFY_TOPIC,
            title: process.env.TITLE,
            message: process.env.NTFY_BODY,
            tags: ['bell', 'robot'],
            priority: 3,
            markdown: true,
          }),
        }).then(r => process.exit(r.ok ? 0 : 1));
      " &
    fi

    # --- Fila persistente (opt-in via --queue) ---
    if $do_queue && { [ -n "''${TMUX:-}" ] || [ -n "$HERDR_TERMINAL_ID" ]; }; then
      QUEUE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/notify-beep"
      mkdir -p "$QUEUE_DIR"
      QUEUE_FILE="$QUEUE_DIR/queue.jsonl"

      ENTRY_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
      ENTRY_HOST="$(hostname)"
      ENTRY_ID="$(date +%s%N)-$$"

      if [ -n "''${TMUX:-}" ]; then
        jq -c -n \
          --arg id          "$ENTRY_ID" \
          --arg ts          "$ENTRY_TS" \
          --arg host        "$ENTRY_HOST" \
          --arg session     "$TMUX_SESSION" \
          --arg window      "$TMUX_WINDOW" \
          --arg window_idx  "$TMUX_WINDOW_IDX" \
          --arg pane        "$TMUX_PANE_IDX" \
          --arg title       "$TITLE" \
          --arg message     "$MESSAGE" \
          '{
            id: $id,
            ts: $ts,
            host: $host,
            mux: "tmux",
            session: $session,
            window: $window,
            window_idx: ($window_idx | tonumber),
            pane: ($pane | tonumber),
            title: $title,
            message: $message,
            status: "unread"
          }' >> "$QUEUE_FILE"
      else
        # herdr: terminal_id é o handle durável; pane_id compacto é só hint
        # (ids compactos mudam quando panes fecham — notify-jump re-resolve).
        jq -c -n \
          --arg id              "$ENTRY_ID" \
          --arg ts              "$ENTRY_TS" \
          --arg host            "$ENTRY_HOST" \
          --arg terminal_id     "$HERDR_TERMINAL_ID" \
          --arg workspace_id    "$HERDR_WORKSPACE_ID" \
          --arg tab_id          "$HERDR_TAB_ID" \
          --arg pane_id         "$HERDR_COMPACT_PANE_ID" \
          --arg workspace_label "$HERDR_WS_LABEL" \
          --arg tab_label       "$HERDR_TAB_LABEL" \
          --arg title           "$TITLE" \
          --arg message         "$MESSAGE" \
          '{
            id: $id,
            ts: $ts,
            host: $host,
            mux: "herdr",
            terminal_id: $terminal_id,
            workspace_id: $workspace_id,
            tab_id: $tab_id,
            pane_id: $pane_id,
            workspace_label: $workspace_label,
            tab_label: $tab_label,
            title: $title,
            message: $message,
            status: "unread"
          }' >> "$QUEUE_FILE"
      fi
    fi

    if $do_echo; then
      echo "$MESSAGE"
      if [ -n "$CONTEXT" ]; then
        echo "  ↳ $CONTEXT"
      fi
    fi
  '';
}
