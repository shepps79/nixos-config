{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      # Node version manager (nvm, wired up in ~/.zshrc) fetches stock Node builds
      # that are dynamically linked against a standard FHS loader NixOS lacks.
      # nix-ld supplies that loader so `nvm install <ver>` and the node binaries run.
      programs.nix-ld.enable = true;

      environment.systemPackages = with pkgs; [
        binutils
        bun
        dotnet-sdk_10
        gcc
        gnumake
        maven
        #pipx
        pi-coding-agent
        pkg-config
        python3
        shellcheck
      ];
    };
}
