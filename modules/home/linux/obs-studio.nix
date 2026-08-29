{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vertical-canvas
      obs-aitum-multistream
      obs-backgroundremoval
      obs-source-record
      obs-pipewire-audio-capture
      obs-move-transition
      obs-advanced-masks
      obs-source-clone
      obs-stroke-glow-shadow
      obs-3d-effect
    ];
  };
}
