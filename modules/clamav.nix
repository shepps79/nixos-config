# ClamAV: signature updates, clamd, a weekly scan of the home directory, and
# on-access scanning of Downloads. Imported by salt only.
{
  flake.nixosModules.clamav = {
    services.clamav = {
      updater.enable = true;
      daemon.enable = true;
      daemon.settings = {
        OnAccessIncludePath = "/home/richard/Downloads";
        # Block access to a file until it has been scanned.
        OnAccessPrevention = true;
        # Don't scan clamd's own reads.
        OnAccessExcludeUname = "clamav";
        # Skip bulky non-executable data in the home scan: model weights, IDE data, caches.
        ExcludePath = [
          "^/home/richard/\\.lmstudio/"
          "^/home/richard/\\.local/share/JetBrains/"
          "^/home/richard/\\.cache/"
        ];
      };
      clamonacc.enable = true;
      scanner = {
        enable = true;
        interval = "weekly";
        scanDirectories = [ "/home/richard" ];
      };
    };

    # A laptop is often asleep at scan time; run the missed scan on wake.
    systemd.timers.clamdscan.timerConfig.Persistent = true;

    # A busy clamd can ignore SIGTERM, holding shutdown for the default 90s. Nothing
    # here needs a clean stop, so kill it sooner.
    systemd.services = {
      clamav-daemon.serviceConfig.TimeoutStopSec = "10s";
      clamav-clamonacc.serviceConfig.TimeoutStopSec = "10s";
      clamdscan.serviceConfig.TimeoutStopSec = "10s";
    };
  };
}
