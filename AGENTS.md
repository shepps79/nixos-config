# nixos-config

NixOS configuration for two machines: `salt`, a bare metal laptop, and `pepper`, WSL2 under Windows.

## Layout

Dendritic pattern: every `.nix` file under `modules/` is a flake-parts module, loaded automatically by import-tree. There are no `imports` lists to maintain, and files can be moved or renamed freely.

- `modules/<feature>.nix` — one file per feature. Each one writes its NixOS config into a named module, `flake.modules.nixos.<name>`. Modules that share a name merge.
  - `base` — what every host gets. New features go here unless they are machine-specific.
  - `plasma`, `hyprland`, `niri` (`modules/desktop/`) — opt-in desktops.
- `modules/hosts/<name>` — defines `nixosConfigurations.<name>` and the host module, which imports `base` plus whatever opt-in modules the host wants. `salt` keeps `_hardware-configuration.nix` alongside; `pepper` gets filesystems and networking from the nixos-wsl module instead.
- import-tree skips any path with a component starting with `_`. Use that prefix for plain NixOS modules such as hardware-configuration.
- A feature that needs a flake input takes `{ inputs, ... }` at the top of its file, outside the NixOS module (see `rust.nix`, `omp.nix`).

## Rebuilding

`bin/rebuild` formats, switches and commits. It resolves `--flake .` by hostname, so it only builds the host it runs on, and it stages everything first — commit your work before running it. New files must be git-tracked before the flake can see them.
