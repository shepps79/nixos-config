# LM Studio: local LLMs in a GUI, plus an OpenAI-compatible server and the
# `lms` CLI. It downloads its own CUDA llama.cpp runtime, so CUDA needs only
# the driver from the nvidia module, not a CUDA toolkit from nixpkgs.
{
  flake.nixosModules.lmstudio =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.lmstudio ];
    };
}
