{ config, lib, ... }:
let
  inventory = config.local.inventory;
  sudoUsers = lib.filterAttrs (_userId: user: user.sudo) inventory.users;
  mkUser = userId: user: {
    isNormalUser = user.isNormalUser;
    extraGroups = lib.optional user.sudo "wheel";
    hashedPasswordFile = config.sops.secrets."users/${userId}/password_hash".path;
    openssh.authorizedKeys.keys = user.ssh.authorizedKeys;
  };
in
{
  users.users = builtins.mapAttrs mkUser inventory.users;

  security.sudo.wheelNeedsPassword = sudoUsers == { };
}
