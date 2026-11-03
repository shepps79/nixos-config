# Obsidian notes. On pepper it runs on the Windows side.
# Uses the upstream AppImage with its bundled Electron: nixpkgs' build runs on
# system Electron 43.8.3, which breaks it (webFrame errors, blank start).
# shortcut: pinned version, switch back to pkgs.obsidian once nixpkgs' works again.
{
  flake.nixosModules.obsidian =
    { pkgs, ... }:
    let
      pname = "obsidian";
      version = "1.15.0";
      src = pkgs.fetchurl {
        url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/Obsidian-${version}.AppImage";
        hash = "sha256-HdjPtZPeqmRBAb2032WxWe15hZk7ZXLdJf0TY0Wekcw=";
      };
      contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
    in
    {
      environment.systemPackages = [
        (pkgs.appimageTools.wrapType2 {
          inherit pname version src;
          extraInstallCommands = ''
            install -Dm444 ${contents}/md.obsidian.Obsidian.desktop -t $out/share/applications
            substituteInPlace $out/share/applications/md.obsidian.Obsidian.desktop \
              --replace-fail 'Exec=AppRun' 'Exec=obsidian'
            cp -r ${contents}/usr/share/icons $out/share
          '';
        })
      ];
    };
}
