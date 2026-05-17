{ lib, pkgs, config, inventory, ... }:
let
  hostName = config.networking.hostName;
  machines = inventory.providers.xorek.machines;
  host =
    if builtins.hasAttr hostName machines
    then machines.${hostName}
    else { };
  wireguard = host.wireguard or null;
  peers = lib.filterAttrs (
    name: machine: name != hostName && machine ? wireguard
  ) machines;
in
lib.mkIf (wireguard != null) {
  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  networking.firewall.allowedUDPPorts = [ wireguard.listenPort ];

  sops.secrets."wireguard/${hostName}/private_key" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "${wireguard.address}/24" ];
    listenPort = wireguard.listenPort;
    privateKeyFile = config.sops.secrets."wireguard/${hostName}/private_key".path;
    peers = lib.mapAttrsToList (
      _name: peer: {
        publicKey = peer.wireguard.publicKey;
        endpoint = "${peer.address}:${toString peer.wireguard.listenPort}";
        allowedIPs = [ "${peer.wireguard.address}/32" ];
        persistentKeepalive = 25;
      }
    ) peers;
  };
}
