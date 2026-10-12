# Fingerprint auth via fprintd. salt's reader is a Broadcom ControlVault 3
# (0a5c:5843), which needs Dell's proprietary TOD driver; the -cv3plus variant
# only covers 0a5c:5864-5867. Enroll with `fprintd-enroll`. fprintd adds a
# "sufficient" rule to every PAM service, so the password still works.
{
  flake.nixosModules.fingerprint =
    { pkgs, ... }:
    {
      services.fprintd = {
        enable = true;
        tod.enable = true;
        tod.driver = pkgs.libfprint-2-tod1-broadcom;
      };

      # sddm and the TTY go through login. KWallet unlocks at login from the
      # typed password, so a fingerprint login leaves it locked and prompting.
      security.pam.services.login.fprintAuth = false;
    };
}
