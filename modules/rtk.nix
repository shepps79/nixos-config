# rtk: CLI proxy that reduces LLM token consumption on common dev commands.
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.rtk ];
    };
}
