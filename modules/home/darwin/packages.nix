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
  inherit (pkgs.stdenv.hostPlatform) system;
  herdrPkg = inputs.herdr.packages.${system}.default;

  # O `kb` chama `graphify` por PATH (spawn em cli/kb/src/kb/graphify.js), não
  # o carrega no closure — então os dois precisam estar no mesmo perfil.
  #
  # O graphify é um venv: além do `graphify`, o bin/ traz `python`, `python3`,
  # `python3.13`, `f2py` e os `activate`. Jogar o env inteiro no perfil colide
  # com o `python3` de ../common/nvim.nix (buildEnv aborta o switch). No NixOS
  # isso não aparece porque lá ele vive em environment.systemPackages, um
  # buildEnv separado. Então expomos só os dois binários que interessam — o
  # shebang deles é absoluto para o python do próprio venv, que é justamente o
  # que o `resolvePythonInterp` do kb lê para achar o interpretador do MCP.
  graphifyEnv = inputs.graphify.packages.${system}.default;
  graphifyPkg = pkgs.runCommand "graphify-bin" { } ''
    mkdir -p $out/bin
    ln -s ${graphifyEnv}/bin/graphify $out/bin/graphify
    ln -s ${graphifyEnv}/bin/graphify-mcp $out/bin/graphify-mcp
  '';

  kbPkg = inputs.kb.packages.${system}.default;

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
  cc-review = import ../../scripts/cc-review.nix { inherit pkgs; };
  fd-videos = import ../../scripts/fd-videos.nix { inherit pkgs; };
in {
  home.packages = with pkgs; [
    herdrPkg
    graphifyPkg
    kbPkg
    notify-beep
    notify-jump
    notify-pick
    notify-remove
    claude-notify
    wtree
    cc-review
    fd-videos

    # usados pelos aliases de ../common/zsh.nix
    eza
    fd
    ripgrep

    # core
    openssl
    wget
    jq
    yq

    # segredos — editar secrets/*.yaml sem `nix shell`
    sops
    ssh-to-age

    # dotfiles — o install.sh do repo ~/code/dotfiles depende dele
    stow

    # git e github
    gh-dash
    tig
    lazygit

    # utilitários
    bat
    television
    yazi
    cookiecutter
    httpie

    # O cliente docker NÃO entra aqui: quem o fornece é o Docker Desktop, em
    # /usr/local/bin (contexto ativo `desktop-linux`, verificado em 2026-08-29).
    # O `docker` que aparece no closure é dependência interna do colima e nunca
    # esteve no PATH — declará-lo aqui sombrearia o binário do Desktop.
    colima
  ];
}
