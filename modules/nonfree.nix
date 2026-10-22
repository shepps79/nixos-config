# Non-free applications, in one file so the unfree surface is easy to audit.
{ inputs, ... }:

{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = [
        # Stable lags several minor versions behind and the API gates on
        # recent versions, so take it from unstable.
        # Imported rather than legacyPackages so it inherits allowUnfree.
        (import inputs.nixpkgs-unstable {
          inherit (pkgs.stdenv.hostPlatform) system;
          inherit (pkgs) config;
        }).claude-code
      ];
    };
}
