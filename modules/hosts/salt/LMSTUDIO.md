# LM Studio with CUDA on salt

Runs local LLMs on salt's NVIDIA RTX 2000 Ada Laptop GPU (AD107, 8 GB VRAM)
using LM Studio's CUDA llama.cpp runtime.

- Driver: `modules/nvidia.nix` (`flake.nixosModules.nvidia`), imported by salt
  only. NVIDIA's open kernel module replaces nouveau. PRIME offload keeps the
  Intel iGPU on the display and powers the dGPU down when idle. It also
  provides `nvidia-offload <cmd>`, `nvidia-smi` and `nvtop`.
- App: `modules/lmstudio.nix` (`flake.nixosModules.lmstudio`). LM Studio
  downloads its own CUDA runtime, so no CUDA toolkit is built from nixpkgs;
  it only needs the driver.

## 1. Activate

```bash
bin/rebuild
```

Then reboot. nouveau stays loaded in the running kernel until you do.

## 2. Check the driver

```bash
nvidia-smi
```

It should list the RTX 2000 Ada with about 8 GB. If `lsmod | grep nouveau`
still prints anything, the old driver is still loaded.

## 3. Pick the CUDA runtime

Start LM Studio, open the runtime settings (Ctrl+Shift+R) and select the
**CUDA llama.cpp** runtime. Download it there if it isn't installed.

## 4. Load a model

Set GPU offload to max when the model fits in VRAM. As a guide for 8 GB:

| Model size | Quantisation | Fits on GPU? |
| ---------- | ------------ | ------------ |
| 7–8B       | Q4–Q6        | Yes, with room for context |
| 14B        | Q4           | Only just; keep context short |
| 30B+       | any          | No; offload part of it and the rest runs from RAM, slowly |

Long contexts use VRAM too, so lower the offload or the context length if
loading fails.

## Checking on it

```bash
nvtop          # live VRAM and GPU load while a model runs
nvidia-smi     # one-off snapshot; wakes the dGPU if it was asleep
```

## Local API

LM Studio's Developer tab (or `lms server start`) starts an OpenAI-compatible
server on `http://localhost:1234/v1`.

## Caveats

- **Kernel.** salt uses `linuxPackages_latest`. If a kernel bump outpaces the
  NVIDIA driver, the rebuild fails building the `nvidia` kernel module. Fix it
  by pinning an older kernel in salt's `configuration.nix` until the driver
  catches up.
- **External monitors.** If a display port is wired to the NVIDIA card, the
  dGPU can't power down while a monitor is connected there.
- **Bus IDs.** `prime.intelBusId` and `prime.nvidiaBusId` come from
  `/sys/bus/pci/devices` (`0000:00:02.0` and `0000:01:00.0`). They only change
  if the hardware does.
