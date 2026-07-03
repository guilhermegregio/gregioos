{ pkgs, inputs, ... }:
let
  herdrPkg = inputs.herdr.packages.x86_64-linux.default;
  graphifyPkg = inputs.graphify.packages.x86_64-linux.default;
  kbPkg = inputs.kb.packages.x86_64-linux.default;
  notify-beep = import ../scripts/notify-beep.nix { inherit pkgs; herdr = herdrPkg; };
  notify-jump = import ../scripts/notify-jump.nix { inherit pkgs; herdr = herdrPkg; };
  notify-pick = import ../scripts/notify-pick.nix { inherit pkgs; herdr = herdrPkg; };
  notify-remove = import ../scripts/notify-remove.nix { inherit pkgs; };
  claude-notify = import ../scripts/claude-notify.nix { inherit pkgs; };
  wtree = import ../scripts/wtree.nix { inherit pkgs; };
  fd-videos = import ../scripts/fd-videos.nix { inherit pkgs; };
in {
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
    lazygit
    gh-dash
    bat
    nh
    cloudflared
    infisical
    ripgrep
    ffmpeg
    glow
    xclip
    fd
    lsof
    imagemagick
    pdftk
    gnumake42
    jq
    yq
    httpie
    television
    notify-beep
    notify-jump
    notify-pick
    notify-remove
    claude-notify
    wtree
    fd-videos
    steam-run

    postgresql_15

    uv

    nodejs_24
    pnpm
    biome
    flyctl
    supabase-cli

    ghostty

    zed-editor
    vscode

    # Playwright com browsers inclusos
    # auto-patchelf
    # playwright-driver
    # playwright-driver.browsers

    brave
    chromium
    inputs.zen-browser.packages.x86_64-linux.default
    herdrPkg
    graphifyPkg
    kbPkg
    obsidian

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
