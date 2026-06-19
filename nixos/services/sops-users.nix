{ config, pkgs, sopsnix, ... }:
let
  inherit (config.local) inventory;
  mkUserSecrets = userId: _user: { config, ... }: {
    sops = {
      package = sopsnix.packages.${pkgs.stdenv.hostPlatform.system}.sops-install-secrets;
      defaultSopsFile = ../../secrets/users/${userId}.yaml;
      age.keyFile = "/var/lib/sops-nix/users/${userId}/key.txt";
      secrets."ssh/deploy/${userId}/private" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      secrets."ssh/deploy/${userId}/public" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        mode = "0644";
      };
    };
  };
in
{
  home-manager.users = builtins.mapAttrs mkUserSecrets inventory.users;
}
