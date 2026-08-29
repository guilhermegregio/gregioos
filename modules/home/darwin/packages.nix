# CLIs do dia a dia no macOS.
#
# No NixOS estes vêm de modules/core/packages.nix, no nível do sistema — por
# isso não estão em ../common. O macOS não tem esse equivalente, então sem este
# módulo a migração do dotfiles regrediria: os aliases de ../common/zsh.nix
# (`ls`, `ll`, `la`, `ls-env`) dependem de `eza` e `fd`, e o fluxo de trabalho
# depende do `herdr`.
#
# A lista espelha o que o dotfiles@nixpkgs instalava em shell/default.nix. O que
# é específico de mobile/Stone fica em hosts/CV9NF4V0H6.
{ pkgs, inputs, ... }:
let
  # `pkgs.system` está deprecado desde o nixpkgs 25.11.
  herdrPkg = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;

  notify-beep = import ../../scripts/notify-beep.nix {
    inherit pkgs;
    herdr = herdrPkg;
  };
  notify-jump = import ../../scripts/notify-jump.nix {
    inherit pkgs;
    herdr = herdrPkg;
  };
  notify-pick = import ../../scripts/notify-pick.nix {
    inherit pkgs;
    herdr = herdrPkg;
  };
  notify-remove = import ../../scripts/notify-remove.nix { inherit pkgs; };
  claude-notify = import ../../scripts/claude-notify.nix { inherit pkgs; };
  wtree = import ../../scripts/wtree.nix { inherit pkgs; };
in {
  home.packages = with pkgs; [
    herdrPkg
    notify-beep
    notify-jump
    notify-pick
    notify-remove
    claude-notify
    wtree

    # usados pelos aliases de ../common/zsh.nix
    eza
    fd
    ripgrep

    # core
    openssl
    wget
    jq
    yq

    # git e github
    gh-dash
    tig
    lazygit

    # utilitários
    bat
    yazi
    cookiecutter
    httpie
    colima
  ];
}
