{ pkgs, ... }:
let
  inventory = import ../hosts.nix;
  machines = inventory.machines;
in
{
  users.users.clackgot = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = (import ../ssh-keys.nix).clackgot;
  };

  security.sudo.wheelNeedsPassword = false;

  programs.ssh.knownHosts = {
    moscow = {
      hostNames = [ "moscow" machines.moscow.address ];
      publicKey = machines.moscow.sshHostKey;
    };
    finland = {
      hostNames = [ "finland" machines.finland.address ];
      publicKey = machines.finland.sshHostKey;
    };
    github = {
      hostNames = inventory.knownHosts.github.hostNames;
      publicKey = inventory.knownHosts.github.sshHostKey;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.clackgot = {
      home = {
        username = "clackgot";
        homeDirectory = "/home/clackgot";
        sessionVariables.SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/key.txt";
        stateVersion = "24.11";
      };

      programs = {
        git = {
          enable = true;
          userName = "clackgot";
        };
        ssh = {
          enable = true;
          matchBlocks = {
            "github.com" = {
              hostname = "github.com";
              user = "git";
              identityFile = "~/.ssh/id_ed25519";
              identitiesOnly = true;
            };
            moscow = {
              hostname = machines.moscow.address;
              user = "clackgot";
              identityFile = "~/.ssh/id_ed25519";
              identitiesOnly = true;
            };
            finland = {
              hostname = machines.finland.address;
              user = "clackgot";
              identityFile = "~/.ssh/id_ed25519";
              identitiesOnly = true;
            };
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    bat
    curl
    eza
    fd
    fzf
    git
    htop
    jq
    just
    neovim
    ripgrep
    sops
    tree
    unzip
    vim
    wget
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Moscow";

  system.stateVersion = "24.11";
}
