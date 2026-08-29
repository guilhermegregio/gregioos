# O prompt: o pacote e a integração com o shell ficam aqui; o VISUAL vem do
# dotfiles (`starship/.config/starship.toml`, via stow).
#
# Sem `settings`, o home-manager não gera `~/.config/starship.toml`
# (`hasGeneratedConfig` no módulo upstream) mas mantém o `zsh.initContent` que
# inicializa o prompt — que é exatamente a divisão que queremos: o nix cuida do
# binário e do wiring, o dotfiles cuida do que se edita.
{ ... }: {
  programs.starship.enable = true;
}
