{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      window-theme = "dark";
      macos-option-as-alt = true;
      window-decoration = "none";

      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "notify,no-bell";
      notify-on-command-finish-after = "10s";

      bell-features = "audio,system,attention";

      font-family = "JetBrainsMono Nerd Font Mono";
      font-size = 15;
      font-feature = [ "-liga" "-dlig" "-calt" ];

      theme = "Catppuccin Mocha";
      background-opacity = 0.95;
    };
  };
}
