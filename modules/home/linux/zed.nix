# O Zed: pacote, LSPs e extensões ficam aqui; `settings.json` e `keymap.json`
# vêm do dotfiles (`zed/.config/zed/`, via stow).
#
# O módulo declarava `userSettings` — e o Zed as ignorava: ele reescreve o
# próprio settings.json ao salvar preferências pela UI. O arquivo em disco era
# real (não symlink), com um `settings.json.backup` ao lado que o
# `backupFileExtension` guardou. Era config morta.
{ pkgs, lib, ... }: {
  home.packages = with pkgs; [ nixd nil nixfmt ];

  programs = {
    zed-editor = {
      enable = true;
      extensions = [
        "nix"
        "toml"
        "make"
        "html"
        "dockerfile"
        "sql"
        "lua"
        "git-firefly"
        "catppuccin"
      ];
    };
  };
}
