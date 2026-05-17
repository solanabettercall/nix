{ lib, ... }:
{
  boot.blacklistedKernelModules = [ "vmwgfx" ];
  virtualisation.virtualbox.guest.enable = lib.mkForce false;
}
