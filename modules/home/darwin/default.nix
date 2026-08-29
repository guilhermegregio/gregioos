# Camada home-manager exclusiva do macOS. O que vale nas três máquinas mora em
# modules/home/common (fase 3 do plano).
{ config, lib, osConfig, ... }:
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

  # Onde o CLI do sops acha a identidade para editar `secrets/*.yaml`.
  #
  # Tem de ser a identidade **age X25519** (`AGE-SECRET-KEY-1…`) derivada da
  # chave SSH por `ssh-to-age -private-key`, e não a chave SSH em si: os
  # recipients do .sops.yaml são `age1…`, produzidos pelo `ssh-to-age`, e o
  # sops lê chave SSH com `agessh`, que é o esquema SSH nativo do age — outro
  # tipo de identidade, que não casa com esses recipients. Apontar
  # SOPS_AGE_SSH_PRIVATE_KEY_FILE para a id_ed25519 falha com
  # "no identity matched any of the recipients".
  #
  # A variável é declarada explicitamente porque o default do sops é
  # `<os.UserConfigDir()>/sops/age/keys.txt` — no macOS,
  # `~/Library/Application Support`, não `~/.config`.
  #
  # O arquivo é gerado na máquina e nunca versionado; ver docs/segredos-sops.md.
  # A ativação do sistema não depende disto: lá quem decripta é o módulo, via
  # `sops.age.sshKeyPaths`, que faz a conversão internamente.
  home.sessionVariables.SOPS_AGE_KEY_FILE =
    "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  # `-r` em vez de `-f`: se a decriptação não rodou, o shell não fica barulhento.
  programs.zsh.initContent = lib.optionalString (devEnv != null) ''
    [ -r ${devEnv} ] && source ${devEnv}
  '';
}
