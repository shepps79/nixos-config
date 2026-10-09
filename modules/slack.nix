# Slack. On pepper it runs on the Windows side.
{
  flake.nixosModules.slack =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.slack ];
    };
}
