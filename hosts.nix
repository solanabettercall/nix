{
  providers = {
    xorek = {
      knownMachineProviders = [ "xorek" ];
      wireguard = {
        interface = "wg0";
        prefixLength = 24;
        persistentKeepalive = 25;
        trusted = true;
      };
      clients = {
        bubble-home = {
          wireguard = {
            address = "10.77.0.10";
            publicKey = "+EEnaXWubYTIWHSGAgNoHeRsB3DDP+NvyxZVVt+LDTI=";
          };
        };
      };
      machines = {
        moscow = {
          address = "31.76.230.57";
          prefixLength = 24;
          gateway = "31.76.230.1";
          sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBc95eQyBa8K/u8xIORn6ES8PQvgB5WTdeB8LRK6OsNH root@moscow";
          wireguard = {
            address = "10.77.0.1";
            listenPort = 51820;
            publicKey = "FF6DIXUFbcnv5U/w+uWWYC7gGfx0G25yK4Ed1s/UpSo=";
          };
        };

        finland = {
          address = "109.206.243.227";
          prefixLength = 32;
          gateway = "172.0.0.1";
          gatewayInterface = "ens3";
          sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8KXMEwSy8FaWzTMnyRK+cp9PK6yNy/hcHEXfn8RPE0 root@finland";
          wireguard = {
            address = "10.77.0.2";
            listenPort = 51820;
            publicKey = "2858b+QvM/6HSrXECeO1S4fIXy6uytIxHDvMxiCqCGo=";
          };
        };
      };
    };

    virtualbox = {
      knownMachineProviders = [ "xorek" "virtualbox" ];
      machines = {
        nixos1 = {
          address = "192.168.10.50";
          interface = "enp0s3";
          prefixLength = 24;
          gateway = "192.168.10.1";
          sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSYsKs7B7dQUO244ty/PxzS17SLZqy47RHmlZKAG44r root@nixos1";
        };
      };
    };
  };

  external = {
    github = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}
