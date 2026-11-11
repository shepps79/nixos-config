# ffmpeg: CLI to record, convert and stream audio and video.
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.ffmpeg ];
    };
}
