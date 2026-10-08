# pepper - WSL2 under Windows. No bootloader, kernel, filesystems or desktop:
# the NixOS-WSL module and Windows supply all of that.
{ self, inputs, ... }:

{
  flake.nixosModules.pepperConfiguration = {
    imports = [
      inputs.nixos-wsl.nixosModules.default
      self.nixosModules.base
    ];

    wsl.enable = true;
    wsl.defaultUser = "richard";

    networking.hostName = "pepper";

    # No hardware-configuration.nix here to set it.
    nixpkgs.hostPlatform = "x86_64-linux";

    # First NixOS release installed on this machine. Never bump it on upgrade;
    # see https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "26.05";
  };
}
