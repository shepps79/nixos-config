# LibreOffice productivity suite, including Impress for presentations.
{
  flake.nixosModules.libreoffice =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.libreoffice ];
    };
}
