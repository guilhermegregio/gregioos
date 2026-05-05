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
    ./nixpkgs.nix
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
    ./tmux.nix
    # editors
    ./helix.nix
    ./zed.nix
    ./nvim.nix
  ];
}
