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

      # Noctalia's lock screen would otherwise use login, which is password-only
      # so sddm unlocks KWallet. Its own service keeps face and fingerprint.
      security.pam.services.noctalia = { };
      environment.sessionVariables.NOCTALIA_PAM_SERVICE = "noctalia";

      environment.systemPackages = with pkgs; [
        noctalia-shell
        hyprpolkitagent
        kitty
        awww
        brightnessctl
        wl-clipboard
        cliphist
        matugen
        cava
      ];
    };
}
