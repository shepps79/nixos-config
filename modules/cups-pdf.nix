# "Print to PDF" virtual printer; output lands in ~/PDF.
{
  flake.nixosModules.cupsPdf = {
    services.printing.cups-pdf = {
      enable = true;
      instances.pdf.settings.Out = "\${HOME}/PDF";
    };
  };
}
