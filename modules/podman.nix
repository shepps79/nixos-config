# Podman alongside Docker. No dockerCompat: it would clash with the real docker CLI.
{
  flake.nixosModules.base = {
    virtualisation.podman.enable = true;
  };
}
