{
  providers = {
    xorek = {
      knownMachineProviders = [ "xorek" ];
      machines = {
        moscow = {
          address = "31.76.230.57";
          prefixLength = 24;
          gateway = "31.76.230.1";
          sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBc95eQyBa8K/u8xIORn6ES8PQvgB5WTdeB8LRK6OsNH root@moscow";
        };

        finland = {
          address = "109.206.243.227";
          prefixLength = 32;
          gateway = "172.0.0.1";
          gatewayInterface = "ens3";
          sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8KXMEwSy8FaWzTMnyRK+cp9PK6yNy/hcHEXfn8RPE0 root@finland";
        };
      };
    };

    virtualbox = {
      knownMachineProviders = [ "xorek" "virtualbox" ];
      machines = {
        nixos1 = {
          address = "192.168.10.50";
          interface = "enp0s3";
          prefixLength = 24;
          gateway = "192.168.10.1";
          sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSYsKs7B7dQUO244ty/PxzS17SLZqy47RHmlZKAG44r root@nixos1";
        };
      };
    };
  };

  external = {
    github = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}
