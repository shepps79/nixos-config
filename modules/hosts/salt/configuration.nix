# salt - bare metal laptop.
{ self, ... }:

{
  flake.nixosModules.saltConfiguration =
    { pkgs, ... }:
    {
      imports = with self.nixosModules; [
        saltHardware
        base
        plasma
        hyprland
        niri
        fonts
        onepassword
        bingWallpaper
        obsidian
        zoom
        slack
        vscode
        wezterm
        fuzzel
        dmidecode
        canonG3070
        cupsPdf
        clamav
        meld
        codex
        media
        jetbrains
        onedrive
        bluetooth
        noiseCancelling
        youtubeMusic
        powerProfiles
        brave
        networkmanager
        printing
        pipewire
        openssh
        zram
        nvidia
        lmstudio
        fingerprint
        faceUnlock
      ];

      networking.hostName = "salt";

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # Cap the systemd-boot menu to the last few generations. Keep this in step
      # with the count bin/rebuild trims to, so no boot entry outlives the
      # generation it points at.
      boot.loader.systemd-boot.configurationLimit = 4;

      # Pinned: stable's nvidia driver fails to build against 7.3 (linuxPackages_latest).
      boot.kernelPackages = pkgs.linuxPackages_6_18;

      boot.initrd.systemd.enable = true;
      boot.initrd.luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];

      # First NixOS release installed on this machine. Never bump it on upgrade;
      # see https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      system.stateVersion = "26.05";
    };
}
