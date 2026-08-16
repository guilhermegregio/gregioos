{
  description = "GregioOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    herdr.url = "github:ogulcancelik/herdr";
    herdr.inputs.nixpkgs.follows = "nixpkgs";
    graphify.url = "github:guilhermegregio/nix-dev-envs?dir=graphify";
    graphify.inputs.nixpkgs.follows = "nixpkgs";
    kb.url = "git+file:///home/gregio/code/gregio-marketplace";
    kb.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    fine-cmdline = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      host = "gregio-asus-tuf-f15";
      username = "gregio";
      profile = "nvidia-laptop";
    in {
      nixosConfigurations = {
        nvidia-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit username;
            inherit host;
            inherit profile;
          };
          modules = [ ./profiles/nvidia-laptop ];
        };
      };
    };
}
