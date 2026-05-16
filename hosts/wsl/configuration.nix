{ ... }:
{
  wsl = {
    enable = true;
    defaultUser = "clackgot";
    startMenuLaunchers = true;
  };

  networking.hostName = "wsl";
}
