{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      # Some macOS settings
      window-theme = "dark";
      macos-option-as-alt = true;
      window-decoration = "none";

      # Disables ligatures
      # font-feature = ["-liga" "-dlig" "-calt"];
    };
  };
}
