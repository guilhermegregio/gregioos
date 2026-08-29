{ pkgs, host, ... }:
let inherit (import ../../hosts/${host}/variables.nix) systemStateVersion;
in {
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  environment.variables = {
    GREGIOOS_VERSION = "1.0";
    GREGIOOS = "true";
    EDITOR = "nvim";
    VISUAL = "nvim";
    GIT_EDITOR = "nvim";
    # Playwright
    PLAYWRIGHT_BROWSERS_PATH =
      "/nix/store/vq93n2wh2s3jb8x7wn29gvd1k0nd1l71-playwright-browsers";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
    # PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    # Puppeteer
    # PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "1";
    # PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
    LESS = "-g -i -M -R -S -w -X";
  };

  qt.platformTheme = "gnome";

  console.useXkbConfig = true;

  # Permite rodar binários genéricos não-Nix (ex: Chromium baixado pelo
  # Playwright para CLIs como notebooklm-py) resolvendo as libs dinâmicas
  # via Nix em vez de depender de um /lib FHS que o NixOS não tem.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      zlib
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxscrnsaver
      libxtst
    ];
  };

  system.stateVersion = systemStateVersion;
}
