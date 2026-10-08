{
  flake.nixosModules.base = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Reclaim disk from superseded builds. bin/rebuild caps how many system
    # generations survive each switch; this weekly timer then garbage-collects the
    # store paths the dropped generations used to pin, and auto-optimise dedupes
    # identical files in the store.
    nix.gc = {
      automatic = true;
      dates = "weekly";
    };
    nix.settings.auto-optimise-store = true;
  };
}
