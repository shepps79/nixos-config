# Slack. On pepper it runs on the Windows side.
{
  flake.nixosModules.slack =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.slack ];

      # Start minimised to the tray at Plasma login. niri starts it from its own
      # config (dotfiles/niri); OnlyShowIn keeps other sessions from doubling up.
      environment.etc."xdg/autostart/slack.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Slack
        Exec=slack --startup
        OnlyShowIn=KDE;
      '';
    };
}
