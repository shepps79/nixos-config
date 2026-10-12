# JetBrains Toolbox; it downloads and updates the IDEs themselves under $HOME.
{
  flake.nixosModules.jetbrains =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        # nixpkgs fetches from download-cdn.jetbrains.com directly, which 404s
        # without the signed redirect that download.jetbrains.com issues.
        (pkgs.jetbrains-toolbox.override {
          fetchzip =
            args:
            pkgs.fetchzip (
              args
              // {
                url = builtins.replaceStrings [ "download-cdn.jetbrains.com" ] [ "download.jetbrains.com" ] args.url;
              }
            );
        })
      ];
    };
}
