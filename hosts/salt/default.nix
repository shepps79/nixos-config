# salt - bare metal laptop.
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../desktop/plasma.nix
    ../../desktop/hyprland.nix
    ../../desktop/niri.nix
  ];

  networking.hostName = "salt";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  programs.firefox.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];

  zramSwap.enable = true;
}
