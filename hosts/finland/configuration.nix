{ pkgs, ... }:
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
    hostName = "finland";
    useDHCP = false;
    interfaces.ens3.ipv4.addresses = [{
      address = "109.206.243.227";
      prefixLength = 32;
    }];
    defaultGateway = {
      address = "172.0.0.1";
      interface = "ens3";
    };
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # ── SSH ───────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── Пользователь ──────────────────────────────────────────────────────────
  users.users.clackgot = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = (import ../../ssh-keys.nix).clackgot;
  };

  security.sudo.wheelNeedsPassword = false;

  # ── Базовые пакеты ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    curl
    wget
  ];

  # ── Nix ──────────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── Временная зона ────────────────────────────────────────────────────────
  time.timeZone = "UTC";

  system.stateVersion = "24.11";
}
