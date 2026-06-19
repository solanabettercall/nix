let
  rootDomain = "bettercallsolana.chickenkiller.com";
  mkDomain = subdomain: "${subdomain}.${rootDomain}";
in
{
  machines = {
    ares = {
      address = "109.206.243.227";
    };

    hermes = {
      address = "192.168.10.50";
    };
  };

  users = {
    clackgot = {
      isNormalUser = true;
      sudo = true;
      ssh.authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaR5chAudCG96WFgYZ347g2SdW1bt/Sn0B51SKDjd+G clackgot@91.108.227.42"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExWDHGnGypwAUH93//GexyPBO2vMeuMKfrxbat8jnI0 clackgot"
      ];
    };
  };

  deploy = {
    defaultUserId = "clackgot";
  };

  dns = {
    inherit rootDomain;
    acmeEmail = "admin@${rootDomain}";
    records = {
      ares = {
        fqdn = mkDomain "ares";
        target = {
          machineId = "ares";
        };
      };
      media = {
        fqdn = mkDomain "media";
        target = {
          machineId = "ares";
        };
      };
    };
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

  providers = {
    byMachine = {
      ares = "xorek";
      hermes = "virtualbox";
    };

    definitions = {
      xorek = {
        knownProviderIds = [ "xorek" ];
      };

      virtualbox = {
        knownProviderIds = [ "xorek" "virtualbox" ];
      };
    };
  };

  network = {
    staticIpv4.byMachine = {
      ares = {
        interface = "ens3";
        prefixLength = 32;
        gateway = {
          address = "172.0.0.1";
          interface = "ens3";
        };
      };

      hermes = {
        interface = "enp0s3";
        prefixLength = 24;
        gateway = {
          address = "192.168.10.1";
        };
      };
    };
  };

  ssh = {
    hostKeys.byMachine = {
      ares.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8KXMEwSy8FaWzTMnyRK+cp9PK6yNy/hcHEXfn8RPE0 root@ares";
      hermes.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSYsKs7B7dQUO244ty/PxzS17SLZqy47RHmlZKAG44r root@hermes";
    };
  };

  wireguard = {
    mesh = {
      interface = "wg0";
      mtu = 1280;
      prefixLength = 24;
      persistentKeepalive = 25;
      trusted = true;
      members.byMachine = {
        ares = {
          address = "10.77.0.2";
          listenPort = 51820;
          publicKey = "2858b+QvM/6HSrXECeO1S4fIXy6uytIxHDvMxiCqCGo=";
        };
      };
      clients = {
        bubble-home = {
          address = "10.77.0.10";
          publicKey = "+EEnaXWubYTIWHSGAgNoHeRsB3DDP+NvyxZVVt+LDTI=";
        };
      };
    };
  };

  externalKnownHosts = {
    github = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}
