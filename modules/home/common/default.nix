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
    ./nixpkgs.nix
    ./sops.nix
    # Terminals
    ./wezterm.nix
    ./ghostty.nix
    # shells
    ./bash.nix
    ./zsh.nix
    ./nushell.nix
    # terminal multiplexer
    ./zellij.nix
    ./tmux.nix
    # editors
    ./helix.nix
    ./nvim.nix
  ];
}
