{ pkgs, host, ... }:
let inherit (import ../../hosts/${host}/variables.nix) terminal;
in {
  imports = [ ./homebrew.nix ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = terminal;
  };

  programs.zsh.enable = true;

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    # pam_reattach: sem isso o Touch ID não chega dentro do multiplexer (herdr)
    reattach = true;
  };

  services = {
    # substitui o brew `borders` do felixkratz/formulae
    jankyborders = {
      enable = true;
      active_color = "0xffe1e3e4";
      inactive_color = "0xff494d64";
      width = 10.0;
    };

    # FIXME: problemas de driver
    karabiner-elements.enable = false;
    sketchybar = {
      enable = false;
      extraPackages = with pkgs; [ jq gh ];
    };
  };

  networking = {
    knownNetworkServices = [ "Wi-Fi" ];
    dns = [ "9.9.9.9" "1.1.1.1" "8.8.8.8" ];
  };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono sketchybar-app-font ];

  system = {
    stateVersion = 4;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      ".GlobalPreferences"."com.apple.mouse.scaling" = 4.0;
      spaces.spans-displays = false;

      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        orientation = "right";
        dashboard-in-overlay = true;
        largesize = 85;
        tilesize = 50;
        magnification = true;
        launchanim = false;
        mru-spaces = false;
        show-recents = false;
        show-process-indicators = false;
        static-only = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf"; # pasta atual
        QuitMenuItem = true;
      };

      NSGlobalDomain = {
        _HIHideMenuBar = false;
        AppleFontSmoothing = 0;
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        AppleKeyboardUIMode = 3;
        AppleScrollerPagingBehavior = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 10;
        KeyRepeat = 2;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 0.0;
        NSWindowShouldDragOnGesture = true;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.trackpad.scaling" = 2.0;
      };
    };
  };
}
