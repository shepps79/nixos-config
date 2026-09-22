# Niri (scrollable-tiling Wayland compositor) + Noctalia shell. Coexists with
# ./plasma.nix and ./hyprland.nix: SDDM lists every session, pick one at login.
# User config lives in dotfiles/niri (stow); niri ships a default config too.
{ pkgs, ... }:

{
  # nixpkgs has no `programs.niri` module, so register the Wayland session the
  # niri package ships (passthru.providedSessions = [ "niri" ]) with SDDM, which
  # plasma.nix already enables.
  services.displayManager.sessionPackages = [ pkgs.niri ];

  # GTK portal for file pickers etc.; niri ships its own portals.conf.
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    niri # the compositor
    noctalia-shell # the shell (bar, launcher, notifications); bundles quickshell
    hyprpolkitagent # polkit auth agent for the session
    kitty # terminal (niri ships no default)
    swww # wallpaper daemon Noctalia drives
    brightnessctl # backlight control for Noctalia
    wl-clipboard # clipboard for Wayland
    cliphist # clipboard history for Noctalia
    matugen # Material palette generation for Noctalia theming
    cava # audio visualiser widget
  ];
}
