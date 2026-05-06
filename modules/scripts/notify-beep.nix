{ pkgs ? import <nixpkgs> {} }:

let
  platformInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
    pkgs.sound-theme-freedesktop # bell.oga
  ];

  # Som tocado quando do_beep está ativo (Linux). No Mac usa afplay direto.
  bellSoundLinux =
    if pkgs.stdenv.isLinux
    then "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/bell.oga"
    else "";
in
pkgs.writeShellApplication {
  name = "notify-beep";

  runtimeInputs = with pkgs; [
    bash
    nodejs
  ] ++ platformInputs;

  text = ''
    NTFY_TOPIC="alertas_gregio_cc"

    do_beep=true
    do_ntfy=true
    do_echo=true
    custom_title=""

    usage() {
      cat <<EOF
uso: notify-beep [flags] [mensagem...]

flags (todas combináveis):
  --title TXT  título da notificação (default: "Claude Code")
  --no-beep    desabilita o som local
  --no-ntfy    desabilita o push pro ntfy.sh
  -h, --help   mostra esta ajuda

o contexto (tmux/zellij/cmux) e o hostname são anexados no body da
notificação, não no título.

exemplo:
  notify-beep --title "🔔 🤖 Claude Code - permission" "preciso de aprovação"
EOF
    }

    while [[ "''${1:-}" == --* || "''${1:-}" == -h ]]; do
      case "$1" in
        --title)   custom_title="''${2:-}"; shift 2 ;;
        --title=*) custom_title="''${1#--title=}"; shift ;;
        --no-beep) do_beep=false; shift ;;
        --no-ntfy) do_ntfy=false; shift ;;
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

    if [ -n "''${TMUX:-}" ] && command -v tmux > /dev/null 2>&1; then
      TMUX_SESSION="$(tmux display-message -p '#S')"
      TMUX_WINDOW="$(tmux display-message -p '#W')"
      TMUX_PANE_IDX="$(tmux display-message -p '#P')"
      CONTEXT="tmux · sessão: $TMUX_SESSION · janela: $TMUX_WINDOW · painel: $TMUX_PANE_IDX"
    elif [ -n "''${ZELLIJ:-}" ]; then
      ZELLIJ_TAB=""
      if command -v zellij > /dev/null 2>&1; then
        ZELLIJ_TAB="$(zellij action current-tab-info 2>/dev/null \
          | sed 's/.*name: "\([^"]*\)".*/\1/')"
      fi
      CONTEXT="zellij · sessão: ''${ZELLIJ_SESSION_NAME:-} · aba: $ZELLIJ_TAB · painel: ''${ZELLIJ_PANE_ID:-}"
    elif [ -n "''${CMUX_WORKSPACE_ID:-}" ]; then
      CONTEXT="cmux · workspace: $CMUX_WORKSPACE_ID · surface: ''${CMUX_SURFACE_ID:-?}"
    fi

    TITLE="''${custom_title:-Claude Code}"

    # --- Beep (som local) ---
    if $do_beep; then
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

    if $do_echo; then
      echo "$MESSAGE"
      if [ -n "$CONTEXT" ]; then
        echo "  ↳ $CONTEXT"
      fi
    fi
  '';
}
