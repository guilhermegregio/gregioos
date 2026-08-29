{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "Guilherme Gregio";
  gitEmail = "guilherme@gregio.net";

  # Hyprland Settings
  extraMonitorSettings = "";

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "zen-browser"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "ghostty"; # Set Default System Terminal

  keyboardLayout = "us";
  consoleKeyMap = "us";

  # Versão do NixOS em que a máquina foi instalada. NÃO atualizar: não traz
  # pacote novo nenhum, só troca defaults de dados stateful (o mecanismo existe
  # justamente para não quebrá-los). Ver a descrição de `system.stateVersion`.
  systemStateVersion = "24.11";

  # Contrato do home-manager, independente do de cima. Em 26.05 os defaults
  # novos valem — entre eles `gtk.gtk4.theme = null` no lugar do legado
  # `config.gtk.theme`.
  homeStateVersion = "26.05";
}
