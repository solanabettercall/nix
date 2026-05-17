{ config, ... }:
{
  users.users.clackgot = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets."users/clackgot/password_hash".path;
    openssh.authorizedKeys.keys = (import ../../ssh-keys.nix).clackgot;
  };

  security.sudo.wheelNeedsPassword = false;
}
