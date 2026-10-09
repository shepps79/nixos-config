# Meld graphical diff/merge tool.
{
  flake.nixosModules.meld =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.meld ];
    };
}
