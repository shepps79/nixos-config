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
        fastfetch
        fzf
        gh
        gnupg
        htop
        httpie
        inotify-tools
        jq
        lazygit
        mc
        nano
        ncdu
        nmap
        rclone
        ripgrep
        rsync
        tmux
        tree
        unzip
        usbutils
        xdg-utils
        zip
      ];
    };
}
