# pi (pi.dev) coding agent, taken from unstable because stable lags far behind.
{ inputs, ... }:

{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pi-coding-agent
      ];
    };
}
