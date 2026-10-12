# Provides the FHS dynamic loader NixOS lacks, so prebuilt binaries
# (nvm's Node builds, downloaded tools) run unpatched.
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      programs.nix-ld.enable = true;

      # Libraries prebuilt GUI apps dlopen at runtime (winit/wgpu style:
      # X11 via xcb, Wayland, keyboard handling, GL and Vulkan).
      programs.nix-ld.libraries = with pkgs; [
        libxcb
        libx11
        libxcursor
        libxi
        libxrandr
        libxkbcommon
        wayland
        vulkan-loader
        libGL
      ];
    };
}
