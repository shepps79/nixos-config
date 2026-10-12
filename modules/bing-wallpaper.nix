# Bing image of the day as the wallpaper, like Windows 11. A systemd user timer
# downloads today's UHD image into ~/Pictures/Wallpapers/Bing once a day (and
# shortly after login) and hands it to noctalia over IPC. Noctalia's own
# random rotation is off in dotfiles/noctalia, so the image sticks all day.
{
  flake.nixosModules.bingWallpaper =
    { pkgs, ... }:
    let
      fetch = pkgs.writeShellApplication {
        name = "bing-wallpaper";
        runtimeInputs = with pkgs; [
          curl
          jq
          coreutils
          findutils
          noctalia-shell
        ];
        text = ''
          dir="$HOME/Pictures/Wallpapers/Bing"
          mkdir -p "$dir"

          meta="$(curl -fsS 'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-GB')"
          urlbase="$(jq -r '.images[0].urlbase' <<<"$meta")"
          date="$(jq -r '.images[0].startdate' <<<"$meta")"
          file="$dir/$date.jpg"

          if [ ! -s "$file" ]; then
            curl -fsS -o "$file.part" "https://www.bing.com''${urlbase}_UHD.jpg"
            mv "$file.part" "$file"
          fi

          # Keep a month of history.
          find "$dir" -name '*.jpg' -mtime +30 -delete

          # Noctalia may still be starting after login; retry for a minute.
          for _ in $(seq 12); do
            if noctalia-shell ipc call wallpaper set "$file" all 2>/dev/null; then
              exit 0
            fi
            sleep 5
          done
          echo "noctalia not reachable; wallpaper downloaded to $file" >&2
        '';
      };
    in
    {
      systemd.user.services.bing-wallpaper = {
        description = "Fetch Bing image of the day and set it as the wallpaper";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${fetch}/bin/bing-wallpaper";
        };
      };

      systemd.user.timers.bing-wallpaper = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnStartupSec = "30s";
          OnCalendar = "*-*-* 00:05:00";
          Persistent = true;
          RandomizedDelaySec = "5m";
        };
      };
    };
}
