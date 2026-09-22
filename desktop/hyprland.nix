# Hyprland (Wayland) + Noctalia shell. Coexists with ./plasma.nix: SDDM lists
# both sessions, pick one at login. User config lives in dotfiles/hypr (stow).
{ pkgs, ... }:

{
  # Wayland session + xdg-desktop-portal-hyprland. Registers the Hyprland
  # session with SDDM (which plasma.nix already enables).
  programs.hyprland.enable = true;

  # GTK portal for file pickers etc. under the Hyprland session.
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    noctalia-shell # the shell (bar, launcher, notifications); bundles quickshell
    hyprpolkitagent # polkit auth agent for the Hyprland session
    kitty # terminal (Hyprland ships no default)
    swww # wallpaper daemon Noctalia drives
    brightnessctl # backlight control for Noctalia
    wl-clipboard # clipboard for Wayland
    cliphist # clipboard history for Noctalia
    matugen # Material palette generation for Noctalia theming
    cava # audio visualiser widget
  ];
}
