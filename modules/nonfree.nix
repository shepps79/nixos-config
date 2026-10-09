# Non-free applications, in one file so the unfree surface is easy to audit.
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        claude-code
      ];
    };
}
