# Fingerprint and face login on salt

Two `sufficient` PAM methods ahead of the password, so the password always
still works:

- Fingerprint: fprintd with Dell's proprietary TOD driver
  `libfprint-2-tod1-broadcom`, for the Broadcom ControlVault 3 reader
  (`0a5c:5843`). `modules/fingerprint.nix` (`flake.nixosModules.fingerprint`).
- Face: Howdy on the webcam's IR sensor (`/dev/video2`, greyscale 640x360,
  addressed by its `/dev/v4l/by-path/` name). `modules/face-unlock.nix`
  (`flake.nixosModules.faceUnlock`).

Both are imported by salt only. For `login` (which sddm and the TTY use),
`sudo` and `polkit-1` the order is face, then fingerprint, then password:
Howdy gives up after about 4 seconds, while fprintd waits about 30 seconds for
a finger. Other PAM services get fprintd before Howdy, the NixOS default.

## 1. Activate

```bash
bin/rebuild
```

## 2. Enroll a fingerprint

```bash
fprintd-enroll                          # right index finger by default
fprintd-enroll -f left-index-finger     # optional: more fingers
fprintd-list "$USER"
fprintd-verify
```

Touch the sensor repeatedly until enrollment completes. To start over:
`fprintd-delete "$USER"`.

Enrolling needs your password through polkit (`auth_self_keep`), so it needs
a polkit agent: Plasma has its own, niri starts `hyprpolkitagent`
(`modules/desktop/niri.nix`). With no agent running (e.g. Hyprland, whose
config doesn't start one), `fprintd-enroll` fails with
`PermissionDenied: Not Authorized: net.reactivated.fprint.device.enroll`.
Don't reach for plain `sudo fprintd-enroll`: with no username, fprintd acts
on the calling user, so the print is stored for root (`/var/lib/fprint/root`).
`sudo fprintd-verify` then matches, but the lock screen and sddm authenticate
you and find no prints, so the reader does nothing. Instead, name yourself:

```bash
sudo fprintd-enroll "$USER"
```

or give the terminal a text-mode agent with
`pkttyagent --process $$ & fprintd-enroll`. `fprintd-list "$USER"` shows
whose prints exist; remove a stray root enrollment with
`sudo fprintd-delete root`.

The first time fprintd starts, the Broadcom driver flashes new ControlVault
firmware, which takes about two minutes. That outlasts systemd's start timeout,
so the first command fails with `Timeout was reached` and a retry right after
says `No devices available`. Don't reboot or restart fprintd during the flash.
Watch `journalctl -u fprintd -f` until it logs
`Control Vault firmware upgrade successful`. Once
`systemctl is-active fprintd` no longer says `deactivating`, run the command
again. Later starts skip the flash.

## 3. Enroll your face

The camera doesn't light its IR emitter by itself, so without it Howdy sees
only a dark silhouette and says `No face detected`. The
`linux-enable-ir-emitter` service is enabled, but it needs configuring once:

```bash
sudo linux-enable-ir-emitter configure
```

It tries control values on the camera and asks after each one whether the
emitter is flashing. Watch the small light beside the lens; a phone camera
shows the IR flash if your eyes can't. The working config is saved under
`/var/lib/linux-enable-ir-emitter`, and the service replays it at boot and
after suspend.

Then:

```bash
sudo howdy test        # live IR preview; your face should be lit
sudo howdy add         # look at the camera
```

Add a few models in different conditions (glasses on and off, day and night):
each `howdy add` is another model. `sudo howdy list` shows them,
`sudo howdy remove <id>` or `sudo howdy clear` deletes them.

## 4. Try it

```bash
sudo -k && sudo true
```

You should be recognised by face. Cover the camera and it falls through to
the fingerprint, then the password.

## Lock screens

- Noctalia (niri, Hyprland) authenticates against `/etc/pam.d/login`, so it
  gets face, fingerprint and password like sddm. `autoStartAuth` is on in
  `dotfiles/noctalia`, so authentication starts as soon as the lock screen
  appears and the reader is ready without pressing Enter first. If Howdy is
  enrolled it tries the face first, so a finger works once that gives up
  (about 4 seconds, or straight away with the lid closed). niri's
  `Super+L` calls Noctalia's lock; `/etc/pam.d/swaylock` has neither face
  nor fingerprint, so don't lock with swaylock.
- Plasma's screen locker uses the `kde-fingerprint` PAM service, which NixOS
  generates when fprintd is enabled. It takes a finger alongside the password
  field.

## Caveats

- Logging in at sddm by face or finger leaves KWallet/gnome-keyring locked,
  since they unlock with the password. To keep the password for login only,
  add to `modules/face-unlock.nix`:

  ```nix
  security.pam.services.login.fprintAuth = false;
  security.pam.services.login.howdy.enable = false;
  ```

- Howdy skips itself when the lid is closed (`abort_if_lid_closed`) and over
  SSH, so docked with the lid shut it goes straight to the fingerprint.
- A good photo can fool Howdy. That's why it is `sufficient` alongside the
  password, never the only way in.

## Troubleshooting

```bash
systemctl status fprintd
journalctl -u fprintd -b
lsusb | grep -i 0a5c        # reader present?
cat /etc/howdy/config.ini   # generated; change it via services.howdy.settings
```
