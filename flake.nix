{
  description = "NixOS VPS config";

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
  };

  outputs = { self, nixpkgs, disko, sops-nix, ... }: {
    nixosConfigurations.xorek = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { sopsnix = sops-nix; };
      modules = [
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        ./hosts/xorek/disk-config.nix
        ./hosts/xorek/configuration.nix
      ];
    };
  };
}