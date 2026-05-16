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
    defaultSopsFile = ../secrets/system.yaml;
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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      sopsnix.homeManagerModules.sops
    ];
    users.clackgot = { config, ... }: {
      home.stateVersion = "24.11";
      sops = {
        package = sopsnix.packages.${pkgs.system}.sops-install-secrets;
        defaultSopsFile = ../secrets/users/clackgot.yaml;
        age.keyFile = "/var/lib/sops-nix/users/clackgot/key.txt";
        secrets."ssh/deploy/clackgot/private" = {
          path = "${config.home.homeDirectory}/.ssh/id_ed25519";
          mode = "0600";
        };
        secrets."ssh/deploy/clackgot/public" = {
          path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
          mode = "0644";
        };
      };
      programs.ssh = {
        enable = true;
        matchBlocks = {
          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = "~/.ssh/id_ed25519";
            identitiesOnly = true;
          };
          moscow = {
            hostname = "31.76.230.57";
            user = "clackgot";
            identityFile = "~/.ssh/id_ed25519";
            identitiesOnly = true;
          };
          finland = {
            hostname = "109.206.243.227";
            user = "clackgot";
            identityFile = "~/.ssh/id_ed25519";
            identitiesOnly = true;
          };
        };
      };
    };
  };
}
