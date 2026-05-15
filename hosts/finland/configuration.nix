{ pkgs, config, lib, sopsnix, ... }:
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

  # ── Secrets ────────────────────────────────────────────────────────────────
  sops = {
    package = sopsnix.packages.${pkgs.system}.sops-install-secrets;
    defaultSopsFile = ../../secrets/default.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = true;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.ssh_key = {
      path = "${config.users.users.clackgot.home}/.ssh/id_ed25519";
      owner = config.users.users.clackgot.name;
      group = "users";
      mode = "0600";
    };
    secrets."ssh_key.pub" = {
      path = "${config.users.users.clackgot.home}/.ssh/id_ed25519.pub";
      owner = config.users.users.clackgot.name;
      group = "users";
      mode = "0644";
    };
  };

  # ── Home-manager ────────────────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.clackgot = {
      home.stateVersion = "24.11";
      programs.ssh = {
        enable = true;
        matchBlocks = {
          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = "~/.ssh/id_ed25519";
            identitiesOnly = true;
          };
        };
      };
    };
  };

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
