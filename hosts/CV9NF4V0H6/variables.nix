{
  gitUsername = "Guilherme Gregio";
  gitEmail = "guilherme.gregio@stone.com.br";

  browser = "arc";
  terminal = "ghostty";

  # nix-darwin não tem system.stateVersion versionado como o NixOS (usa 4,
  # fixado em modules/darwin). Aqui só o contrato do home-manager, que veio
  # do dotfiles e não deve subir sem inspeção.
  homeStateVersion = "24.05";
}
