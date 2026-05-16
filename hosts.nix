{
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

  knownHosts = {
    github = {
      hostNames = [ "github.com" ];
      sshHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}
