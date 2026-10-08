# 1Password desktop app, so the Brave extension unlocks with system auth.
{
  flake.nixosModules.onepassword = {
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "richard" ];
    };
    # 1Password only talks to browsers on its built-in list; nixpkgs Brave isn't on it.
    environment.etc."1password/custom_allowed_browsers" = {
      text = "brave\n";
      mode = "0755";
    };
  };
}
