# 1Password desktop app, so the Brave extension unlocks with system auth.
{ inputs, ... }:

{
  flake.nixosModules.onepassword = {
    # Stable nixpkgs lags behind and the app nags to update, so take the GUI
    # from unstable.
    nixpkgs.overlays = [
      (final: prev: {
        # Imported rather than legacyPackages so it inherits allowUnfree.
        _1password-gui =
          (import inputs.nixpkgs-unstable {
            inherit (prev.stdenv.hostPlatform) system;
            inherit (prev) config;
          })._1password-gui;
      })
    ];

    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "richard" ];
    };
    # 1Password only talks to browsers on its built-in list; nixpkgs Brave isn't on it.
    environment.etc."1password/custom_allowed_browsers" = {
      text = "brave\n";
      mode = "0755";
    };

    # Start minimised to the tray at Plasma login. niri starts it from its own
    # config (dotfiles/niri); OnlyShowIn keeps other sessions from doubling up.
    environment.etc."xdg/autostart/1password.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=1Password
      Exec=1password --silent
      OnlyShowIn=KDE;
    '';
  };
}
