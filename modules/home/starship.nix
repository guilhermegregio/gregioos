{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    package = pkgs.starship;

    settings = {
      add_newline = false;
    };
  };
}
