# Installing salt (LUKS + TPM2)

Layout the config expects: GPT disk, 1 GiB vfat ESP at `/boot`, rest a LUKS2
container `cryptroot` holding an ext4 root. systemd-boot, systemd initrd, TPM2
auto-unlock. No swap partition — `zramSwap` handles it.

Run from the NixOS installer ISO (UEFI) as root. NVMe → partitions are
`${DISK}p1`, `${DISK}p2`.

## 1. Partition

```bash
lsblk -o NAME,SIZE,TYPE,MODEL      # find the disk
DISK=/dev/nvme0n1
wipefs -a "$DISK"
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart cryptroot 1GiB 100%
```

## 2. Format + open

```bash
mkfs.fat -F32 -n BOOT "${DISK}p1"
cryptsetup luksFormat --type luks2 "${DISK}p2"   # YES, strong passphrase (keep it)
cryptsetup open "${DISK}p2" cryptroot
mkfs.ext4 -L nixos /dev/mapper/cryptroot
```

## 3. Mount

```bash
mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot
mount "${DISK}p1" /mnt/boot
```

## 4. Config with fresh UUIDs

```bash
nixos-generate-config --root /mnt
nix-shell -p git
git clone <repo-url> /mnt/etc/nixos-config
cp /mnt/etc/nixos/hardware-configuration.nix \
   /mnt/etc/nixos-config/hosts/salt/hardware-configuration.nix
blkid "${DISK}p1" "${DISK}p2"   # confirm UUIDs match /boot and luks.devices.cryptroot
```

## 5. Install

```bash
nixos-install --flake /mnt/etc/nixos-config#salt   # sets root password
nixos-enter --root /mnt -c 'passwd richard'
reboot
```

First boot uses the passphrase.

## 6. Enroll TPM2

On the installed system:

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 "${DISK}p2"
```

Reboot — auto-unlocks from TPM, passphrase stays as fallback. `--tpm2-pcrs=7`
binds to Secure Boot state; stricter PCRs re-lock after firmware/boot updates.

## Swap (later, only if needed)

None by default; `zramSwap` is enough on 64 GiB with no hibernation. To add disk
swap later — no repartition, inherits LUKS via the encrypted root:

```nix
# hosts/salt/default.nix
swapDevices = [ { device = "/var/lib/swapfile"; size = 8 * 1024; } ];
```

`nixos-rebuild switch` creates and enables it.
