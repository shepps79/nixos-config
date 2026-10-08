{
  description = "Richard's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    omp.url = "github:can1357/oh-my-pi";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Dendritic: every .nix file under ./modules is a flake-parts module, loaded
  # automatically. Paths with a component starting with `_` are skipped, which
  # is how plain NixOS modules (hardware-configuration) live in the tree.
  outputs =
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
