# nixos-config

NixOS configuration for two machines: `salt`, a bare metal laptop, and `pepper`, WSL2 under Windows.

## Layout

- `common.nix` — options every host needs. New options go here unless they are machine-specific.
- `hosts/<name>/` — hardware, boot and desktop. `salt` keeps its `hardware-configuration.nix` alongside; `pepper` gets filesystems and networking from the nixos-wsl module instead.
- `desktop/` — one file per desktop environment, imported by the hosts that want one.

## Rebuilding

`bin/rebuild` formats, switches and commits. It resolves `--flake .` by hostname, so it only builds the host it runs on, and it stages everything first — commit your work before running it.
