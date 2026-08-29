# Camada home-manager exclusiva do macOS. O que vale nas três máquinas mora em
# modules/home/common (fase 3 do plano).
{ ... }: {
  imports = [ ./nh.nix ];

  home.file = {
    # aerospace substituiu o yabai/skhd; os dois saíram do config.
    ".aerospace.toml".source = ./aerospace.toml;
    ".config/herdr/config.toml".source = ./herdr-config.toml;
  };
}
