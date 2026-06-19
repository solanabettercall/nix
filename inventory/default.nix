{
  machines = import ./machines.nix;
  users = import ./users.nix;
  deploy = import ./deploy.nix;
  dns = import ./dns.nix;
  ports = import ./ports.nix;
  providers = import ./providers.nix;
  network = import ./network.nix;
  ssh = import ./ssh.nix;
  wireguard = import ./wireguard.nix;
  externalKnownHosts = import ./external-known-hosts.nix;
}
