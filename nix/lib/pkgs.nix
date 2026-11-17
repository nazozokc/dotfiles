# nix/lib/pkgs.nix
# システム文字列から nixpkgs インスタンスを生成するヘルパー (pkgsFor)
# overlay と unfree パッケージを一括で適用する
# x86_64-darwin (Intel Mac) は 26.11 でサポートが削除されたため 26.05 系スタックを使う
{
  nixpkgs,
  nixpkgs-intel,
  llm-agents,
  llm-agents-intel,
  gh-graph,
  gh-graph-intel,
  gh-nippou,
  gh-nippou-intel,
  overlay,
}:
system:
let
  isIntel = system == "x86_64-darwin";
  nixpkgs' = if isIntel then nixpkgs-intel else nixpkgs;
  llmAgents' = if isIntel then llm-agents-intel else llm-agents;
  ghGraphOverlay = if isIntel then gh-graph-intel.overlays.default else gh-graph.overlays.default;
  ghNippouOverlay = if isIntel then gh-nippou-intel.overlays.default else gh-nippou.overlays.default;
in
import nixpkgs' {
  localSystem.system = system;
  # 値の単一ソースは nix/lib/nixpkgs-config.nix (macOS / NixOS 側と共有)
  config = import ./nixpkgs-config.nix {
    allowDeprecatedx86_64Darwin = isIntel;
  };
  overlays = [
    (_: _: { _llm-agents = llmAgents'; })
    overlay
    ghGraphOverlay
    ghNippouOverlay
  ];
}
