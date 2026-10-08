{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      # Define a user account. Don't forget to set a password with 'passwd'.
      users.users."richard" = {
        isNormalUser = true;
        description = "Richard Shephard";
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      security.sudo.extraRules = [
        {
          users = [ "richard" ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
}
