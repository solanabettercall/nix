{ pkgs, config, lib, sopsnix, ... }:
let
  inventory = import ../hosts.nix;
  machines = inventory.machines;
in
{
  services.qemuGuest.enable = true;

  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  programs.ssh.knownHosts = {
    moscow = {
      hostNames = [ "moscow" machines.moscow.address ];
      publicKey = machines.moscow.sshHostKey;
    };
    finland = {
      hostNames = [ "finland" machines.finland.address ];
      publicKey = machines.finland.sshHostKey;
    };
    github = {
      hostNames = inventory.knownHosts.github.hostNames;
      publicKey = inventory.knownHosts.github.sshHostKey;
    };
  };

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
            hostname = machines.moscow.address;
            user = "clackgot";
            identityFile = "~/.ssh/id_ed25519";
            identitiesOnly = true;
          };
          finland = {
            hostname = machines.finland.address;
            user = "clackgot";
            identityFile = "~/.ssh/id_ed25519";
            identitiesOnly = true;
          };
        };
      };
    };
  };
}
