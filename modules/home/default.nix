{ ... }: {
  imports = [
    ./bash.nix
    ./btop.nix
    ./direnv.nix
    ./fastfetch.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./starship.nix
    ./stylix.nix
    ./zsh.nix
    # Terminals
    ./kitty.nix
    ./wezterm.nix
    ./ghostty.nix
  ];
}
