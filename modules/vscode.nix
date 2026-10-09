# VS Code. On pepper, use Windows VS Code with Remote-WSL.
{
  flake.nixosModules.vscode =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.vscode ];
    };
}
