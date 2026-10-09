# Zoom. On pepper it runs on the Windows side.
{
  flake.nixosModules.zoom =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.zoom-us ];
    };
}
