# The overlay and the toolchain it provides live together, so dropping rust
# means deleting this one file.
{ inputs, ... }:

{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];

      environment.systemPackages = [
        (pkgs.rust-bin.nightly.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
          ];
        })
      ];
    };
}
