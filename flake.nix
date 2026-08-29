{
  description = "GregioOS — configuração multi-host (NixOS + nix-darwin)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # macOS — usados pelos hosts darwin (ver darwinConfigurations)
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Linux-only — não referenciar em módulos comuns nem darwin
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    stylix.url = "github:danth/stylix";

    herdr.url = "github:ogulcancelik/herdr";
    herdr.inputs.nixpkgs.follows = "nixpkgs";
    graphify.url = "github:guilhermegregio/nix-dev-envs?dir=graphify";
    graphify.inputs.nixpkgs.follows = "nixpkgs";
    # Repo remoto, não caminho local: os Macs também consomem este input.
    # Para desenvolver o kb: --override-input kb ~/code/gregio-marketplace
    kb.url = "github:guilhermegregio/gregio-marketplace";
    kb.inputs.nixpkgs.follows = "nixpkgs";

    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      # Um host NixOS. O profile importa hosts/<host>/hardware.nix, os drivers
      # e modules/core; o específico da máquina mora em hosts/<host>/.
      mkNixos =
        { host
        , username ? "gregio"
        , profile ? "nvidia-laptop"
        , system ? "x86_64-linux"
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username host profile; };
          modules = [ ./profiles/${profile} ];
        };

      asus = mkNixos { host = "gregio-asus-tuf-f15"; };
    in
    {
      nixosConfigurations = {
        gregio-asus-tuf-f15 = asus;
        gregio-note = mkNixos { host = "gregio-note"; };

        # Compat: o `fr` de hoje resolve pelo profile
        # (`nh os switch --hostname nvidia-laptop`). Sai na task 5.2, depois
        # que o alias por host estiver em uso nas três máquinas.
        nvidia-laptop = asus;
      };
    };
}
