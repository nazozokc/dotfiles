{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = true;
    # acceleration = null;  # null: デフォルト, "cuda": NVIDIA, "rocm": AMD
    host = "127.0.0.1";
    port = 11434;
  };

  home.packages = with pkgs; [
    oterm
  ];
}
