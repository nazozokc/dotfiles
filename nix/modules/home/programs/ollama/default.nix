_:
{
  dotfiles.programs.ollama = {
    icon = "🦙";
    note = "127.0.0.1:11434";
  };

  services.ollama = {
    enable = true;
    # acceleration = null;  # null: デフォルト, "cuda": NVIDIA, "rocm": AMD
    host = "127.0.0.1";
    port = 11434;
  };
}
