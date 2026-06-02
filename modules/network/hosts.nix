{ lib, inventory, machineProvider, ... }:
let
  provider = inventory.providers.${machineProvider};
  knownProviderNames = provider.knownMachineProviders or [ machineProvider ];
  knownMachines = lib.mergeAttrsList (
    map (providerName: inventory.providers.${providerName}.machines) knownProviderNames
  );

  machineHostEntries = lib.flatten (
    lib.mapAttrsToList (
      name: machine:
        [
          {
            address = machine.address;
            aliases = [ name ];
          }
        ] ++ lib.optional (machine ? wireguard) {
          address = machine.wireguard.address;
          aliases = [ "${name}-wg" ];
        }
    ) knownMachines
  );

  hostsByAddress = lib.foldl' (
    result: entry:
      result // {
        ${entry.address} = (result.${entry.address} or [ ]) ++ entry.aliases;
      }
  ) { } machineHostEntries;
in
{
  networking.hosts = hostsByAddress;
}
