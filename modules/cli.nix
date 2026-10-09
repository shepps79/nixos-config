{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        wget
        git
        stow
        bat
        btop
        curl
        delta
        gh
        gnupg
        htop
        inotify-tools
        jq
        mc
        nano
        rclone
        ripgrep
        rsync
        tmux
        tree
        unzip
        xdg-utils
        zip
      ];
    };
}
