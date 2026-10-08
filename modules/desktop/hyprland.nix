# Hyprland (Wayland) + Noctalia shell. Coexists with ./plasma.nix: SDDM lists
# both sessions, pick one at login. User config lives in dotfiles/hypr (stow).
{
  flake.nixosModules.hyprland =
    { pkgs, ... }:
    {
      # Wayland session + xdg-desktop-portal-hyprland. Registers the Hyprland
      # session with SDDM (which plasma.nix already enables).
      programs.hyprland.enable = true;

      # GTK portal for file pickers etc. under the Hyprland session.
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      environment.systemPackages = with pkgs; [
        noctalia-shell
        hyprpolkitagent
        kitty
        swww
        brightnessctl
        wl-clipboard
        cliphist
        matugen
        cava
      ];
    };
}
