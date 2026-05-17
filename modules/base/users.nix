{
  users.users.clackgot = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = (import ../../ssh-keys.nix).clackgot;
  };

  security.sudo.wheelNeedsPassword = false;
}
