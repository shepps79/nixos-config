# omp (oh-my-pi) coding agent harness; upstream pi is in pi.nix.
{ inputs, ... }:

{
  flake.nixosModules.base = {
    imports = [ inputs.omp.nixosModules.default ];

    programs.omp.enable = true;

    # nix-community cache, as omp's own flake recommends. It has some of omp's
    # dependencies but not omp itself, so omp still builds locally.
    nix.settings.extra-substituters = [ "https://nix-community.cachix.org" ];
    nix.settings.extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
