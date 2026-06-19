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
      system = "x86_64-linux";
      inventory = import ./inventory;
      localLib = {
        network = import ./lib/network.nix { };
      };
      providerModules = {
        xorek = ./nixos/providers/xorek.nix;
        virtualbox = ./nixos/providers/virtualbox.nix;
      };
      mkMachine = { name }:
        let
          provider = inventory.providers.byMachine.${name};
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inventory localLib;
            sopsnix = sops-nix;
            machineId = name;
          };
          modules = [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            ./nixos/inventory.nix
            ./nixos/profiles/machine.nix
            ./nixos/profiles/users.nix
            ./nixos/profiles/home-manager.nix
            ./nixos/profiles/hosts.nix
            ./nixos/programs/system-tools.nix
            ./nixos/programs/net-tools.nix
            ./nixos/programs/nix.nix
            ./nixos/programs/ssh-client.nix
            ./nixos/services/sops-system.nix
            ./nixos/services/sops-users.nix
            ./nixos/services/openssh.nix
            ./nixos/services/wireguard-mesh.nix
            ./nixos/services/amneziawg.nix
            providerModules.${provider}
            ./hosts/${name}/disk-config.nix
            ./hosts/${name}/configuration.nix
          ];
        };
    in
    {
      packages.${system} = import ./packages { };

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
