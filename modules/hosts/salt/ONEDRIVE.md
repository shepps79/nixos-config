# OneDrive sync on salt

Syncs the OneDrive used by the Windows 11 machine into `~/OneDrive`, using the
abraunegg/onedrive client as a systemd user service (`onedrive --monitor`).

- NixOS side: `modules/onedrive.nix` (`flake.nixosModules.onedrive`), imported
  by salt only. pepper's Windows host already runs native OneDrive.
- Client config: `dotfiles/onedrive/.config/onedrive/config`, stowed into
  `~/.config/onedrive/`. `bin/stow-dotfiles` pre-creates that dir so the auth
  token and sync database the client writes there stay out of git.

Windows 11 folder backup puts Documents, Pictures (with `Pictures/Screenshots`)
and Desktop at the OneDrive root, so they show up under `~/OneDrive/`.

The same package links `~/Documents` and `~/Pictures` to `~/OneDrive/Documents`
and `~/OneDrive/Pictures`. Stow refuses absolute symlinks, so the links in
`dotfiles/onedrive/` are relative and assume the repo is checked out at
`~/git/personal/nixos-config`. Stow won't replace real directories: remove the
empty `~/Documents` and `~/Pictures` (`rmdir ~/Documents ~/Pictures`) before
the first stow.

## 1. Activate

```bash
bin/rebuild
bin/stow-dotfiles -R
```

## 2. Authorise (once)

```bash
onedrive
```

Open the printed URL, sign in, then paste the URL the browser lands on (a blank
page) back into the terminal. Work/business accounts may need tenant admin
approval for the app first.

## 3. First sync

```bash
onedrive --sync --dry-run   # optional: preview what happens
onedrive --sync             # initial full download
systemctl --user restart onedrive-launcher
```

From then on it starts at every login and syncs both ways: local changes
upload immediately, remote changes are checked every `monitor_interval`
seconds (300).

## Checking on it

```bash
systemctl --user status onedrive@onedrive
journalctl --user -u onedrive@onedrive -f
onedrive --display-sync-status
```

## Syncing only some folders

Add `dotfiles/onedrive/.config/onedrive/sync_list`, one path per line relative
to the OneDrive root:

```
/Documents
/Pictures
/Desktop
```

## Changing the config

After changing `sync_dir`, any `skip_*` option or `sync_list`, the client
refuses to run until it has resynced once:

```bash
systemctl --user stop onedrive@onedrive
onedrive --sync --resync
systemctl --user start onedrive@onedrive
```

## Linux screenshots

Linux screenshots only reach Windows if they're saved inside `~/OneDrive`. To
do that, point the screenshot tool (e.g. Spectacle) at
`~/OneDrive/Pictures/Screenshots`.
