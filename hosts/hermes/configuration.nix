{ config, machineId, ... }:
let
  inherit (config.local) inventory;
  machine = inventory.machines.${machineId};
  network = inventory.network.staticIpv4.byMachine.${machineId};
in
{
  imports = [
    ./hardware-configuration.nix
  ];

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
    defaultGateway = network.gateway.address;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedTCPPorts = with inventory.ports.public; [ ssh ];
    };
  };

  time = {
    timeZone = "UTC";
  };

  system = {
    stateVersion = "24.11";
  };
}
