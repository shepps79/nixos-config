# NetworkManager for wifi/ethernet. Not on pepper: WSL manages its networking.
{ lib, ... }:
{
  flake.nixosModules.networkmanager = {
    networking.networkmanager.enable = true;

    # Ignore the router's DHCP DNS (1.1.1.1, which times out under load) and resolve
    # through systemd-resolved's cache. The cache also absorbs the bursts of lookups
    # from parallel nix fetches.
    # mkForce: enabling resolved would otherwise make NM pass the DHCP DNS on to it.
    networking.networkmanager.dns = lib.mkForce "none";
    services.resolved.enable = true;
    services.resolved.settings.Resolve = {
      DNS = [
        "9.9.9.9"
        "149.112.112.112"
      ];
      FallbackDNS = [
        "8.8.8.8"
        "8.8.4.4"
      ];
      MulticastDNS = false; # avahi does mDNS (printing)
    };
  };
}
