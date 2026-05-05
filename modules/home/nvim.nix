{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    gcc
    gnumake
    unzip
    tree-sitter
    luajit
    python3
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  home.activation.linkNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NVIM_SRC="${config.home.homeDirectory}/gregioos/modules/home/nvim"
    NVIM_DST="${config.xdg.configHome}/nvim"
    run mkdir -p "${config.xdg.configHome}"
    if [ -e "$NVIM_DST" ] && [ ! -L "$NVIM_DST" ]; then
      run rm -rf "$NVIM_DST"
    fi
    run ln -snf "$NVIM_SRC" "$NVIM_DST"
  '';
}
