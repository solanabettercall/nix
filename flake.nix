{
  description = "NixOS machines config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, sops-nix, home-manager, ... }:
    let
      inventory = import ./inventory;
      localLib = {
        network = import ./lib/network.nix { };
      };
      providerModules = {
        xorek = ./modules/providers/xorek.nix;
        virtualbox = ./modules/providers/virtualbox.nix;
      };
      mkMachine = { name }:
        let
          provider = inventory.providers.byMachine.${name};
        in
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inventory localLib;
            sopsnix = sops-nix;
            machineId = name;
          };
          modules = [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            ./modules/inventory.nix
            ./modules/base/users.nix
            ./modules/base/packages.nix
            ./modules/profiles/machine.nix
            ./modules/profiles/net-tools.nix
            ./modules/base/nix.nix
            ./modules/base/home-manager.nix
            ./modules/secrets/system.nix
            ./modules/secrets/users.nix
            ./modules/network/hosts.nix
            ./modules/ssh/server.nix
            ./modules/ssh/client.nix
            ./modules/wireguard/mesh.nix
            ./modules/services/amneziawg.nix
            providerModules.${provider}
            ./hosts/${name}/disk-config.nix
            ./hosts/${name}/configuration.nix
          ];
        };
    in
    {
      nixosConfigurations = {
        ares = mkMachine {
          name = "ares";
        };
        hermes = mkMachine {
          name = "hermes";
        };
      };
    };
}
