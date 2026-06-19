let
  rootDomain = "bettercallsolana.chickenkiller.com";
  mkDomain = subdomain: "${subdomain}.${rootDomain}";

  domains = {
    inherit rootDomain;

    hosts = {
      ares = mkDomain "ares";
    };

    services = {
      media = mkDomain "media";
    };

    acmeEmail = "admin@${rootDomain}";
  };

  ports = {
    public = {
      ssh = 22;
      http = 80;
      https = 443;
    };

    wireguard = {
      mesh = 51820;
      amneziaExit = 51821;
    };

    media = {
      jellyfin = 8096;
      tlsFallback = 9443;
    };
  };
in
{
  inherit domains ports;

  providers = {
    xorek = {
      knownMachineProviders = [ "xorek" ];
      wireguard = {
        interface = "wg0";
        mtu = 1280;
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
        ares = {
          address = "109.206.243.227";
          hostName = domains.hosts.ares;
          location = "finland";
          prefixLength = 32;
          gateway = "172.0.0.1";
          gatewayInterface = "ens3";
          sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8KXMEwSy8FaWzTMnyRK+cp9PK6yNy/hcHEXfn8RPE0 root@ares";
          wireguard = {
            address = "10.77.0.2";
            listenPort = ports.wireguard.mesh;
            publicKey = "2858b+QvM/6HSrXECeO1S4fIXy6uytIxHDvMxiCqCGo=";
          };
        };
      };
    };

    virtualbox = {
      knownMachineProviders = [ "xorek" "virtualbox" ];
      machines = {
        hermes = {
          address = "192.168.10.50";
          interface = "enp0s3";
          prefixLength = 24;
          gateway = "192.168.10.1";
          sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSYsKs7B7dQUO244ty/PxzS17SLZqy47RHmlZKAG44r root@hermes";
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
