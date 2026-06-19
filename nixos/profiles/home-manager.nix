{ config, sopsnix, ... }:
let
  inherit (config.local) inventory;
  mkHomeUser = _userId: _user: {
    home.stateVersion = "24.11";
  };
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      sopsnix.homeManagerModules.sops
    ];
    users = builtins.mapAttrs mkHomeUser inventory.users;
  };
}
