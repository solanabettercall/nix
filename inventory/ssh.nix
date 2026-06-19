{
  publicKeys = {
    clackgot-xorek = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPaR5chAudCG96WFgYZ347g2SdW1bt/Sn0B51SKDjd+G clackgot@91.108.227.42";
    clackgot-local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExWDHGnGypwAUH93//GexyPBO2vMeuMKfrxbat8jnI0 clackgot";
    ares-host-ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8KXMEwSy8FaWzTMnyRK+cp9PK6yNy/hcHEXfn8RPE0 root@ares";
    hermes-host-ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSYsKs7B7dQUO244ty/PxzS17SLZqy47RHmlZKAG44r root@hermes";
    github-ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  authorizedKeys.byUser = {
    clackgot = [
      "clackgot-xorek"
      "clackgot-local"
    ];
  };

  hostKeys.byMachine = {
    ares.publicKeyId = "ares-host-ed25519";
    hermes.publicKeyId = "hermes-host-ed25519";
  };
}
