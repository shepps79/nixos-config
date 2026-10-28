# cameractrls: GUI for webcam controls (brightness, contrast, exposure).
{
  flake.nixosModules.cameractrls =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.cameractrls-gtk4 ];
    };
}
