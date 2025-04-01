{ pkgs, inputs, ... }: {
  programs = { };

  # programs = {
  #   firefox.enable = false;
  #   dconf.enable = true;
  #   seahorse.enable = true;
  #   fuse.userAllowOther = true;
  #   virt-manager.enable = true;
  #   mtr.enable = true;

  #   gnupg.agent = {
  #     enable = true;
  #     enableSSHSupport = true;
  #   };

  #   thunar = {
  #     enable = true;
  #     plugins = with pkgs.xfce; [
  #       thunar-archive-plugin
  #       thunar-volman
  #     ];
  #   };
  # };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    eza
    yazi
    git
    tig
    htop
    bat
    nh
    ngrok
    infisical
    ripgrep
    ffmpeg
    glow
    xclip
    fd
    lsof
    imagemagick
    pdftk

    postgresql_15

    nodejs_24
    pnpm
    biome
    flyctl
    supabase-cli

    ghostty

    zed-editor
    vscode
    neovim

    # Playwright com browsers inclusos
    # auto-patchelf
    # playwright-driver
    # playwright-driver.browsers

    brave
    chromium
    inputs.zen-browser.packages.x86_64-linux.default

    linuxPackages.v4l2loopback
    usbutils
    pciutils
    ddcutil

    obs-studio

    # Fontes essenciais para renderização
    fontconfig
    dejavu_fonts
    freefont_ttf
    noto-fonts
    noto-fonts-color-emoji
  ];

  # environment.systemPackages = with pkgs; [
  #   appimage-run
  #   brave
  #   brightnessctl
  #   cmatrix
  #   cowsay
  #   discord
  #   docker-compose
  #   duf
  #   eza
  #   ffmpeg
  #   file-roller
  #   gedit
  #   gimp
  #   greetd.tuigreet
  #   htop
  #   hyprpicker
  #   imv
  #   inxi
  #   killall
  #   libnotify
  #   libvirt
  #   lm_sensors
  #   lolcat
  #   lshw
  #   lxqt.lxqt-policykit
  #   meson
  #   mpv
  #   ncdu
  #   ninja
  #   nixfmt-rfc-style
  #   obs-studio
  #   pavucontrol
  #   pciutils
  #   pkg-config
  #   playerctl
  #   ripgrep
  #   socat
  #   tree
  #   unrar
  #   unzip
  #   usbutils
  #   v4l-utils
  #   virt-viewer
  #   wget
  # ];
}
