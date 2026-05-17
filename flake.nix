{
  description = "NixOS machines config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

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
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, sops-nix, home-manager, ... }:
    let
      inventory = import ./hosts.nix;
      providerModules = {
        xorek = ./modules/providers/xorek.nix;
        virtualbox = ./modules/providers/virtualbox.nix;
      };
      mkMachine = { name, provider, roles ? [ ] }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inventory;
          sopsnix = sops-nix;
          machineProvider = provider;
        };
        modules = [
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          ./modules/base/users.nix
          ./modules/base/packages.nix
          ./modules/base/nix.nix
          ./modules/base/home-manager.nix
          ./modules/secrets/system.nix
          ./modules/secrets/clackgot.nix
          ./modules/ssh/server.nix
          ./modules/ssh/client.nix
          providerModules.${provider}
          ./hosts/${name}/disk-config.nix
          ./hosts/${name}/configuration.nix
        ] ++ roles;
      };
    in {
      nixosConfigurations = {
        moscow = mkMachine {
          name = "moscow";
          provider = "xorek";
        };
        finland = mkMachine {
          name = "finland";
          provider = "xorek";
        };
        nixos1 = mkMachine {
          name = "nixos1";
          provider = "virtualbox";
        };
      };
    };
}
