# Casks e brews comuns aos dois Macs. O que for de trabalho (toolchain mobile,
# apps corporativos) mora em hosts/CV9NF4V0H6/default.nix — homebrew.casks e
# homebrew.brews são listas, então cada host só acrescenta à sua.
{ ... }: {
  homebrew = {
    enable = true;
    global.autoUpdate = false;

    masApps = { };

    onActivation = {
      # "zap" remove brews e casks instalados na mão
      cleanup = "zap";
      autoUpdate = false;
      upgrade = false;
    };

    casks = [
      # produtividade
      "nikitabobko/tap/aerospace"
      "raycast"

      # código
      "zed"
      "dbeaver-community"

      # browsers
      "arc"
      "zen"
      "google-chrome"

      # terminais
      "ghostty"

      # utilitários
      "sf-symbols"
      "docker-desktop"
      "obs"
    ];
  };
}
