{ config, inventory, lib, pkgs, ... }:
let
  panelDomain = inventory.domains.services.remnawavePanel;
  panelUrl = "https://${panelDomain}";
  panelConfigEnv = "/etc/remnawave/panel.env";
  panelSecretEnv = config.sops.secrets."remnawave/panel_env".path;
  ports = inventory.ports.remnawave;
  wireguardInterface = inventory.providers.xorek.wireguard.interface;
  podmanSubnet = "10.89.10.0/24";
  containerServices = [
    "podman-remnawave-db"
    "podman-remnawave-valkey"
    "podman-remnawave"
  ];
  containerUnits = map (name: "${name}.service") containerServices;
in
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      remnawave-db = {
        image = "docker.io/library/postgres:17.6";
        autoStart = true;
        environmentFiles = [ panelSecretEnv ];
        volumes = [
          "/var/lib/remnawave/postgres:/var/lib/postgresql/data"
        ];
        extraOptions = [
          "--network=remnawave"
          "--network-alias=remnawave-db"
        ];
      };

      remnawave-valkey = {
        image = "docker.io/valkey/valkey:9-alpine";
        autoStart = true;
        cmd = [
          "valkey-server"
          "--save"
          ""
          "--appendonly"
          "no"
          "--maxmemory-policy"
          "noeviction"
          "--loglevel"
          "warning"
        ];
        extraOptions = [
          "--network=remnawave"
          "--network-alias=remnawave-valkey"
        ];
      };

      remnawave = {
        image = "docker.io/remnawave/backend:2";
        autoStart = true;
        dependsOn = [
          "remnawave-db"
          "remnawave-valkey"
        ];
        environmentFiles = [
          panelConfigEnv
          panelSecretEnv
        ];
        ports = [
          "127.0.0.1:${toString ports.backend}:${toString ports.backend}"
          "127.0.0.1:${toString ports.metrics}:${toString ports.metrics}"
        ];
        extraOptions = [
          "--network=remnawave"
        ];
      };
    };
  };

  environment.etc."remnawave/panel.env".text = lib.generators.toKeyValue { } {
    APP_PORT = ports.backend;
    METRICS_PORT = ports.metrics;
    API_INSTANCES = 1;
    REDIS_HOST = "remnawave-valkey";
    REDIS_PORT = 6379;
    PANEL_DOMAIN = panelDomain;
    FRONT_END_DOMAIN = panelUrl;
    SUB_PUBLIC_DOMAIN = "${panelDomain}/api/sub";
    METRICS_USER = "admin";
    WEBHOOK_ENABLED = "false";
  };

  sops.secrets."remnawave/panel_env" = {
    mode = "0400";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/remnawave 0700 root root -"
    "d /var/lib/remnawave/postgres 0700 999 999 -"
  ];

  systemd.services = {
    remnawave-network = {
      description = "Create Remnawave Podman network";
      wantedBy = [ "multi-user.target" ];
      before = containerUnits;
      after = [ "podman.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.podman}/bin/podman network exists remnawave \
          || ${pkgs.podman}/bin/podman network create --subnet ${podmanSubnet} remnawave
      '';
    };
  } // lib.genAttrs containerServices (_name: {
    requires = [
      "remnawave-network.service"
    ];
    after = [
      "remnawave-network.service"
    ];
  });

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts.${panelDomain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString ports.backend}";
        recommendedProxySettings = false;
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-Ssl on;
        '';
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = inventory.domains.acmeEmail;
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };
  };

  # Let Remnawave panel containers reach node APIs over the WireGuard mesh.
  # The SNAT is needed because remote peers only route 10.77.0.1/32 back here,
  # not Podman's private bridge subnets.
  networking.nat = {
    enable = true;
    externalInterface = wireguardInterface;
    internalIPs = [
      podmanSubnet
    ];
  };

  networking.firewall.allowedTCPPorts = [
    inventory.ports.public.http
    inventory.ports.public.https
  ];
}
