# herdr: persistent terminal workspace server for AI coding agents.
# Not in nixpkgs; built from the upstream flake (no binary cache, compiles from source).
{ inputs, ... }:

{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };
}
