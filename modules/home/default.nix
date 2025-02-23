{ ... }: {
  imports = [
    ./btop.nix
    ./direnv.nix
    ./fastfetch.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./starship.nix
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
  ];
}
