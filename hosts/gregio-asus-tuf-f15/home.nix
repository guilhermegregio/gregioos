{
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (import ./variables.nix) gitUsername gitEmail stateVersion;
in
{
  # Home Manager Settings
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";
  home.stateVersion = stateVersion;

  # Import Program Configurations
  imports = [
    ../../home/default.nix
  ];

  # catppuccin = {
  #   enable = true;
  #   flavor = "mocha";
  #   accent = "blue";
  # };

  # sessionPath = [
  #   # "$HOME/go/bin"
  #   "$HOME/.local/bin"
  #   # "$HOME/.cargo/bin"
  #   # "$HOME/.krew/bin"
  # ];

  # sessionVariables = {
  #   EDITOR = "nvim";
  #   VISUAL = "nvim";
  #   NIXPKGS_ALLOW_UNFREE = "1";
  # };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    fastfetch.enable = true;
    gh.enable = true;
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
    home-manager.enable = true;
  };
}
