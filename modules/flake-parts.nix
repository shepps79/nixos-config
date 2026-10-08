# Enables `flake.modules.<class>.<name>`, the option every feature file writes
# its NixOS config into. Modules sharing a name merge, so any number of files
# can contribute to `flake.modules.nixos.base`.
{ inputs, ... }:

{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];
}
