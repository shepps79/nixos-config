# Canon PIXMA G3070 series: CUPS driver, network discovery and scanning.
{
  flake.nixosModules.canonG3070 =
    { pkgs, ... }:
    {
      services.printing.drivers = [ pkgs.cnijfilter2 ];

      # mDNS discovery for network printers and scanners.
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      hardware.sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
      };

      environment.systemPackages = [ pkgs.simple-scan ];
    };
}
