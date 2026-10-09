# Reads firmware tables; WSL2 doesn't expose them, so bare metal only.
{
  flake.nixosModules.dmidecode =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.dmidecode ];
    };
}
