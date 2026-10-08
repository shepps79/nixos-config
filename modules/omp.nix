# AI coding agent harnesses: omp (oh-my-pi) + pi (upstream).
{ inputs, ... }:

{
  flake.nixosModules.base = {
    imports = [ inputs.omp.nixosModules.default ];

    # programs.omp.enable = true;

    # Binary cache for oh-my-pi (omp); avoids building it from source.
    nix.settings.extra-substituters = [ "https://nix-community.cachix.org" ];
    nix.settings.extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
