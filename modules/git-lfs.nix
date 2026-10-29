# git-lfs: git extension for storing large files outside the repo.
{
  flake.nixosModules.base = {
    programs.git = {
      enable = true;
      lfs.enable = true;
    };
  };
}
