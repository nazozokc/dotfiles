# nix/overlays/bitwarden-cli.nix
# ---------------------------------------------------------------------------
# bitwarden-cli (Darwin) ビルド修正
# ---------------------------------------------------------------------------
# bitwarden-cli の `npm rebuild` は node-gyp (gyp) が直接 `xcodebuild -version` を
# spawn する。しかし Nix ビルド中の PATH には /usr/bin が含まれず、
# 上流 package.nix が nativeBuildInputs に持つ xcbuild.xcrun は xcrun しか
# 提供しないため、`xcodebuild` が見つからず FileNotFoundError で失敗する。
#
# そこで `xcodebuild -version` にのみ正常応答する shim を追加する。
# 実際のコンパイルは nixpkgs の clang / apple_sdk が行うため、shim の値は
# gyp のアーキテクチャ判定 (ARCHS_STANDARD = x86_64/arm64) にのみ使われる。
# 対象は Intel Mac / Apple Silicon 共通 (Nix ビルド中の PATH は両方で同じ)。
# 上流 package.nix の nativeBuildInputs を xcbuild (xcodebuild 入り) に変える
# 修正が入ったら削除してよい。
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  bitwarden-cli = prev.bitwarden-cli.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      (final.writeShellScriptBin "xcodebuild" ''
        if [ "$1" = "-version" ]; then
          echo "Xcode 15.4"
          echo "Build version 15F31d"
        fi
        exit 0
      '')
    ];
  });
}
