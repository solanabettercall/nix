{ config, lib, localLib, ... }:
let
  cfg = config.local.services.amneziawg;
  inherit (config.local) inventory;
  inherit (config.networking) hostName;
  inherit (inventory.wireguard) amnezia;
  server = amnezia.servers.byMachine.${hostName};
  network = inventory.network.staticIpv4.byMachine.${hostName};
  subnet = inventory.network.subnets.${amnezia.subnetId};
  subnetAddress = localLib.network.ipv4.addressInSubnet24 subnet;
  machineAddress = name: subnetAddress inventory.network.allocations.${amnezia.subnetId}.machines.${name};
  clientAddress = name: subnetAddress inventory.network.allocations.${amnezia.subnetId}.clients.${name};
  clientConfig = clientId:
    let
      client = amnezia.clients.${clientId};
    in
    {
      publicKey = inventory.wireguard.publicKeys.${client.publicKeyId};
      allowedIPs = [ "${clientAddress clientId}/32" ];
    };
in
{
  options.local.services.amneziawg = {
    enable = lib.mkEnableOption "AmneziaWG exit interface";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      extraModulePackages = [ config.boot.kernelPackages.amneziawg ];
      kernel.sysctl."net.ipv4.ip_forward" = 1;
    };

    networking = {
      firewall = {
        allowedUDPPorts = [ server.listenPort ];
        trustedInterfaces = [ amnezia.interface ];
      };

      nat = {
        enable = true;
        externalInterface = network.interface;
        internalInterfaces = [ amnezia.interface ];
      };

      wireguard.interfaces.${amnezia.interface} = {
        type = "amneziawg";
        ips = [ "${machineAddress hostName}/${toString subnet.prefixLength}" ];
        inherit (server) listenPort;
        privateKeyFile = config.sops.secrets."wireguard/${config.networking.hostName}/private_key".path;
        inherit (amnezia) extraOptions;
        peers = map clientConfig server.clients;
      };
    };
  };
}
