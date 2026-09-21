# KDE Plasma 6 on X11. Swap for ./sway.nix in configuration.nix imports.
{ pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "za";
    variant = "";
  };

  environment.systemPackages = with pkgs; [ kdePackages.kate ];
}
