{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "notify-beep";

  runtimeInputs = with pkgs; [
    bash
    nodejs
    curl
    jq
    inetutils
    coreutils
  ];

  text = ''
    DISCORD_WEBHOOK="https://discord.com/api/webhooks/1418606826433417246/tA2FTwsR5v-MWgRIyiKwJRbRHuK31X_rqggEttTNXi1-k5rIhaW8BpVdOR1SQqdzctle"

    do_beep=true
    do_discord=true

    case "''${1:-}" in
      --only-beep)    do_discord=false; shift ;;
      --only-discord) do_beep=false;    shift ;;
      --help|-h)
        echo "uso: notify-beep [--only-beep|--only-discord] [mensagem...]"
        exit 0
        ;;
      --*)
        echo "notify-beep: flag desconhecida: $1" >&2
        echo "uso: notify-beep [--only-beep|--only-discord] [mensagem...]" >&2
        exit 2
        ;;
    esac

    MESSAGE="''${*:-🔔 Notificação do Claude Code}"

    if $do_beep; then
      node -e "console.log('\007')"
      echo "$MESSAGE"
    fi

    if $do_discord; then
      payload=$(jq -n \
        --arg msg "$MESSAGE" \
        --arg host "$(hostname)" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{content:"🤖 **Claude Code**", embeds:[{description:$msg, color:5814783, timestamp:$ts, footer:{text:$host}}]}')
      curl -s -X POST "$DISCORD_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "$payload" >/dev/null 2>&1 &
    fi
  '';
}
