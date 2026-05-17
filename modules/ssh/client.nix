{ lib, inventory, machineProvider, ... }:
let
  user = "clackgot";
  commonSsh = {
    inherit user;
    identityFile = "~/.ssh/id_ed25519";
    identitiesOnly = true;
  };

  provider = inventory.providers.${machineProvider};
  knownProviderNames = provider.knownMachineProviders or [ machineProvider ];
  knownMachines = lib.mergeAttrsList (
    map (providerName: inventory.providers.${providerName}.machines) knownProviderNames
  );
  machinesWithWireguard = lib.filterAttrs (
    _name: machine: machine ? wireguard
  ) knownMachines;

  machinePort = machine: machine.sshPort or 22;

  knownHostNames = name: machine:
    [ name ] ++ (
      if machinePort machine == 22
      then [ machine.address ]
      else [ "[${machine.address}]:${toString (machinePort machine)}" ]
    ) ++ lib.optional (machine ? wireguard) machine.wireguard.address;

  machineMatchBlock = _name: machine: commonSsh // {
    hostname = machine.address;
    port = machinePort machine;
  };

  wireguardMatchBlock = _name: machine: commonSsh // {
    hostname = machine.wireguard.address;
    extraOptions = {
      # The current VPS-to-VPS WireGuard path resets OpenSSH's default
      # post-quantum hybrid KEX. Plain Curve25519 is stable there.
      KexAlgorithms = "curve25519-sha256";
    };
  };

  wireguardMatchBlocks = lib.mapAttrs' (
    name: machine:
      lib.nameValuePair "${name}-wg" (wireguardMatchBlock name machine)
  ) machinesWithWireguard;

  machineKnownHosts = builtins.mapAttrs (
    name: machine: {
      hostNames = knownHostNames name machine;
      publicKey = machine.sshHostKey;
    }
  ) knownMachines;

  githubMatchBlock = {
    "github.com" = commonSsh // {
      hostname = "github.com";
      user = "git";
    };
  };

  defaultMatchBlock = {
    "*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };
in
{
  programs.ssh.knownHosts = machineKnownHosts // inventory.external;

  home-manager.users.${user} = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks =
        (builtins.mapAttrs machineMatchBlock knownMachines)
        // wireguardMatchBlocks
        // githubMatchBlock
        // defaultMatchBlock;
    };
  };
}
