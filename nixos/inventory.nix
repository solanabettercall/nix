{ lib, inventory, localLib, ... }:
let
  inherit (lib) mkOption types;
  cfg = inventory;

  machineIds = builtins.attrNames cfg.machines;
  userIds = builtins.attrNames cfg.users;
  subnetIds = builtins.attrNames cfg.network.subnets;
  sshPublicKeyIds = builtins.attrNames cfg.ssh.publicKeys;
  wireguardPublicKeyIds = builtins.attrNames cfg.wireguard.publicKeys;
  knownMachine = machineId: builtins.hasAttr machineId cfg.machines;
  knownUser = userId: builtins.hasAttr userId cfg.users;
  knownSubnet = subnetId: builtins.hasAttr subnetId cfg.network.subnets;
  knownSshPublicKey = publicKeyId: builtins.hasAttr publicKeyId cfg.ssh.publicKeys;
  knownWireGuardPublicKey = publicKeyId: builtins.hasAttr publicKeyId cfg.wireguard.publicKeys;
  isIpv4Subnet24 = subnet: localLib.network.ipv4.isSubnet24 subnet;
  hostNumbers = allocation: (builtins.attrValues allocation.machines) ++ (builtins.attrValues allocation.clients);
  hasDuplicateHostNumbers = allocation:
    let
      numbers = hostNumbers allocation;
    in
    builtins.length numbers != builtins.length (lib.unique numbers);

  unknownProviderMachines = lib.filterAttrs
    (
      machineId: _providerId: !(knownMachine machineId)
    )
    cfg.providers.byMachine;

  unknownProviderIds = lib.filterAttrs
    (
      _machineId: providerId: !(builtins.hasAttr providerId cfg.providers.definitions)
    )
    cfg.providers.byMachine;

  unknownDnsTargets = lib.filterAttrs
    (
      _recordId: record: record.target ? machineId && !(knownMachine record.target.machineId)
    )
    cfg.dns.records;

  unknownStaticIpv4Machines = lib.filterAttrs
    (
      machineId: _network: !(knownMachine machineId)
    )
    cfg.network.staticIpv4.byMachine;

  invalidSubnets = lib.filterAttrs
    (
      _subnetId: subnet: !(isIpv4Subnet24 subnet)
    )
    cfg.network.subnets;

  unknownAllocationSubnets = lib.filterAttrs
    (
      subnetId: _allocation: !(knownSubnet subnetId)
    )
    cfg.network.allocations;

  unknownAllocationMachines = lib.filterAttrs
    (
      _subnetId: allocation: builtins.any (machineId: !(knownMachine machineId)) (builtins.attrNames allocation.machines)
    )
    cfg.network.allocations;

  duplicateAllocationHostNumbers = lib.filterAttrs
    (
      _subnetId: hasDuplicateHostNumbers
    )
    cfg.network.allocations;

  unknownSshHostKeyMachines = lib.filterAttrs
    (
      machineId: _hostKey: !(knownMachine machineId)
    )
    cfg.ssh.hostKeys.byMachine;

  unknownAuthorizedKeyUsers = lib.filterAttrs
    (
      userId: _keyIds: !(knownUser userId)
    )
    cfg.ssh.authorizedKeys.byUser;

  unknownAuthorizedKeyIds = lib.filterAttrs
    (
      _userId: keyIds: builtins.any (keyId: !(knownSshPublicKey keyId)) keyIds
    )
    cfg.ssh.authorizedKeys.byUser;

  unknownHostKeyIds = lib.filterAttrs
    (
      _machineId: hostKey: !(knownSshPublicKey hostKey.publicKeyId)
    )
    cfg.ssh.hostKeys.byMachine;

  unknownExternalKnownHostKeyIds = lib.filterAttrs
    (
      _knownHostId: knownHost: !(knownSshPublicKey knownHost.publicKeyId)
    )
    cfg.externalKnownHosts;

  unknownWireGuardMachines = lib.filterAttrs
    (
      machineId: _member: !(knownMachine machineId)
    )
    cfg.wireguard.mesh.members.byMachine;

  unknownWireGuardMemberPublicKeyIds = lib.filterAttrs
    (
      _machineId: member: !(knownWireGuardPublicKey member.publicKeyId)
    )
    cfg.wireguard.mesh.members.byMachine;

  unknownWireGuardClientPublicKeyIds = lib.filterAttrs
    (
      _clientId: client: !(knownWireGuardPublicKey client.publicKeyId)
    )
    cfg.wireguard.mesh.clients;

  missingWireGuardMachineAllocations = lib.filterAttrs
    (
      machineId: _member: !(builtins.hasAttr machineId cfg.network.allocations.${cfg.wireguard.mesh.subnetId}.machines)
    )
    cfg.wireguard.mesh.members.byMachine;

  missingWireGuardClientAllocations = lib.filterAttrs
    (
      clientId: _client: !(builtins.hasAttr clientId cfg.network.allocations.${cfg.wireguard.mesh.subnetId}.clients)
    )
    cfg.wireguard.mesh.clients;

  unknownAmneziaWireGuardMachines = lib.filterAttrs
    (
      machineId: _server: !(knownMachine machineId)
    )
    cfg.wireguard.amnezia.servers.byMachine;

  knownAmneziaWireGuardClient = clientId: builtins.hasAttr clientId cfg.wireguard.amnezia.clients;

  unknownAmneziaWireGuardServerClients = lib.filterAttrs
    (
      _machineId: server: builtins.any (clientId: !(knownAmneziaWireGuardClient clientId)) server.clients
    )
    cfg.wireguard.amnezia.servers.byMachine;

  unknownAmneziaWireGuardClientPublicKeyIds = lib.filterAttrs
    (
      _clientId: client: !(knownWireGuardPublicKey client.publicKeyId)
    )
    cfg.wireguard.amnezia.clients;

  missingAmneziaWireGuardMachineAllocations = lib.filterAttrs
    (
      machineId: _server: !(builtins.hasAttr machineId cfg.network.allocations.${cfg.wireguard.amnezia.subnetId}.machines)
    )
    cfg.wireguard.amnezia.servers.byMachine;

  missingAmneziaWireGuardClientAllocations = lib.filterAttrs
    (
      clientId: _client: !(builtins.hasAttr clientId cfg.network.allocations.${cfg.wireguard.amnezia.subnetId}.clients)
    )
    cfg.wireguard.amnezia.clients;

  machineIdType = types.enum machineIds;
  userIdType = types.enum userIds;
  subnetIdType = types.enum subnetIds;
  sshPublicKeyIdType = types.enum sshPublicKeyIds;
  wireguardPublicKeyIdType = types.enum wireguardPublicKeyIds;
  allocationHostType = types.ints.between 1 254;
