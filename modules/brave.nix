# Brave browser. No NixOS programs.* module, so install the package directly.
{
  flake.nixosModules.brave =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.brave ];
    };
}
