# O editor: pacote, toolchain de build dos plugins e as variáveis. A config
# vem do dotfiles (`nvim/.config/nvim/`, via stow).
#
# Antes daqui havia um `home.activation` que linkava ~/.config/nvim para o
# working tree do gregioos — a mesma ideia do stow, feita à mão para escapar do
# store read-only. Agora o stow faz isso, e o lazy-lock.json fica versionado
# junto de quem o escreve.
{ pkgs, ... }: {
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
}
