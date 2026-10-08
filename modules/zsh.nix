{
  flake.nixosModules.base =
    { pkgs, lib, ... }:
    {
      # zsh as richard's login shell, with the whole prompt stack provided
      # declaratively by Nix instead of clones under $HOME. oh-my-zsh,
      # powerlevel10k (an oh-my-zsh custom theme) and zsh-syntax-highlighting all
      # come from the store; the stowed ~/.zshrc only layers on ~/.p10k.zsh and the
      # personal env tail. /etc/zshrc is sourced before ~/.zshrc, so the omz stack
      # is already loaded by the time ~/.zshrc runs.
      programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
        ohMyZsh = {
          enable = true;
          plugins = [
            "git"
            "autojump"
          ];
          customPkgs = [ pkgs.zsh-powerlevel10k ];
          theme = "powerlevel10k/powerlevel10k";
          # The store copy is read-only; self-update would only error.
          preLoaded = "zstyle ':omz:update' mode disabled";
        };
        # Powerlevel10k instant prompt must run before oh-my-zsh loads. mkBefore
        # places it ahead of the oh-my-zsh block within /etc/zshrc.
        interactiveShellInit = lib.mkBefore ''
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi
        '';
      };

      environment.systemPackages = [ pkgs.autojump ];
    };
}
