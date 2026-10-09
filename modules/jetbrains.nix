# JetBrains Toolbox; it downloads and updates the IDEs themselves under $HOME.
{
  flake.nixosModules.jetbrains =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.jetbrains-toolbox ];
    };
}
