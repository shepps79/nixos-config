# tmux with plugins from nixpkgs, written to /etc/tmux.conf. resurrect +
# continuum save sessions every 10 minutes and restore them on tmux start.
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          resurrect
          continuum
        ];
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      };
    };
}
