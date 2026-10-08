{
  # Wrap nixfmt so `nix fmt` with no path args formats the whole tree
  # instead of blocking on stdin (bare nixfmt reads stdin when given no
  # files, and never recurses a directory itself).
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.writeShellApplication {
        name = "nixfmt-tree";
        runtimeInputs = [
          pkgs.nixfmt
          pkgs.findutils
        ];
        text = ''
          if [ "$#" -eq 0 ]; then set -- .; fi
          find "$@" -type f -name '*.nix' -exec nixfmt {} +
        '';
      };
    };
}
