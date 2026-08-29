{
  description = "GregioOS — configuração multi-host (NixOS + nix-darwin)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # macOS — usados pelos hosts darwin (ver darwinConfigurations).
    # O nix-darwin exige que sua branch de release case com a do nixpkgs; o
    # master é 26.11 e quebraria o eval contra o nixpkgs 26.05 do lock. Ao
    # subir o nixpkgs para a próxima release, subir esta branch junto.
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
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

  outputs = { nixpkgs, home-manager, darwin, ... }@inputs:
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

      # Um host macOS. modules/darwin é o comum; hosts/<host> só acrescenta.
      # O attr é o hostname real, então `--flake .` resolve sem `#nome`.
      mkDarwin =
        { host
        , username
        , system ? "aarch64-darwin"
        }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs username host; };
          modules = [
            inputs.nix-index-database.darwinModules.nix-index
            ./modules/darwin
            ./hosts/${host}

            {
              nixpkgs.config.allowUnfree = true;

              networking = {
                computerName = host;
                hostName = host;
                localHostName = host;
              };

              system.primaryUser = username;
              users.users.${username} = {
                name = username;
                home = "/Users/${username}";
              };

              nix.settings = {
                allowed-users = [ username ];
                experimental-features = [ "nix-command" "flakes" ];
                warn-dirty = false;
                # https://github.com/NixOS/nix/issues/7273
                auto-optimise-store = false;
              };

              # Faz `nix-shell -p` e afins usarem o nixpkgs do lock, sem channels.
              nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
              nix.registry.nixpkgs.flake = inputs.nixpkgs;
            }

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                # Sem isto a ativação aborta em qualquer arquivo que já exista
                # e não tenha sido criado pelo home-manager (gh, btop e afins
                # escrevem os seus no primeiro uso). Mesmo valor do NixOS, em
                # modules/core/user.nix.
                backupFileExtension = "backup";
                extraSpecialArgs = {
                  inherit inputs username host;
                  hostPlatform = "darwin";
                };
                users.${username} = {
                  imports = [ ./modules/home ];
                  home.stateVersion =
                    (import ./hosts/${host}/variables.nix).homeStateVersion;
                  programs.home-manager.enable = true;
                };
              };
            }
          ];
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

      darwinConfigurations = {
        # trabalho (Stone)
        CV9NF4V0H6 = mkDarwin {
          host = "CV9NF4V0H6";
          username = "guilherme.gregio";
        };

        # pessoal — username confirmado com `whoami` na fase 6.2
        nxt-os-01 = mkDarwin {
          host = "nxt-os-01";
          username = "gregio";
        };
      };
    };
}
