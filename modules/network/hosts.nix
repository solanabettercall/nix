{ lib, config, ... }:
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

  wireguardAddress = name:
    if builtins.hasAttr name wireguardMembers
    then wireguardMembers.${name}.address
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
