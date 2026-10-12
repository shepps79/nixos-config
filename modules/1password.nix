# 1Password desktop app, so the Brave extension unlocks with system auth.
{
  flake.nixosModules.onepassword = {
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
