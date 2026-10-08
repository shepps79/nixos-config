# Nerd Font for the p10k prompt icons; default monospace so terminals pick it up.
{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts.packages = [ pkgs.nerd-fonts.meslo-lg ];
      fonts.fontconfig.defaultFonts.monospace = [ "MesloLGS Nerd Font" ];
    };
}
