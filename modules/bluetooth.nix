# Bluetooth; Plasma's and noctalia's panels drive it. Not on pepper (WSL).
{
  flake.nixosModules.bluetooth = {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
  };
}
