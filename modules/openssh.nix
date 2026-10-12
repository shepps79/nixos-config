# OpenSSH server, for logging in to this machine remotely.
{
  flake.nixosModules.openssh = {
    services.openssh.enable = true;
  };
}
