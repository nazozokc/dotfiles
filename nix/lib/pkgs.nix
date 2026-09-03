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
  config.allowUnfree = true;
  # 26.05 で x86_64-darwin の非推奨警告を抑止 (26.11 ではキー自体が不要)
  config.allowDeprecatedx86_64Darwin = isIntel;
  config.permittedInsecurePackages = [
    "pnpm-9.15.9"
    "pnpm-10.34.0"
    "electron-39.8.10"
  ];
  config.problems = {
    handlers.dlinfo.broken = "warn";
  };
  overlays = [
    (_: _: { _llm-agents = llmAgents'; })
    overlay
    ghGraphOverlay
    ghNippouOverlay
  ];
}
