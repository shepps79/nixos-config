# pepper - WSL2 under Windows. No bootloader, kernel, filesystems or desktop:
# the NixOS-WSL module and Windows supply all of that.
{ ... }:

{
  wsl.enable = true;
  wsl.defaultUser = "richard";

  networking.hostName = "pepper";

  # No hardware-configuration.nix here to set it.
  nixpkgs.hostPlatform = "x86_64-linux";
}
