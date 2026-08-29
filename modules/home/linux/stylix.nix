# Centraliza os alvos do stylix que ficam desligados. Os módulos em ../common
# não podem declarar `stylix.*`: a opção não existe no macOS e o eval quebra.
{ ... }: {
  stylix.targets.waybar.enable = false;
  stylix.targets.rofi.enable = false;
  stylix.targets.hyprland.enable = false;
  stylix.targets.hyprlock.enable = false;
  stylix.targets.zed.enable = false;
  stylix.targets.ghostty.enable = false;
  stylix.targets.neovim.enable = false;
}
