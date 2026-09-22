# The prompt stack — oh-my-zsh, the powerlevel10k theme, zsh-syntax-highlighting
# and the powerlevel10k instant prompt — is provided declaratively by NixOS via
# /etc/zshrc (see programs.zsh in common.nix), which is sourced before this file.
# ~/.zshrc only layers on the personal p10k config and environment.

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


## Custom edits
export PATH=$HOME/.local/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. "$HOME/.cargo/env"
. "$HOME/.bash_aliases"
. "$HOME/.custom_env"

# pnpm
export PNPM_HOME="/home/richard/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# bun completions
[ -s "/home/richard/.bun/_bun" ] && source "/home/richard/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
