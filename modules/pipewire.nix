# Sound with pipewire, replacing pulseaudio (pulse/alsa clients still work).
{
  flake.nixosModules.pipewire = {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
