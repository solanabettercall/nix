{ lib, pkgs, config, localLib, ... }:
let
  inherit (config.networking) hostName;
  inherit (config.local) inventory;
  inherit (inventory) machines;
  inherit (inventory.wireguard) mesh;
  members = mesh.members.byMachine;
  inherit (mesh) clients;
  interfaceName = mesh.interface;
  subnet = inventory.network.subnets.${mesh.subnetId};
  machineAddress = localLib.network.ipv4.machineAddress inventory mesh.subnetId;
  clientAddress = localLib.network.ipv4.clientAddress inventory mesh.subnetId;
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
      allowedIPs = [ "${machineAddress name}/32" ];
    } // lib.optionalAttrs (mesh.persistentKeepalive != null) {
      inherit (mesh) persistentKeepalive;
    };

  clientPeerConfig = name: peer: {
    publicKey = publicKey peer;
    allowedIPs = [ "${clientAddress name}/32" ];
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
      ips = [ "${machineAddress hostName}/${toString subnet.prefixLength}" ];
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
