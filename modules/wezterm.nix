# WezTerm terminal emulator. On pepper, Windows hosts the terminal.
{
  flake.nixosModules.wezterm =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.wezterm ];
    };
}
