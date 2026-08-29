# Só NixOS. dconf e stylix dependem do GNOME; zed e obs vêm de cask no macOS,
# e o terminal de lá é o ghostty, não o kitty.
{ ... }: {
  imports = [
    ./dconf.nix
    ./stylix.nix
    ./kitty.nix
    ./zed.nix
    ./obs-studio.nix
  ];
}
