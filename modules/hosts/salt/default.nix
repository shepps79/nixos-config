# salt - bare metal laptop. The attribute name must match the hostname:
# bin/rebuild switches to .#$(hostname).
{ self, inputs, ... }:

{
  flake.nixosConfigurations.salt = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.saltConfiguration ];
  };
}
