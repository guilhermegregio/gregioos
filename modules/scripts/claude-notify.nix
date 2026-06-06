{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "claude-notify";

  runtimeInputs = with pkgs; [
    bash
    jq
    coreutils
    findutils
  ];

  text = ''
    INPUT="$(cat)"

    EVENT="$(jq -r '.hook_event_name // "Unknown"' <<<"$INPUT")"
    CWD_RAW="$(jq -r '.cwd // ""' <<<"$INPUT")"
    CWD=""
    if [ -n "$CWD_RAW" ]; then
      CWD="$(basename "$CWD_RAW")"
    fi
    LABEL="''${CWD:-Claude}"

    TITLE=""
    BODY=""

    case "$EVENT" in
      Stop)
        ACTIVE="$(jq -r '.stop_hook_active // false' <<<"$INPUT")"
        if [ "$ACTIVE" = "true" ]; then
          exit 0
        fi

        MSG="$(jq -r '.last_assistant_message // "Task completa"' <<<"$INPUT" \
              | tr '\n' ' ' | cut -c1-200)"
        TITLE="✅ [$LABEL] terminou"
        BODY="$MSG"
        ;;

      Notification)
        NTYPE="$(jq -r '.notification_type // ""' <<<"$INPUT")"
        if [ "$NTYPE" = "idle_prompt" ]; then
          exit 0
        fi
        NMSG="$(jq -r '.message // "aguardando aprovação"' <<<"$INPUT")"
        TITLE="⚠️ [$LABEL] permissão"
        BODY="$NMSG"
        ;;

      *)
        exit 0
        ;;
    esac

    notify-beep --queue --title "$TITLE" "$BODY"
  '';
}
