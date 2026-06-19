{ config, ... }:
let
  inventory = config.local.inventory;
  machine = inventory.machines.hermes;
  network = inventory.network.staticIpv4.byMachine.hermes;
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
    hostName = "hermes";
    useDHCP = false;
    interfaces.${network.interface}.ipv4.addresses = [{
      address = machine.address;
      prefixLength = network.prefixLength;
    }];
    defaultGateway = network.gateway.address;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ inventory.ports.public.ssh ];
    };
  };

  time.timeZone = "UTC";

  system.stateVersion = "24.11";
}
