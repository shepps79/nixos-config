# KDE Plasma 6 on X11. Also enables SDDM, which hyprland and niri register with.
{
  flake.modules.nixos.plasma =
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
    };
}
