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
    hostName = "vps";
    useDHCP = false;
    interfaces.ens3.ipv4.addresses = [{
      address = "31.76.230.57";
      prefixLength = 24;
    }];
    defaultGateway = "31.76.230.1";
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
      PermitRootLogin = "prohibit-password";
    };
  };

  # Добавь свой публичный ключ
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCu0ibcTXkcosUdMfW+rX8zmtz3Q52lf1PVBQ0KWoORWxqPQ+bctFbX892FMcAR8oISz2KoMhDtIqOacZ+CdbZtLBbA/rLaKKQZl0BmK9N4jyTHV1FHadUtaYl2VimKrwpuD3eR+3Ju1JH2QwULfqNfYaHiAtEpt91JYr+FSQR9BsUW022spRo/m5vZzJLNnSCZi/oX867aRbhewsE4RTLpAP8PWUVrykHlv0DeRW9ao1XoCcgM1oA5sbvdyIMeHOZokemcHRFAn7dXfKkpytMC/XatCKdT0bjSmpBjvPucaHUrD0ipCxxXL5pwviLyuz8vwkh2yKFGXZgeJX9DABCFXMkwFJRyZTkaiZHC3e06gneah0YLl0PuBRFDO9s12xsAkPREQbUcvV2yWDZHezmdhC2+lpZlmwjB+qd0p4AOo2E0sNV378WUniegkX4iqsg9RdRo3ERTAS3nxMyClDnb4Ni40RHHKbqNiR/Xd0NkQ3ZN/gxhphIt6uiHDDhdFhk= user@kirill-desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaR5chAudCG96WFgYZ347g2SdW1bt/Sn0B51SKDjd+G clackgot@91.108.227.42"
  ];

  # ── Пользователь ──────────────────────────────────────────────────────────
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCu0ibcTXkcosUdMfW+rX8zmtz3Q52lf1PVBQ0KWoORWxqPQ+bctFbX892FMcAR8oISz2KoMhDtIqOacZ+CdbZtLBbA/rLaKKQZl0BmK9N4jyTHV1FHadUtaYl2VimKrwpuD3eR+3Ju1JH2QwULfqNfYaHiAtEpt91JYr+FSQR9BsUW022spRo/m5vZzJLNnSCZi/oX867aRbhewsE4RTLpAP8PWUVrykHlv0DeRW9ao1XoCcgM1oA5sbvdyIMeHOZokemcHRFAn7dXfKkpytMC/XatCKdT0bjSmpBjvPucaHUrD0ipCxxXL5pwviLyuz8vwkh2yKFGXZgeJX9DABCFXMkwFJRyZTkaiZHC3e06gneah0YLl0PuBRFDO9s12xsAkPREQbUcvV2yWDZHezmdhC2+lpZlmwjB+qd0p4AOo2E0sNV378WUniegkX4iqsg9RdRo3ERTAS3nxMyClDnb4Ni40RHHKbqNiR/Xd0NkQ3ZN/gxhphIt6uiHDDhdFhk= user@kirill-desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaR5chAudCG96WFgYZ347g2SdW1bt/Sn0B51SKDjd+G clackgot@91.108.227.42"
    ];
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

  # ── Временная зона ────────────────────────────────────────────────────────
  time.timeZone = "UTC";

  system.stateVersion = "24.11";
}