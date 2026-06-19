{ lib, pkgs, config, ... }:
let
  inherit (config.networking) hostName;
  inherit (config.local) inventory;
  inherit (inventory) machines;
  inherit (inventory.wireguard) mesh;
  members = mesh.members.byMachine;
  inherit (mesh) clients;
  interfaceName = mesh.interface;
  publicKey = peer: inventory.wireguard.publicKeys.${peer.publicKeyId};
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
      publicKey = publicKey peer;
      endpoint = "${machines.${name}.address}:${toString peer.listenPort}";
      allowedIPs = [ "${peer.address}/32" ];
    } // lib.optionalAttrs (mesh.persistentKeepalive != null) {
      inherit (mesh) persistentKeepalive;
    };

  clientPeerConfig = _name: peer: {
    publicKey = publicKey peer;
    allowedIPs = [ "${peer.address}/32" ];
  };
in
lib.mkIf (wireguard != null) {
  environment.systemPackages = [
    pkgs.wireguard-tools
  ];

  networking = {
    firewall = {
      allowedUDPPorts = [ wireguard.listenPort ];
      trustedInterfaces = lib.optional (mesh.trusted or false) interfaceName;
    };

    wireguard.interfaces.${interfaceName} = {
      ips = [ "${wireguard.address}/${toString mesh.prefixLength}" ];
      inherit (mesh) mtu;
      inherit (wireguard) listenPort;
      privateKeyFile = config.sops.secrets."wireguard/${hostName}/private_key".path;
      peers =
        (lib.mapAttrsToList machinePeerConfig machinePeers)
        ++ (lib.mapAttrsToList clientPeerConfig clients);
    };
  };

  sops.secrets."wireguard/${hostName}/private_key" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
}
