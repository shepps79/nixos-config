# NetworkManager for wifi/ethernet. Not on pepper: WSL manages its networking.
{
  flake.nixosModules.networkmanager = {
    networking.networkmanager.enable = true;
  };
}
