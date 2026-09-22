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

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    # base
    vim
    wget
    git
    stow

    # editors
    helix
    neovim

    # cli tools
    autojump
    bat
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

    # dev toolchains
    binutils
    dotnet-sdk_10
    gcc
    gnumake
    maven
    pipx
    pkg-config
    python3
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
