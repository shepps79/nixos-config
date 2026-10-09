# nixos-config

NixOS configuration for two machines: `salt`, a bare metal laptop, and `pepper`, WSL2 under Windows.

## Layout

Dendritic pattern: every `.nix` file under `modules/` is a flake-parts module, loaded automatically by import-tree. There are no `imports` lists to maintain, and files can be moved or renamed freely.

- `modules/<feature>.nix` — one file per feature. Each one writes its NixOS config into a named module, `flake.nixosModules.<name>`. Modules that share a name merge.
  - `base` — what every host gets. New features go here unless they are machine-specific.
  - Machine-specific features get their own named module instead, e.g. `fonts`, `onepassword`, or the desktops `plasma`, `hyprland`, `niri` (`modules/desktop/`). Hosts opt in by importing them.
  - Never write feature config inline in a host's `configuration.nix`, even for one host. That file only holds what is intrinsic to the machine (boot, kernel, hostname, `stateVersion`) and its imports.
- `modules/hosts/<name>/` — `default.nix` defines `nixosConfigurations.<name>` (must match the hostname); `configuration.nix` defines `<name>Configuration`, which imports `base` plus the opt-in modules the host wants. `salt` also has `hardware.nix` (`saltHardware`), the generated hardware config wrapped as a module; `pepper` gets filesystems and networking from the nixos-wsl module instead.
- Reference other modules as `self.nixosModules.<name>` (take `{ self, ... }` at the top of the file).
- import-tree skips any path with a component starting with `_`. Every other `.nix` file must be a flake-parts module, so never drop a plain NixOS module into `modules/` unwrapped.
- A feature that needs a flake input takes `{ inputs, ... }` at the top of its file, outside the NixOS module (see `rust.nix`, `omp.nix`).

## Dotfiles

User-level config that isn't NixOS config lives in `dotfiles/`, symlinked into `$HOME` with GNU Stow by `bin/stow-dotfiles` (run by hand per machine; `bin/rebuild` does not call it).

- Every subdirectory of `dotfiles/` is one stow package (`dotfiles/<app>/`) mirroring `$HOME`, and is picked up automatically. `dotfiles/.gitignore` is not a package.
- Add new user config as a package here. Don't use NixOS modules for per-user files.
- Stow folds: if a target directory doesn't exist, the whole directory becomes a symlink into the repo, and anything an app writes there lands in git. To link only the files we ship, `bin/stow-dotfiles` pre-creates the parent dirs (`~/.config`, `~/.claude/skills`, `~/.claude-equalexperts`, `~/.agents/skills`, `~/.pi/agent/extensions`). A new package whose apps write into the same dir needs its parent added to that `mkdir -p`.
- Don't stow files that apps rewrite (e.g. `~/.claude/settings.json`, `~/.claude.json`); they can replace the symlink. Link stable, hand-edited files such as `CLAUDE.md` and skill directories.
- `.claude/skills/` at the repo root is this repo's own project skills, not a dotfiles package.

## Rebuilding

`bin/rebuild` formats, switches and commits. It resolves `--flake .` by hostname, so it only builds the host it runs on, and it stages everything first — commit your work before running it. New files must be git-tracked before the flake can see them.
