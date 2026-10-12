# YouTube Music desktop client (pear-desktop, formerly th-ch/youtube-music).
{
  flake.nixosModules.youtubeMusic =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.pear-desktop ];
    };
}
