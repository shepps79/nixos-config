# Tailscale mesh VPN. Run `sudo tailscale up` once per host to log in.
{
  flake.nixosModules.base = {
    services.tailscale.enable = true;
    # Opens the WireGuard UDP port so peers can connect directly instead of via DERP relays.
    services.tailscale.openFirewall = true;
  };
}
