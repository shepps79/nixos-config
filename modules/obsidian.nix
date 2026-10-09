# Obsidian notes. On pepper it runs on the Windows side.
{
  flake.nixosModules.obsidian =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.obsidian ];
    };
}
