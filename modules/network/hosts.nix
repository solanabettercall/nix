{ lib, config, localLib, ... }:
let
  inherit (config.local) inventory;
  inherit (config.networking) hostName;
  currentProviderId = inventory.providers.byMachine.${hostName};
  inherit (inventory.providers.definitions.${currentProviderId}) knownProviderIds;
  knownMachines = lib.filterAttrs
    (
      name: _machine: builtins.elem inventory.providers.byMachine.${name} knownProviderIds
    )
    inventory.machines;
  wireguardMembers = inventory.wireguard.mesh.members.byMachine;
  wireguardSubnet = inventory.network.subnets.${inventory.wireguard.mesh.subnetId};
  wireguardSubnetAddress = localLib.network.ipv4.addressInSubnet24 wireguardSubnet;

  wireguardAddress = name:
    if builtins.hasAttr name wireguardMembers
    then wireguardSubnetAddress inventory.network.allocations.${inventory.wireguard.mesh.subnetId}.machines.${name}
    else null;

  machineHostEntries = lib.flatten (
    lib.mapAttrsToList
      (
        name: machine:
          [
            {
              inherit (machine) address;
              aliases = [ name ];
            }
          ] ++ lib.optional (wireguardAddress name != null) {
            address = wireguardAddress name;
            aliases = [ "${name}-wg" ];
          }
      )
      knownMachines
  );

  hostsByAddress = lib.foldl'
    (
      result: entry:
        result // {
          ${entry.address} = (result.${entry.address} or [ ]) ++ entry.aliases;
        }
    )
    { }
    machineHostEntries;
in
{
  networking.hosts = hostsByAddress;
}
