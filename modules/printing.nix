# CUPS print server. Printer drivers and virtual printers (canonG3070, cupsPdf) build on it.
{
  flake.nixosModules.printing = {
    services.printing.enable = true;
  };
}
