# guvcview: UVC webcam viewer and capture tool with image controls.
{
  flake.nixosModules.guvcview =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.guvcview ];
    };
}
