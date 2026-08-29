# Camada home-manager exclusiva do macOS. O que vale nas três máquinas mora em
# modules/home/common (fase 3 do plano).
{ lib, osConfig, ... }:
let
  # Só o host de trabalho declara este template. `osConfig` (não `config`) é o
  # caminho para a config do sistema: dentro de um módulo home-manager, `config`
  # é o do próprio home-manager e não tem `sops`. O `or null` deixa o Mac
  # pessoal avaliar sem o template, em vez de quebrar.
  devEnv = osConfig.sops.templates."dev-env".path or null;
in {
  imports = [ ./nh.nix ./packages.nix ];

  home.file = {
    # aerospace substituiu o yabai/skhd; os dois saíram do config.
    ".aerospace.toml".source = ./aerospace.toml;
    ".config/herdr/config.toml".source = ./herdr-config.toml;
  };

  # `-r` em vez de `-f`: se a decriptação não rodou, o shell não fica barulhento.
  programs.zsh.initContent = lib.optionalString (devEnv != null) ''
    [ -r ${devEnv} ] && source ${devEnv}
  '';
}