in
{
  options.local.inventory = mkOption {
    description = "Typed infrastructure inventory.";
    type = types.submodule {
      options = {
        machines = mkOption {
          description = "Primary machine table. Keys are machine IDs; values contain only primary management addresses.";
          type = types.attrsOf (types.submodule {
            options.address = mkOption {
              type = types.str;
              description = "Primary management address.";
            };
          });
        };

        users = mkOption {
          description = "User table. Keys are user IDs.";
          type = types.attrsOf (types.submodule {
            options = {
              isNormalUser = mkOption { type = types.bool; };
              sudo = mkOption { type = types.bool; };
            };
          });
        };

        deploy.defaultUserId = mkOption {
          type = userIdType;
          description = "Default user ID for deploy and generated SSH client config.";
        };

        dns = mkOption {
          type = types.submodule {
            options = {
              rootDomain = mkOption { type = types.str; };
              acmeEmail = mkOption { type = types.str; };
              records = mkOption {
                type = types.attrsOf (types.submodule {
                  options = {
                    fqdn = mkOption { type = types.str; };
                    target = mkOption {
                      type = types.submodule {
                        options.machineId = mkOption {
                          type = machineIdType;
                          description = "Foreign key into local.inventory.machines.";
                        };
                      };
                    };
                  };
                });
              };
            };
          };
        };

        ports = mkOption {
          type = types.attrsOf (types.attrsOf types.port);
        };

        providers = mkOption {
          type = types.submodule {
            options = {
              byMachine = mkOption {
                type = types.attrsOf types.str;
              };
              definitions = mkOption {
                type = types.attrsOf (types.submodule {
                  options.knownProviderIds = mkOption {
                    type = types.listOf types.str;
                  };
                });
              };
            };
          };
        };

        network = {
          staticIpv4.byMachine = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                interface = mkOption { type = types.str; };
                prefixLength = mkOption { type = types.ints.unsigned; };
                gateway = mkOption {
                  type = types.submodule {
                    options = {
                      address = mkOption { type = types.str; };
                      interface = mkOption {
                        type = types.nullOr types.str;
                        default = null;
                      };
                    };
                  };
                };
              };
            });
          };

          subnets = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                address = mkOption {
                  type = types.str;
                  description = "IPv4 network address, for example 10.77.0.0.";
                };
                prefixLength = mkOption {
                  type = types.enum [ 24 ];
                  description = "Subnet prefix length. Only /24 allocations are currently supported.";
                };
              };
            });
          };

          allocations = mkOption {
            type = types.attrsOf (types.submodule {
              options = {
                machines = mkOption {
                  type = types.attrsOf allocationHostType;
                };
                clients = mkOption {
                  type = types.attrsOf allocationHostType;
                };
              };
            });
          };
        };

        ssh = mkOption {
          type = types.submodule {
            options = {
              publicKeys = mkOption {
                type = types.attrsOf types.str;
              };
              authorizedKeys.byUser = mkOption {
                type = types.attrsOf (types.listOf sshPublicKeyIdType);
              };
              hostKeys.byMachine = mkOption {
                type = types.attrsOf (types.submodule {
                  options.publicKeyId = mkOption {
                    type = sshPublicKeyIdType;
                  };
                });
              };
            };
          };
        };

        wireguard = mkOption {
          type = types.submodule {
            options = {
              publicKeys = mkOption {
                type = types.attrsOf types.str;
              };
              mesh = mkOption {
                type = types.submodule {
                  options = {
                    subnetId = mkOption { type = subnetIdType; };
                    interface = mkOption { type = types.str; };
                    mtu = mkOption { type = types.nullOr types.ints.unsigned; };
                    persistentKeepalive = mkOption { type = types.nullOr types.ints.unsigned; };
                    trusted = mkOption { type = types.bool; };
                    members.byMachine = mkOption {
                      type = types.attrsOf (types.submodule {
                        options = {
                          listenPort = mkOption { type = types.port; };
                          publicKeyId = mkOption { type = wireguardPublicKeyIdType; };
                        };
                      });
                    };
                    clients = mkOption {
                      type = types.attrsOf (types.submodule {
                        options = {
                          publicKeyId = mkOption { type = wireguardPublicKeyIdType; };
                        };
                      });
                    };
                  };
                };
              };
              amnezia = mkOption {
                type = types.submodule {
                  options = {
                    subnetId = mkOption { type = subnetIdType; };
                    interface = mkOption { type = types.str; };
                    extraOptions = mkOption {
                      type = types.attrsOf types.int;
                    };
                    servers.byMachine = mkOption {
                      type = types.attrsOf (types.submodule {
                        options = {
                          listenPort = mkOption { type = types.port; };
                          clients = mkOption { type = types.listOf types.str; };
                        };
                      });
                    };
                    clients = mkOption {
                      type = types.attrsOf (types.submodule {
                        options = {
                          publicKeyId = mkOption { type = wireguardPublicKeyIdType; };
                        };
                      });
                    };
                  };
                };
              };
            };
          };
        };

        externalKnownHosts = mkOption {
          type = types.attrsOf (types.submodule {
            options = {
              hostNames = mkOption { type = types.listOf types.str; };
              publicKeyId = mkOption { type = sshPublicKeyIdType; };
            };
          });
        };
      };
    };
  };

  config = {
    local.inventory = cfg;

    assertions = [
      {
        assertion = unknownProviderMachines == { };
        message = "local.inventory.providers.byMachine references unknown machines: ${toString (builtins.attrNames unknownProviderMachines)}";
      }
      {
        assertion = unknownProviderIds == { };
        message = "local.inventory.providers.byMachine references unknown providers: ${toString (builtins.attrNames unknownProviderIds)}";
      }
      {
        assertion = unknownDnsTargets == { };
        message = "local.inventory.dns.records references unknown machines: ${toString (builtins.attrNames unknownDnsTargets)}";
      }
      {
        assertion = unknownStaticIpv4Machines == { };
        message = "local.inventory.network.staticIpv4.byMachine references unknown machines: ${toString (builtins.attrNames unknownStaticIpv4Machines)}";
      }
      {
        assertion = invalidSubnets == { };
        message = "local.inventory.network.subnets contains unsupported subnets; only IPv4 /24 network addresses ending in .0 are currently supported: ${toString (builtins.attrNames invalidSubnets)}";
      }
      {
        assertion = unknownAllocationSubnets == { };
        message = "local.inventory.network.allocations references unknown subnets: ${toString (builtins.attrNames unknownAllocationSubnets)}";
      }
      {
        assertion = unknownAllocationMachines == { };
        message = "local.inventory.network.allocations references unknown machines in subnets: ${toString (builtins.attrNames unknownAllocationMachines)}";
      }
      {
        assertion = duplicateAllocationHostNumbers == { };
        message = "local.inventory.network.allocations contains duplicate host numbers in subnets: ${toString (builtins.attrNames duplicateAllocationHostNumbers)}";
      }
      {
        assertion = unknownSshHostKeyMachines == { };
        message = "local.inventory.ssh.hostKeys.byMachine references unknown machines: ${toString (builtins.attrNames unknownSshHostKeyMachines)}";
      }
      {
        assertion = unknownAuthorizedKeyUsers == { };
        message = "local.inventory.ssh.authorizedKeys.byUser references unknown users: ${toString (builtins.attrNames unknownAuthorizedKeyUsers)}";
      }
      {
        assertion = unknownAuthorizedKeyIds == { };
        message = "local.inventory.ssh.authorizedKeys.byUser references unknown public keys for users: ${toString (builtins.attrNames unknownAuthorizedKeyIds)}";
      }
      {
        assertion = unknownHostKeyIds == { };
        message = "local.inventory.ssh.hostKeys.byMachine references unknown public keys for machines: ${toString (builtins.attrNames unknownHostKeyIds)}";
      }
      {
        assertion = unknownExternalKnownHostKeyIds == { };
        message = "local.inventory.externalKnownHosts references unknown public keys: ${toString (builtins.attrNames unknownExternalKnownHostKeyIds)}";
      }
      {
        assertion = unknownWireGuardMachines == { };
        message = "local.inventory.wireguard.mesh.members.byMachine references unknown machines: ${toString (builtins.attrNames unknownWireGuardMachines)}";
      }
      {
        assertion = unknownWireGuardMemberPublicKeyIds == { };
        message = "local.inventory.wireguard.mesh.members.byMachine references unknown WireGuard public keys for machines: ${toString (builtins.attrNames unknownWireGuardMemberPublicKeyIds)}";
      }
      {
        assertion = unknownWireGuardClientPublicKeyIds == { };
        message = "local.inventory.wireguard.mesh.clients references unknown WireGuard public keys for clients: ${toString (builtins.attrNames unknownWireGuardClientPublicKeyIds)}";
      }
      {
        assertion = missingWireGuardMachineAllocations == { };
        message = "local.inventory.wireguard.mesh.members.byMachine has machines without allocation in subnet ${cfg.wireguard.mesh.subnetId}: ${toString (builtins.attrNames missingWireGuardMachineAllocations)}";
      }
      {
        assertion = missingWireGuardClientAllocations == { };
        message = "local.inventory.wireguard.mesh.clients has clients without allocation in subnet ${cfg.wireguard.mesh.subnetId}: ${toString (builtins.attrNames missingWireGuardClientAllocations)}";
      }
      {
        assertion = unknownAmneziaWireGuardMachines == { };
        message = "local.inventory.wireguard.amnezia.servers.byMachine references unknown machines: ${toString (builtins.attrNames unknownAmneziaWireGuardMachines)}";
      }
      {
        assertion = unknownAmneziaWireGuardServerClients == { };
        message = "local.inventory.wireguard.amnezia.servers.byMachine references unknown AmneziaWG clients for machines: ${toString (builtins.attrNames unknownAmneziaWireGuardServerClients)}";
      }
      {
        assertion = unknownAmneziaWireGuardClientPublicKeyIds == { };
        message = "local.inventory.wireguard.amnezia.clients references unknown WireGuard public keys: ${toString (builtins.attrNames unknownAmneziaWireGuardClientPublicKeyIds)}";
      }
      {
        assertion = missingAmneziaWireGuardMachineAllocations == { };
        message = "local.inventory.wireguard.amnezia.servers.byMachine has machines without allocation in subnet ${cfg.wireguard.amnezia.subnetId}: ${toString (builtins.attrNames missingAmneziaWireGuardMachineAllocations)}";
      }
      {
        assertion = missingAmneziaWireGuardClientAllocations == { };
        message = "local.inventory.wireguard.amnezia.clients has clients without allocation in subnet ${cfg.wireguard.amnezia.subnetId}: ${toString (builtins.attrNames missingAmneziaWireGuardClientAllocations)}";
      }
    ];
  };
}
