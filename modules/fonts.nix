# Nerd Font for the p10k prompt icons; default monospace so terminals pick it up.
# IBM Plex, Roboto and the Microsoft core fonts (Courier New, Arial, Times New
# Roman, ...) for documents and web pages that ask for them by name. corefonts
# is unfree; nonfree.nix allows it.
{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        nerd-fonts.meslo-lg
        ibm-plex
        roboto
        corefonts
      ];
      fonts.fontconfig.defaultFonts.monospace = [ "MesloLGS Nerd Font" ];
    };
}
