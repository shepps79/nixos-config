# Ollama: local LLM server (systemd service, API on localhost:11434), on CUDA.
{
  flake.nixosModules.ollama =
    { pkgs, ... }:
    {
      services.ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
      };
    };
}
