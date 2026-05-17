{ inventory, machineProvider, ... }:
let
  provider = inventory.providers.${machineProvider};
  machines = builtins.foldl' (
    knownMachines: knownProvider:
      knownMachines // inventory.providers.${knownProvider}.machines
  ) { } provider.knownMachineProviders;

  sshPort = machine: machine.sshPort or 22;

  sshHostNames = name: machine:
    [ name ] ++ (
      if sshPort machine != 22
      then [ "[${machine.address}]:${toString (sshPort machine)}" ]
      else [ machine.address ]
    );

  mkKnownHost = name: machine: {
    hostNames = sshHostNames name machine;
    publicKey = machine.sshHostKey;
  };

  mkMatchBlock = name: machine: {
    hostname = machine.address;
    user = "clackgot";
    port = sshPort machine;
    identityFile = "~/.ssh/id_ed25519";
    identitiesOnly = true;
  };
in
{
  programs.ssh.knownHosts =
    (builtins.mapAttrs mkKnownHost machines) // inventory.external;

  home-manager.users.clackgot = {
    programs.ssh = {
      enable = true;
      matchBlocks = (builtins.mapAttrs mkMatchBlock machines) // {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };
      };
    };
  };
}
