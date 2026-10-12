# NVIDIA proprietary driver with PRIME offload, for salt's RTX 2000 Ada. The
# Intel iGPU drives the display; the dGPU powers down until something asks for
# it (CUDA, or `nvidia-offload <cmd>` for graphics). Check it with nvidia-smi.
{
  flake.nixosModules.nvidia =
    { config, pkgs, ... }:
    {
      hardware.graphics.enable = true;

      # Replaces nouveau. Also applies under Wayland sessions.
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        # Turing and newer: NVIDIA's open kernel module is the recommended one.
        open = true;
        modesetting.enable = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        # Suspend the dGPU's VRAM state across sleep, and power it off when idle.
        powerManagement.enable = true;
        powerManagement.finegrained = true;

        # Bus IDs from /sys/bus/pci/devices: Intel 0000:00:02.0, NVIDIA 0000:01:00.0.
        prime = {
          offload.enable = true;
          offload.enableOffloadCmd = true;
          intelBusId = "PCI:0@0:2:0";
          nvidiaBusId = "PCI:1@0:0:0";
        };
      };

      environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];
    };
}
