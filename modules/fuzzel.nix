# Fuzzel Wayland launcher; needs a compositor, so not on pepper.
{
  flake.nixosModules.fuzzel =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.fuzzel ];
    };
}
