# Non-free applications. Kept separate from common.nix so the unfree
# surface is easy to audit. allowUnfree is set in common.nix.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    claude-code
    obsidian
    vscode
    zoom-us
  ];
}
