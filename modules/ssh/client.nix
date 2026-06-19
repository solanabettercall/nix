{ lib, config, ... }:
let
  inventory = config.local.inventory;
  hostName = config.networking.hostName;
  user = inventory.deploy.defaultUserId;
  commonSsh = {
    inherit user;
    identityFile = "~/.ssh/id_ed25519";
    identitiesOnly = true;
  };

  currentProviderId = inventory.providers.byMachine.${hostName};
  knownProviderIds = inventory.providers.definitions.${currentProviderId}.knownProviderIds;
  knownMachines = lib.filterAttrs
    (
      name: _machine: builtins.elem inventory.providers.byMachine.${name} knownProviderIds
    )
    inventory.machines;
  wireguardMembers = inventory.wireguard.mesh.members.byMachine;
  machinesWithWireguard = lib.filterAttrs
    (name: _machine:
      builtins.hasAttr name wireguardMembers
    )
    knownMachines;

  machinePort = _name: inventory.ports.public.ssh;
  wireguardAddress = name: wireguardMembers.${name}.address;

  knownHostNames = name: machine:
    [ name ] ++ (
      if machinePort name == inventory.ports.public.ssh
      then [ machine.address ]
      else [ "[${machine.address}]:${toString (machinePort name)}" ]
    ) ++ lib.optional (builtins.hasAttr name wireguardMembers) (wireguardAddress name);

  machineMatchBlock = name: machine: commonSsh // {
    hostname = machine.address;
    port = machinePort name;
  };

  wireguardMatchBlock = name: _machine: commonSsh // {
    hostname = wireguardAddress name;
    extraOptions = {
      # The current VPS-to-VPS WireGuard path resets OpenSSH's default
      # post-quantum hybrid KEX. Plain Curve25519 is stable there.
      KexAlgorithms = "curve25519-sha256";
    };
  };

  wireguardMatchBlocks = lib.mapAttrs'
    (
      name: machine:
        lib.nameValuePair "${name}-wg" (wireguardMatchBlock name machine)
    )
    machinesWithWireguard;

  machineKnownHosts = builtins.mapAttrs
    (
      name: machine: {
        hostNames = knownHostNames name machine;
        publicKey = inventory.ssh.hostKeys.byMachine.${name}.publicKey;
      }
    )
    knownMachines;

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
  programs.ssh.knownHosts = machineKnownHosts // inventory.externalKnownHosts;

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
