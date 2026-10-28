---
name: add-package
description: Add a package to this NixOS config as its own feature module, then commit it. Use for "add-package <name>", "install <name>", or "add <name> to my config".
argument-hint: <name>
---

# Add package

Add `<name>` (the argument) following the layout in `AGENTS.md`, then commit. Work it out yourself and only ask when one of the reasons under **Ask** applies.

## Steps

1. **Check it isn't already there**: `grep -rn "<name>" modules/`. If it is, say where and stop.
2. **Find the attribute** in the flake's pinned nixpkgs, not the registry's:
   `nix search "$(nix flake metadata --json 2>/dev/null | jq -r '.locks.nodes.nixpkgs.locked | "github:\(.owner)/\(.repo)/\(.rev)"')" '^<name>$' 2>/dev/null` (stderr is progress noise)
   Fall back to a looser regex (`<name>`) if the exact match finds nothing.
3. **Prefer a NixOS option to a bare package** when one exists, e.g. `virtualisation.podman.enable`, `programs.<name>.enable`, `services.<name>.enable`. Check with
   `nix eval .#nixosConfigurations.$(hostname).options.programs.<name>.enable.description` (and the `services`/`virtualisation` equivalents). The option usually sets up groups, services or wrappers that the bare package lacks.
4. **Pick the module**:
   - CLI tools and services useful on both hosts → `base`.
   - GUI apps, or anything needing hardware, a desktop or Windows-incompatible behaviour → its own named module (camelCase of the name), added to the `imports` in `modules/hosts/salt/configuration.nix`. pepper is WSL, so don't add GUI apps there.
5. **Write `modules/<name>.nix`**: a one-line `#` comment saying what it is, then the module. Copy the shape of `modules/lazysql.nix` (base) or `modules/codex.nix` (named). Take the package from `pkgs`; `allowUnfree` is already on in `base`.
6. **Check it evaluates**: `git add` the new file (flakes only see tracked files), then
   `nix eval .#nixosConfigurations.<host>.config.environment.systemPackages --apply 'ps: builtins.any (p: (p.pname or p.name) == "<pname>") ps'`
   (or eval the option you set) for each host that should get it. It must print `true`.
7. **Commit** with the `commit` skill: `feat(<name>): add <name> <short what-it-is> to <base|salt>`. Don't run `bin/rebuild`; tell the user to.

## Ask

Use `AskUserQuestion` only when:

- **Not found**: nothing matches. Offer the closest matches, and `nixpkgs-unstable` if it's there and not in stable.
- **Ambiguous**: several plausible attributes (e.g. `foo`, `foo-bin`, `foo-gtk`, `python3Packages.foo`), or both a NixOS option and a package with different results. Recommend one.
- **Conflict**: it clashes with something already enabled (e.g. podman `dockerCompat` vs docker). Recommend the option that keeps existing behaviour.
- **Host unclear**: you can't tell from what the package is whether pepper should get it.

Otherwise don't ask. Make the change, then in one line say which attribute and module you picked.
