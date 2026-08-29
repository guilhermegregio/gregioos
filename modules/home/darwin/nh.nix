# O nix-darwin não tem `programs.nh` (só o NixOS e o home-manager têm), então
# no macOS o nh vem por aqui. É o que faz `fr`/`fu` funcionarem igual às outras
# máquinas — no NixOS quem cuida disso é modules/core/nh.nix.
{ username, ... }: {
  programs.nh = {
    enable = true;
    # Mesmo caminho nas três máquinas. Define NH_FLAKE, então `fr` funciona de
    # qualquer diretório.
    flake = "/Users/${username}/gregioos";
  };
}
