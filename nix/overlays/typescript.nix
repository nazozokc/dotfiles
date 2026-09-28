# nix/overlays/typescript.nix
#
# TypeScript 7 (Go ネイティブ実装) の LSP エントリポイント `tsgo` を提供する。
#
# 背景:
#   - nixpkgs の `typescript` (= typescript_7) は `subPackages = [ "cmd/tsgo" ]`
#     だけをビルドし、成果物は `tsc` のみ。LSP モードは `tsc --lsp --stdio` で起動する。
#   - nvim-lspconfig の `tsgo` 設定は `node_modules/.bin/tsgo` → PATH 上の `tsgo`
#     の順に探索するため、`tsc` という名前では見つからない。
#   - TypeScript 7 は tsserver を廃し LSP を内置したので、typescript-language-server
#     も typescript-tools.nvim も tsserver.js (TypeScript 5) に依存できなくなった。
#
# 実装:
#   `tsc` 本体は noembed ビルドのため `lib/typescript/` 配下に置かれていないと
#   同梱 lib.d.ts を解決できない。symlinkJoin で本体 (lib/) をそのまま共有し、
#   `bin/tsgo` だけを追加することで store path を増やさず名前だけ差し替える。
final: prev:

let
  tsgo = prev.symlinkJoin {
    name = "tsgo-${prev.typescript_7.version}";
    paths = [ prev.typescript_7 ];
    postBuild = ''
      mkdir -p $out/bin
      ln -s tsc $out/bin/tsgo
    '';
    meta = {
      description = "TypeScript language server (TypeScript 7 native, tsc --lsp)";
      homepage = "https://github.com/microsoft/typescript";
      license = prev.lib.licenses.asl20;
      mainProgram = "tsgo";
      platforms = prev.lib.platforms.unix;
    };
  };
in
{
  inherit tsgo;
}
