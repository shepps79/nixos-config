# OneDrive sync (abraunegg/onedrive) as a systemd user service running
# `onedrive --monitor`. Client config lives in dotfiles/onedrive. First run
# needs an interactive `onedrive` to authorise the account.
{
  flake.nixosModules.onedrive = {
    services.onedrive.enable = true;
  };
}
