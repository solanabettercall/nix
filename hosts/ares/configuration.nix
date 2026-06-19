{ config, machineId, ... }:
let
  inventory = config.local.inventory;
  machine = inventory.machines.${machineId};
  network = inventory.network.staticIpv4.byMachine.${machineId};
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ── Загрузчик ─────────────────────────────────────────────────────────────
  boot.loader.grub = {
    enable = true;
    device = "nodev";
  };

  # ── Сеть ──────────────────────────────────────────────────────────────────
  networking = {
    hostName = machineId;
    useDHCP = false;
    interfaces.${network.interface}.ipv4.addresses = [{
      address = machine.address;
      prefixLength = network.prefixLength;
    }];
    defaultGateway = {
      address = network.gateway.address;
      interface = network.gateway.interface;
    };
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ inventory.ports.public.ssh ];
    };
  };

  # ── Временная зона ────────────────────────────────────────────────────────
  time.timeZone = "UTC";

  system.stateVersion = "24.11";
}
