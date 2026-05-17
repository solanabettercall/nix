{ pkgs, sopsnix, ... }:
{
  home-manager.users.clackgot = { config, ... }: {
    sops = {
      package = sopsnix.packages.${pkgs.system}.sops-install-secrets;
      defaultSopsFile = ../../secrets/users/clackgot.yaml;
      age.keyFile = "/var/lib/sops-nix/users/clackgot/key.txt";
      secrets."ssh/deploy/clackgot/private" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      secrets."ssh/deploy/clackgot/public" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        mode = "0644";
      };
    };
  };
}
