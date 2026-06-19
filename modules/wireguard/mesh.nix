{ lib, pkgs, config, ... }:
let
  hostName = config.networking.hostName;
  inventory = config.local.inventory;
  machines = inventory.machines;
  mesh = inventory.wireguard.mesh;
  members = mesh.members.byMachine;
  clients = mesh.clients;
  interfaceName = mesh.interface;
  wireguard =
    if builtins.hasAttr hostName members
    then members.${hostName}
    else null;
  machinePeers = lib.filterAttrs
    (
      name: _member: name != hostName
    )
    members;

  machinePeerConfig = name: peer:
    {
      publicKey = peer.publicKey;
      endpoint = "${machines.${name}.address}:${toString peer.listenPort}";
      allowedIPs = [ "${peer.address}/32" ];
    } // lib.optionalAttrs (mesh.persistentKeepalive != null) {
      persistentKeepalive = mesh.persistentKeepalive;
    };

  clientPeerConfig = _name: peer: {
    publicKey = peer.publicKey;
    allowedIPs = [ "${peer.address}/32" ];
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
    mtu = mesh.mtu;
    listenPort = wireguard.listenPort;
    privateKeyFile = config.sops.secrets."wireguard/${hostName}/private_key".path;
    peers =
      (lib.mapAttrsToList machinePeerConfig machinePeers)
      ++ (lib.mapAttrsToList clientPeerConfig clients);
  };
}
