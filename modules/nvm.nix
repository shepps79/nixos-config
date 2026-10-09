# nvm, sourced from the store. Node versions it installs still live in the
# writable ~/.nvm. The stock Node builds it downloads need nix-ld.
{ inputs, ... }:

{
  flake.nixosModules.base = {
    programs.zsh.interactiveShellInit = ''
      export NVM_DIR="$HOME/.nvm"
      mkdir -p "$NVM_DIR"
      source ${inputs.nvm}/nvm.sh
      source ${inputs.nvm}/bash_completion
    '';
  };
}
