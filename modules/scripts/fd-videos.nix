{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellApplication {
  name = "fd-videos";

  runtimeInputs = with pkgs; [
    bash
    fd
    fzf
    ffmpeg
    ffmpegthumbnailer
    chafa
    coreutils
  ];

  text = ''
    DIR="''${1:-.}"

    if [[ ! -d "$DIR" ]]; then
      echo "fd-videos: '$DIR' nao e um diretorio" >&2
      exit 2
    fi

    THUMB_DIR=$(mktemp -d -t fd-videos.XXXXXX)
    trap 'rm -rf "$THUMB_DIR"' EXIT

    fd --no-ignore --hidden -e mp4 -e mov -e mkv -e webm -e avi -e m4v . "$DIR" | \
      fzf --preview "ffmpegthumbnailer -i {} -o $THUMB_DIR/thumb.png -s 400 2>/dev/null && chafa $THUMB_DIR/thumb.png" \
          --preview-window 'right:60%' \
          --bind 'enter:execute(ffplay -autoexit -loop 0 -window_title {} {})'
  '';
}
