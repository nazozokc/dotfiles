# nix/overlays/default.nix
final: prev:

let
  # このディレクトリ内の overlay を列挙
  overlayFiles = [
    ./ai.nix
    ./git.nix
    ./node.nix

  ];

  # 各 overlay を適用してマージ
  applyOverlays =
    builtins.foldl'
      (acc: overlay:
        acc // (import overlay final prev)
      )
      { }
      overlayFiles;

in
applyOverlays

