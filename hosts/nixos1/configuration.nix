{ inventory, ... }:
let
  host = inventory.providers.virtualbox.machines.nixos1;
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
    hostName = "nixos1";
    useDHCP = false;
    interfaces.${host.interface}.ipv4.addresses = [{
      address = host.address;
      prefixLength = host.prefixLength;
    }];
    defaultGateway = host.gateway;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  time.timeZone = "UTC";

  system.stateVersion = "24.11";
}
