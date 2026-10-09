# Provides the FHS dynamic loader NixOS lacks, so prebuilt binaries
# (nvm's Node builds, downloaded tools) run unpatched.
{
  flake.nixosModules.base = {
    programs.nix-ld.enable = true;
  };
}
