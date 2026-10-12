# Compressed swap in RAM.
{
  flake.nixosModules.zram = {
    zramSwap.enable = true;
  };
}
