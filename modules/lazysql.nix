# lazysql: TUI database client, in the style of lazygit.
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.lazysql ];
    };
}
