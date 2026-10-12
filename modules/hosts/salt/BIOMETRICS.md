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

## 3. Enroll your face

```bash
sudo howdy test        # live IR preview; check the image isn't black
sudo howdy add         # look at the camera
```

Add a few models in different conditions (glasses on and off, day and night):
each `howdy add` is another model. `sudo howdy list` shows them,
`sudo howdy remove <id>` or `sudo howdy clear` deletes them.

If the `howdy test` image is dark, the IR emitter isn't switching on. Add
`services.linux-enable-ir-emitter.enable = true;` to `modules/face-unlock.nix`,
rebuild, then configure it once:

```bash
sudo linux-enable-ir-emitter configure
```

## 4. Try it

```bash
sudo -k && sudo true
```

You should be recognised by face. Cover the camera and it falls through to
the fingerprint, then the password.

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
sudo howdy config           # opens /etc/howdy/config.ini (read-only; change
                            # settings via services.howdy.settings instead)
```
