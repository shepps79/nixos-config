{
  description = "Richard's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    omp.url = "github:can1357/oh-my-pi";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      omp,
      rust-overlay,
      ...
    }:
    let
      rustOverlay = {
        nixpkgs.overlays = [ rust-overlay.overlays.default ];
      };
    in
    {
      nixosConfigurations.salt = nixpkgs.lib.nixosSystem {
        modules = [
          ./common.nix
          rustOverlay
          omp.nixosModules.default
          ./hosts/salt
        ];
      };

      nixosConfigurations.pepper = nixpkgs.lib.nixosSystem {
        modules = [
          ./common.nix
          rustOverlay
          nixos-wsl.nixosModules.default
          omp.nixosModules.default
          ./hosts/pepper
        ];
      };

      # Wrap nixfmt so `nix fmt` with no path args formats the whole tree
      # instead of blocking on stdin (bare nixfmt reads stdin when given no
      # files, and never recurses a directory itself).
      formatter.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.writeShellApplication {
          name = "nixfmt-tree";
          runtimeInputs = [
            pkgs.nixfmt-rfc-style
            pkgs.findutils
          ];
          text = ''
            if [ "$#" -eq 0 ]; then set -- .; fi
            find "$@" -type f -name '*.nix' -exec nixfmt {} +
          '';
        };
    };
}
