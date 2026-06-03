{ lib, pkgs, config, inventory, machineProvider, ... }:
let
  hostName = config.networking.hostName;
  provider = inventory.providers.${machineProvider};
  machines = provider.machines;
  clients = provider.clients or { };
  mesh = provider.wireguard;
  interfaceName = mesh.interface;
  host =
    if builtins.hasAttr hostName machines
    then machines.${hostName}
    else { };
  wireguard = host.wireguard or null;
  machinePeers = lib.filterAttrs (
    name: machine: name != hostName && machine ? wireguard
  ) machines;
  clientPeers = lib.filterAttrs (
    _name: client: client ? wireguard
  ) clients;

  machinePeerConfig = _name: peer:
    {
      publicKey = peer.wireguard.publicKey;
      endpoint = "${peer.address}:${toString peer.wireguard.listenPort}";
      allowedIPs = [ "${peer.wireguard.address}/32" ];
    } // lib.optionalAttrs (mesh ? persistentKeepalive) {
      persistentKeepalive = mesh.persistentKeepalive;
    };

  clientPeerConfig = _name: peer: {
    publicKey = peer.wireguard.publicKey;
    allowedIPs = [ "${peer.wireguard.address}/32" ];
  };
in
lib.mkIf (wireguard != null) {
  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  networking.firewall.allowedUDPPorts = [ wireguard.listenPort ];
  networking.firewall.trustedInterfaces =
    lib.optional (mesh.trusted or false) interfaceName;

  sops.secrets."wireguard/${hostName}/private_key" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  networking.wireguard.interfaces.${interfaceName} = {
    ips = [ "${wireguard.address}/${toString mesh.prefixLength}" ];
    mtu = mesh.mtu or null;
    listenPort = wireguard.listenPort;
    privateKeyFile = config.sops.secrets."wireguard/${hostName}/private_key".path;
    peers =
      (lib.mapAttrsToList machinePeerConfig machinePeers)
      ++ (lib.mapAttrsToList clientPeerConfig clientPeers);
  };
}
