{ pkgs, config, sopsnix, ... }:
{
  services.qemuGuest.enable = true;

  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  sops = {
    package = sopsnix.packages.${pkgs.system}.sops-install-secrets;
    defaultSopsFile = ../secrets/default.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets."ssh/deploy/clackgot/private" = {
      path = "${config.users.users.clackgot.home}/.ssh/id_ed25519";
      owner = config.users.users.clackgot.name;
      group = "users";
      mode = "0600";
    };
    secrets."ssh/deploy/clackgot/public" = {
      path = "${config.users.users.clackgot.home}/.ssh/id_ed25519.pub";
      owner = config.users.users.clackgot.name;
      group = "users";
      mode = "0644";
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
