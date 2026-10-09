# nvm, sourced from the store. Node versions it installs still live in the
# writable ~/.nvm.
{ inputs, ... }:

{
  flake.nixosModules.base = {
    # nvm downloads stock Node builds that are dynamically linked against an
    # FHS loader NixOS lacks; nix-ld supplies it.
    programs.nix-ld.enable = true;

    programs.zsh.interactiveShellInit = ''
      export NVM_DIR="$HOME/.nvm"
      mkdir -p "$NVM_DIR"
      source ${inputs.nvm}/nvm.sh
      source ${inputs.nvm}/bash_completion
    '';
  };
}
