# Video players. PDFs and images are covered by Okular and Gwenview, which
# Plasma already installs.
{
  flake.nixosModules.media =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        haruna
        mpv
      ];
    };
}
