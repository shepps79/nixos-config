# pepper - WSL2 under Windows. The attribute name must match the hostname:
# bin/rebuild switches to .#$(hostname).
{ self, inputs, ... }:

{
  flake.nixosConfigurations.pepper = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.pepperConfiguration ];
  };
}
