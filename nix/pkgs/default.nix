{ pkgs }:

{
  lang = {
    node = import ./lang/node.nix { inherit pkgs; };
    python = import ./lang/python.nix { inherit pkgs; };
    rust = import ./lang/rust.nix { inherit pkgs; };
  };

  tools = import ./tools/dev.nix { inherit pkgs; };
}

