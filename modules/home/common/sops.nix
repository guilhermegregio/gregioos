# Onde o CLI do sops acha a identidade para editar `secrets/*.yaml`.
#
# Precisa ser a identidade **age X25519** (`AGE-SECRET-KEY-1…`) derivada da
# chave SSH por `ssh-to-age -private-key`, não a chave SSH em si. Os recipients
# do `.sops.yaml` são `age1…`, produzidos pelo `ssh-to-age`; já uma chave SSH é
# lida pelo sops com `agessh`, o esquema SSH nativo do age — identidade de
# outro tipo, que não decripta esses recipients e falha com
# "no identity matched any of the recipients".
#
# A variável é declarada explicitamente porque o default do sops é
# `<os.UserConfigDir()>/sops/age/keys.txt`, e no macOS isso é
# `~/Library/Application Support`, não `~/.config`.
#
# O `keys.txt` é gerado na máquina e nunca versionado — ver docs/segredos-sops.md.
# A ativação do sistema não depende disto: lá quem decripta é o módulo do
# sops-nix, via `sops.age.sshKeyPaths`, que faz a conversão internamente.
{ config, ... }: {
  home.sessionVariables.SOPS_AGE_KEY_FILE =
    "${config.home.homeDirectory}/.config/sops/age/keys.txt";
}
