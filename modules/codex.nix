# OpenAI Codex coding agent CLI.
{
  flake.nixosModules.codex =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.codex ];
    };
}
