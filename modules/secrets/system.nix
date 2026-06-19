{ lib, pkgs, config, sopsnix, ... }:
let
  inventory = config.local.inventory;
  mkUserSecrets = userId: _user: {
    "users/${userId}/sops_age_key" = {
      path = "/var/lib/sops-nix/users/${userId}/key.txt";
      owner = config.users.users.${userId}.name;
      group = "users";
      mode = "0400";
    };
    "users/${userId}/password_hash" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
in
{
  sops = {
    package = sopsnix.packages.${pkgs.stdenv.hostPlatform.system}.sops-install-secrets;
    defaultSopsFile = ../../secrets/system.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets = lib.mergeAttrsList (builtins.attrValues (builtins.mapAttrs mkUserSecrets inventory.users)) // {
      "ssh/host/${config.networking.hostName}/ed25519/private" = {
        path = "/etc/ssh/ssh_host_ed25519_key";
        owner = "root";
        group = "root";
        mode = "0600";
      };
      "ssh/host/${config.networking.hostName}/ed25519/public" = {
        path = "/etc/ssh/ssh_host_ed25519_key.pub";
        owner = "root";
        group = "root";
        mode = "0644";
      };
    };
  };
}
