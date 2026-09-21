{
  description = "Richard's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      ...
    }:
    {
      # Host names are seasoning. bin/rebuild resolves --flake . by hostname.
      nixosConfigurations.salt = nixpkgs.lib.nixosSystem {
        modules = [
          ./common.nix
          ./hosts/salt
        ];
      };

      nixosConfigurations.pepper = nixpkgs.lib.nixosSystem {
        modules = [
          ./common.nix
          nixos-wsl.nixosModules.default
          ./hosts/pepper
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
