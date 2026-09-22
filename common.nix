# Shared by every host. Hardware, boot and desktop live in ./hosts/<name>.
{ pkgs, ... }:

{
  imports = [ ./nonfree.nix ];

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_ZA.UTF-8";

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users."richard" = {
    isNormalUser = true;
    description = "Richard Shephard";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "richard" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Binary cache for oh-my-pi (omp); avoids building it from source.
  nix.settings.extra-substituters = [ "https://nix-community.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # AI coding agent harnesses: omp (oh-my-pi) + pi (upstream).
  # programs.omp.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    stow
    neovim
    autojump
    bats
    btop
    curl
    delta
    dmidecode
    gh
    gnupg
    htop
    inotify-tools
    jq
    mc
    nano
    rclone
    ripgrep
    rsync
    shellcheck
    tmux
    tree
    unzip
    xdg-utils
    zip
    binutils
    bun
    dotnet-sdk_10
    gcc
    gnumake
    maven
    #pipx
    pi-coding-agent
    pkg-config
    python3
    fuzzel
    (rust-bin.nightly.latest.default.override {
      extensions = [
        "rust-src"
        "rust-analyzer"
      ];
    })
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
