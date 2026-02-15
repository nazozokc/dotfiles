final: prev:
let
  # 読み込む overlay ファイル一覧
  overlayFiles = [
    ./ai-tools.nix
    # 将来的に他の overlay をここに追加できる
  ];

  # 各 overlay を順に適用して結果をマージ
  applyOverlays = builtins.foldl' (acc: overlay: acc // (import overlay final prev)) { } overlayFiles;
in
applyOverlays
