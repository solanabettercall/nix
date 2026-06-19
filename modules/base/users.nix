{ config, lib, ... }:
let
  inherit (config.local) inventory;
  sudoUsers = lib.filterAttrs (_userId: user: user.sudo) inventory.users;
  resolveKeyIds = keyIds: map (keyId: inventory.ssh.publicKeys.${keyId}) keyIds;
  mkUser = userId: user: {
    inherit (user) isNormalUser;
    extraGroups = lib.optional user.sudo "wheel";
    hashedPasswordFile = config.sops.secrets."users/${userId}/password_hash".path;
    openssh.authorizedKeys.keys = resolveKeyIds (inventory.ssh.authorizedKeys.byUser.${userId} or [ ]);
  };
in
{
  users.users = builtins.mapAttrs mkUser inventory.users;

  security.sudo.wheelNeedsPassword = sudoUsers == { };
}
