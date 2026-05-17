{ pkgs, config, sopsnix, ... }:
{
  sops = {
    package = sopsnix.packages.${pkgs.system}.sops-install-secrets;
    defaultSopsFile = ../../secrets/system.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets."users/clackgot/sops_age_key" = {
      path = "/var/lib/sops-nix/users/clackgot/key.txt";
      owner = config.users.users.clackgot.name;
      group = "users";
      mode = "0400";
    };
    secrets."ssh/host/${config.networking.hostName}/ed25519/private" = {
      path = "/etc/ssh/ssh_host_ed25519_key";
      owner = "root";
      group = "root";
      mode = "0600";
    };
    secrets."ssh/host/${config.networking.hostName}/ed25519/public" = {
      path = "/etc/ssh/ssh_host_ed25519_key.pub";
      owner = "root";
      group = "root";
      mode = "0644";
    };
  };
}
