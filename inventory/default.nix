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
    subnets = {
      wg-mesh = {
        address = "10.77.0.0";
        prefixLength = 24;
      };

      awg-exit = {
        address = "10.78.0.0";
        prefixLength = 24;
      };
    };

    allocations = {
      wg-mesh = {
        machines = {
          ares = 2;
        };
        clients = {
          bubble-home = 10;
        };
      };

      awg-exit = {
        machines = {
          ares = 1;
        };
        clients = {
          bubble-home = 10;
        };
      };
    };

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
    publicKeys = {
      clackgot-xorek = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaR5chAudCG96WFgYZ347g2SdW1bt/Sn0B51SKDjd+G clackgot@91.108.227.42";
      clackgot-local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExWDHGnGypwAUH93//GexyPBO2vMeuMKfrxbat8jnI0 clackgot";
      ares-host-ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8KXMEwSy8FaWzTMnyRK+cp9PK6yNy/hcHEXfn8RPE0 root@ares";
      hermes-host-ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSYsKs7B7dQUO244ty/PxzS17SLZqy47RHmlZKAG44r root@hermes";
      github-ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };

    authorizedKeys.byUser = {
      clackgot = [
        "clackgot-xorek"
        "clackgot-local"
      ];
    };

    hostKeys.byMachine = {
      ares.publicKeyId = "ares-host-ed25519";
      hermes.publicKeyId = "hermes-host-ed25519";
    };
  };

  wireguard = {
    publicKeys = {
      ares-mesh = "2858b+QvM/6HSrXECeO1S4fIXy6uytIxHDvMxiCqCGo=";
      bubble-home = "+EEnaXWubYTIWHSGAgNoHeRsB3DDP+NvyxZVVt+LDTI=";
    };

    mesh = {
      subnetId = "wg-mesh";
      interface = "wg0";
      mtu = 1280;
      persistentKeepalive = 25;
      trusted = true;
      members.byMachine = {
        ares = {
          listenPort = 51820;
          publicKeyId = "ares-mesh";
        };
      };
      clients = {
        bubble-home = {
          publicKeyId = "bubble-home";
        };
      };
    };

    amnezia = {
      subnetId = "awg-exit";
      interface = "awg0";
      extraOptions = {
        Jc = 5;
        Jmin = 50;
        Jmax = 1000;
        S1 = 32;
        S2 = 64;
        H1 = 13245871;
        H2 = 22345791;
        H3 = 32342791;
        H4 = 42343119;
      };
      servers.byMachine = {
        ares = {
          listenPort = 51821;
          clients = [ "bubble-home" ];
        };
      };
      clients = {
        bubble-home = {
          publicKeyId = "bubble-home";
        };
      };
    };
  };

  externalKnownHosts = {
    github = {
      hostNames = [ "github.com" ];
      publicKeyId = "github-ed25519";
    };
  };
}
