{ inventory, ... }:
let
  host = inventory.providers.xorek.machines.moscow;
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
    hostName = "moscow";
    useDHCP = false;
    interfaces.ens3.ipv4.addresses = [{
      address = host.address;
      prefixLength = host.prefixLength;
    }];
    defaultGateway = host.gateway;
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # ── Временная зона ────────────────────────────────────────────────────────
  time.timeZone = "UTC";

  system.stateVersion = "24.11";
}
