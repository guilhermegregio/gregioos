{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    # No macOS o Ghostty vem do cask (modules/darwin/homebrew.nix) e o pacote
    # do nixpkgs não builda para darwin. `package = null` é o caso previsto
    # pelo módulo: escreve a config sem instalar o binário.
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
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
