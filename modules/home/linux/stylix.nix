# Centraliza os alvos do stylix que ficam desligados. Os módulos em ../common
# não podem declarar `stylix.*`: a opção não existe no macOS e o eval quebra.
#
# Duas razões para desligar um alvo aqui:
#   1. o programa não é usado (waybar, rofi, hyprland…)
#   2. a config dele vem do dotfiles via stow — e nesse caso o stylix
#      concorreria pelo mesmo arquivo. O tema fica congelado no arquivo
#      copiado; trocar o esquema do sistema não o repinta sozinho.
{ ... }: {
  # (2) gerenciados pelo dotfiles/stow
  stylix.targets.ghostty.enable = false;
  stylix.targets.starship.enable = false;
  stylix.targets.btop.enable = false;
  stylix.targets.neovim.enable = false;

  # (1) não usados
  stylix.targets.waybar.enable = false;
  stylix.targets.rofi.enable = false;
  stylix.targets.hyprland.enable = false;
  stylix.targets.hyprlock.enable = false;
  stylix.targets.zed.enable = false;
}
