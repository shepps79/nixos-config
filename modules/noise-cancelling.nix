# DeepFilterNet noise-cancelled mic: adds a "DeepFilter Noise Cancelling Source"
# input to pick in Zoom/Slack. Needs pipewire, which salt enables. From
# github:vimjoyer/nixconf nixos/features/pipewire.nix.
{
  flake.nixosModules.noiseCancelling =
    { pkgs, ... }:
    {
      services.pipewire.extraConfig.pipewire."99-input-denoising"."context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "DeepFilter Noise Cancelling Source";
            "media.name" = "DeepFilter Noise Cancelling Source";
            "filter.graph".nodes = [
              {
                type = "ladspa";
                name = "DeepFilter Mono";
                plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                label = "deep_filter_mono";
              }
            ];
            "audio.rate" = 48000;
            "capture.props" = {
              "node.name" = "deep_filter_mono_input";
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name" = "deep_filter_mono_output";
              "media.class" = "Audio/Source";
            };
          };
        }
      ];
    };
}
