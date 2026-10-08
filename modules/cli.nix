{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      # You can use https://search.nixos.org/ to find more packages (and options).
      environment.systemPackages = with pkgs; [
        vim
        wget
        git
        stow
        neovim
        bat
        btop
        curl
        delta
        dmidecode
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
        fuzzel
        wezterm
      ];
    };
}
