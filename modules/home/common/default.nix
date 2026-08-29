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
    ./ghostty.nix
    # shells
    ./bash.nix
    ./zsh.nix
    ./nushell.nix
    # editors
    ./nvim.nix
  ];
}
