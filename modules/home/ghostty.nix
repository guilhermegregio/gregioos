{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      # Some macOS settings
      window-theme = "dark";
      macos-option-as-alt = true;
      window-decoration = "none";

      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "notify,no-bell";
      notify-on-command-finish-after = "10s";

      # Disables ligatures
      # font-feature = ["-liga" "-dlig" "-calt"];
    };
  };
}
