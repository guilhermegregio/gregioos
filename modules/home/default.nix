{ ... }: {
  imports = [
    ./btop.nix
    ./direnv.nix
    ./fastfetch.nix
    ./fzf.nix
    ./gh.nix
    ./zoxide.nix
    ./git.nix
    ./starship.nix
    ./dconf.nix
    ./stylix.nix
    # Terminals
    ./kitty.nix
    ./wezterm.nix
    ./ghostty.nix
    # shells
    ./bash.nix
    ./zsh.nix
    ./nushell.nix
    # terminal multiplexer
    ./zellij.nix
    # editors
    ./helix.nix
    ./zed.nix
  ];
}
