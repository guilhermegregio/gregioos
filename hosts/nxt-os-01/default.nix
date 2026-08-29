# MacBook pessoal. Nasce só com o comum — nada de CA corporativa, tokens da
# Stone ou toolchain mobile. Se algo daqui virar necessidade das duas máquinas,
# o lugar é modules/darwin, não uma cópia.
{ ... }: {
  # Confirmar na máquina antes do primeiro switch (runbook, fase 6):
  #   dscl . -read /Groups/nixbld PrimaryGroupID
  # Instalações antigas de Nix usavam 30000.
  ids.gids.nixbld = 350;

  homebrew = {
    brews = [ ];
    casks = [ ];
  };
}
