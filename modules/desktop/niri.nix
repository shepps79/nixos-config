# Niri (scrollable-tiling Wayland compositor) + Noctalia shell. Coexists with
# ./plasma.nix and ./hyprland.nix: SDDM lists every session, pick one at login.
# User config lives in dotfiles/niri and dotfiles/noctalia (stow), ported from
# github:vimjoyer/nixconf. niri finds xwayland-satellite on PATH.
{
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      # nixpkgs has no `programs.niri` module, so register the Wayland session the
      # niri package ships (passthru.providedSessions = [ "niri" ]) with SDDM, which
      # plasma.nix already enables.
      services.displayManager.sessionPackages = [ pkgs.niri ];

      # GTK portal for file pickers etc.; niri ships its own portals.conf.
      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # niri starts nothing to answer polkit prompts, so actions that ask for a
      # password (fprintd-enroll, GUI admin tasks) fail with "Not Authorized".
      # The unit's ConditionEnvironment=WAYLAND_DISPLAY skips it under Plasma X11,
      # which has its own agent. Registering the package keeps its unit and makes
      # this a drop-in; without it NixOS writes a unit with no ExecStart.
      systemd.packages = [ pkgs.hyprpolkitagent ];
      systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

      environment.systemPackages = with pkgs; [
        niri
        noctalia-shell
        hyprpolkitagent
        kitty
        swww
        brightnessctl
        wl-clipboard
        swappy
        pwvucontrol
        xwayland-satellite
        cliphist
        matugen
        cava
        # noctalia writes its light/dark mode to org.gnome.desktop.interface with
        # this, so GTK, Electron and portal clients follow it.
        dconf
      ];
    };
}
