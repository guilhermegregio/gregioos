{ config, lib, pkgs, ... }: {
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.packages = with pkgs; [
    gcc
    gnumake
    unzip
    tree-sitter
    luajit
    python3
  ];

  home.activation.linkNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    NVIM_SRC="${config.home.homeDirectory}/gregioos/modules/home/nvim"
    NVIM_DST="${config.xdg.configHome}/nvim"
    if [ -e "$NVIM_DST" ] && [ ! -L "$NVIM_DST" ]; then
      run echo "skip: $NVIM_DST exists and is not a symlink"
    else
      run mkdir -p "${config.xdg.configHome}"
      run ln -snf "$NVIM_SRC" "$NVIM_DST"
    fi
  '';
}
