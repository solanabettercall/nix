{ sopsnix, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      sopsnix.homeManagerModules.sops
    ];
    users.clackgot = {
      home.stateVersion = "24.11";
    };
  };
}
