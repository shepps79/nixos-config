# power-profiles-daemon: switch power-saver/balanced/performance from Plasma's
# battery applet, noctalia's bar, or `powerprofilesctl set performance`.
# `powerprofilesctl launch -p performance -- cargo build` holds it for one build.
# Plasma enables it too; set here so niri/hyprland sessions don't depend on that.
{
  flake.nixosModules.powerProfiles = {
    services.power-profiles-daemon.enable = true;
  };
}
