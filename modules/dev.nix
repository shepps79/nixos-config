{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        binutils
        bun
        devcontainer
        dotnet-sdk_10
        gcc
        gnumake
        maven
        pipx
        pkg-config
        python3
        shellcheck
        uv
        yamllint
      ];
    };
}
