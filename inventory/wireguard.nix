{
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
}
