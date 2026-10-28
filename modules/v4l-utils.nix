# v4l-utils: v4l2-ctl and friends, for inspecting and scripting webcam controls.
{
  flake.nixosModules.v4lUtils =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.v4l-utils ];
    };
}
