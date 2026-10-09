# Docker daemon on every host (native dockerd on pepper too, no Docker Desktop).
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      virtualisation.docker.enable = true;
      users.users."richard".extraGroups = [ "docker" ];
      environment.systemPackages = [ pkgs.lazydocker ];
    };
}
