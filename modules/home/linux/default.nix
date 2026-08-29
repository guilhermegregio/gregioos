# Só NixOS. dconf e stylix dependem do GNOME; zed e obs vêm de cask no macOS.
{ ... }: {
  imports = [
    ./dconf.nix
    ./stylix.nix
    ./zed.nix
    ./obs-studio.nix
  ];
}
