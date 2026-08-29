# MacBook pessoal. Nasce só com o comum — nada de CA corporativa, tokens da
# Stone ou toolchain mobile. Se algo daqui virar necessidade das duas máquinas,
# o lugar é modules/darwin, não uma cópia.
{ pkgs, ... }: {
  # Confirmar na máquina antes do primeiro switch (docs/bootstrap-nxt-os-01.md):
  #   dscl . -read /Groups/nixbld PrimaryGroupID
  # Instalações antigas de Nix usavam 30000.
  ids.gids.nixbld = 350;

  # Containers: aqui o runtime é o colima (que vem de modules/home/darwin),
  # não o Docker Desktop. Como é o Desktop quem instala o cliente `docker` no
  # macOS, sem ele o cliente precisa vir do nix — o colima sobe a VM, mas não
  # fornece o binário com que se fala com ela.
  environment.systemPackages = with pkgs; [ docker docker-compose ];

  homebrew = {
    brews = [ ];
    casks = [ ];
  };
}
