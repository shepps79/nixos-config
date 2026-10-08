# Feature files write NixOS config into `flake.nixosModules.<name>`. It is a
# deferredModule per name, so any number of files can contribute to
# `flake.nixosModules.base` and the definitions merge.
{
  systems = [ "x86_64-linux" ];
}
