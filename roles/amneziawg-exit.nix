{ config, inventory, ... }:
let
  interfaceName = "awg0";
  listenPort = inventory.ports.wireguard.amneziaExit;
in
{

  boot.extraModulePackages = [ config.boot.kernelPackages.amneziawg ];

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.firewall = {
    allowedUDPPorts = [ listenPort ];
    trustedInterfaces = [ interfaceName ];
  };

  networking.nat = {
    enable = true;
    externalInterface = "ens3";
    internalInterfaces = [ interfaceName ];
  };

  networking.wireguard.interfaces.${interfaceName} = {
    type = "amneziawg";
    ips = [ "10.78.0.1/24" ];
    listenPort = listenPort;
    privateKeyFile = config.sops.secrets."wireguard/${config.networking.hostName}/private_key".path;
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
    peers = [
      {
        publicKey = "+EEnaXWubYTIWHSGAgNoHeRsB3DDP+NvyxZVVt+LDTI=";
        allowedIPs = [ "10.78.0.10/32" ];
      }
    ];
  };
}
