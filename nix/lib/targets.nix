# nix/lib/targets.nix
# システム文字列から「どの設定を出力として参照するか」を決める。
# app は nix build .#<attr> / nix run <flake>#<attr> に渡す文字列をここで一律に得る
# (apps 側で attr 名を組み立てない = 名付けの単一ソース)
{ username, system }:
let
  isDarwin = builtins.match ".*-darwin" system != null;
  isIntelMac = system == "x86_64-darwin";
  isAarch64Linux = system == "aarch64-linux";
in
rec {
  inherit isDarwin isIntelMac;

  # nix-darwin の設定名 (Apple Silicon: 無印 / Intel Mac: -x86_64 サフィックス)
  darwinConfigName = if isIntelMac then "${username}-x86_64" else username;

  # Linux の設定名。home-manager と system-manager が同じ attr 名を共有する
  # (nazozokc → x86_64-linux / nazozokc-aarch64 → aarch64-linux)
  linuxConfigName = if isAarch64Linux then "${username}-aarch64" else username;

  # WSL 用の home-manager 設定名
  wslConfigName = "${username}-wsl";

  # nix run .#build がビルドするターゲット
  hmConfig =
    if isDarwin then
      "darwinConfigurations.${darwinConfigName}.system"
    else
      "homeConfigurations.${username}.activationPackage";

  # nix run .#switch / system-* が --flake へ渡すターゲット
  flakeTarget = if isDarwin then ".#${darwinConfigName}" else ".#${linuxConfigName}";

  # system-manager へ渡す attr (systemConfigs.<name> 相当)
  systemConfigName = linuxConfigName;

  # app 実行時に表示する人間向けのシステム名
  sysLabel =
    if system == "x86_64-linux" then
      "Linux (x86_64)"
    else if isAarch64Linux then
      "Linux (aarch64)"
    else if system == "aarch64-darwin" then
      "macOS (Apple Silicon)"
    else if isIntelMac then
      "macOS (Intel)"
    else
      system;

  # switch などの実行前に出す「何をやるか」の表示
  printInfo = cmd: ''
    echo "  system : ${sysLabel}"
    echo "  target : ${flakeTarget}"
    echo "  cmd    : ${cmd}"
    echo ""
  '';
}
