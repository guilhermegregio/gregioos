# O terminal: pacote e integrações aqui; a config vem do dotfiles
# (`ghostty/.config/ghostty/config`, via stow).
#
# Sem `settings`, o módulo não escreve `~/.config/ghostty/config`.
{ pkgs, ... }: {
  programs.ghostty = {
    enable = true;
    # No macOS o Ghostty vem do cask (modules/darwin/homebrew.nix) e o pacote
    # do nixpkgs não builda para darwin. `package = null` é o caso previsto
    # pelo módulo: mantém as integrações sem instalar o binário.
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
  };
}
