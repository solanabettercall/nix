{ lib, pkgs, config, inventory, machineProvider, ... }:
let
  hostName = config.networking.hostName;
  provider = inventory.providers.${machineProvider};
  machines = provider.machines;
  mesh = provider.wireguard;
  interfaceName = mesh.interface;
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
  networking.firewall.trustedInterfaces =
    lib.optional (mesh.trusted or false) interfaceName;

  sops.secrets."wireguard/${hostName}/private_key" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  networking.wireguard.interfaces.${interfaceName} = {
    ips = [ "${wireguard.address}/${toString mesh.prefixLength}" ];
    listenPort = wireguard.listenPort;
    privateKeyFile = config.sops.secrets."wireguard/${hostName}/private_key".path;
    peers = lib.mapAttrsToList (
      _name: peer:
        {
          publicKey = peer.wireguard.publicKey;
          endpoint = "${peer.address}:${toString peer.wireguard.listenPort}";
          allowedIPs = [ "${peer.wireguard.address}/32" ];
        } // lib.optionalAttrs (mesh ? persistentKeepalive) {
          persistentKeepalive = mesh.persistentKeepalive;
        }
    ) peers;
  };
}
