{ config, inventory, ... }:
let
  hostName = config.networking.hostName;
  nodeEnvSecret = "remnawave/nodes/${hostName}/env";
  ports = inventory.ports.remnawave;
  wireguardInterface = inventory.providers.xorek.wireguard.interface;
in
{
  sops.secrets.${nodeEnvSecret} = {
    mode = "0400";
  };

  virtualisation.oci-containers.containers.remnanode = {
    image = "docker.io/remnawave/node:latest";
    autoStart = true;
    environmentFiles = [
      config.sops.secrets.${nodeEnvSecret}.path
    ];
    extraOptions = [
      "--network=host"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
      "--device=/dev/net/tun"
    ];
  };

  networking.firewall = {
    interfaces.${wireguardInterface}.allowedTCPPorts = [
      ports.nodeApi
    ];
    allowedTCPPorts = [
      ports.reality
    ];
  };
}
