# Face auth via Howdy on the webcam's IR sensor. Enroll with `sudo howdy add`,
# check the feed with `sudo howdy test`. A photo can fool Howdy, so it is only
# ever "sufficient": the password (and fingerprint) still work.
{
  flake.nixosModules.faceUnlock =
    { config, lib, ... }:
    let
      # Try the face before the fingerprint: Howdy gives up after a few seconds,
      # while fprintd waits ~30s for a finger before falling through. sddm and
      # the TTY both go through the login stack.
      howdyFirst = lib.genAttrs [ "login" "sudo" "polkit-1" ] (service: {
        rules.auth.howdy.order = config.security.pam.services.${service}.rules.auth.fprintd.order - 10;
      });
    in
    {
      services.howdy = {
        enable = true;
        control = "sufficient";
        # The IR stream (greyscale 640x360); by-path survives /dev/videoN renumbering.
        settings.video.device_path = "/dev/v4l/by-path/pci-0000:00:14.0-usb-0:3:1.2-video-index0";
      };

      security.pam.services = lib.mkIf config.services.fprintd.enable howdyFirst;
    };
}
