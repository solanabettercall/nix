{ config, machineId, ... }:
let
  inherit (config.local) inventory;
  machine = inventory.machines.${machineId};
  network = inventory.network.staticIpv4.byMachine.${machineId};
  gateway =
    if network.gateway.interface == null
    then network.gateway.address
    else {
      inherit (network.gateway) address interface;
    };
in
{
  boot.loader.grub = {
    enable = true;
    device = "nodev";
  };

  networking = {
    hostName = machineId;
    useDHCP = false;
    interfaces.${network.interface}.ipv4.addresses = [{
      inherit (machine) address;
      inherit (network) prefixLength;
    }];
    defaultGateway = gateway;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedTCPPorts = with inventory.ports.public; [ ssh ];
    };
  };

  time.timeZone = "UTC";

  system.stateVersion = "24.11";
}
