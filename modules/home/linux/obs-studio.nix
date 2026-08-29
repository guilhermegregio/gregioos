{ pkgs, ... }:
let
  # FIXME(nixpkgs 26.11): o move-transition não compila com o GCC desta
  # release — o CMakeLists do plugin usa -Werror e o compilador novo acusa
  # warnings que antes não existiam. O override só desliga o -Werror; quando
  # o nixpkgs corrigir upstream, é para remover isto e voltar ao plugin puro.
  obs-move-transition =
    pkgs.obs-studio-plugins.obs-move-transition.overrideAttrs (old: {
      env = (old.env or { }) // {
        NIX_CFLAGS_COMPILE =
          (old.env.NIX_CFLAGS_COMPILE or "") + " -Wno-error";
      };
    });
in {
  programs.obs-studio = {
    enable = true;
    plugins = (with pkgs.obs-studio-plugins; [
      obs-vertical-canvas
      obs-aitum-multistream
      obs-backgroundremoval
      obs-source-record
      obs-pipewire-audio-capture
      obs-advanced-masks
      obs-source-clone
      obs-stroke-glow-shadow
      obs-3d-effect
    ]) ++ [ obs-move-transition ];
  };
}
