# pnpm configuration
# nixpkgs の pnpm はバージョン固定されており、壊れにくい
# corepack の shim は nixpkgs の pnpm と競合して壊れるため使わない
{ pkgs, config, ... }:
{
  # pnpm は dev/default.nix で home.packages に追加済み
  # ここでは堅牢化のための設定のみ行う

  # store を XDG 準拠の場所に明示的に指定 (デフォルトと同等だが明示化)
  home.sessionVariables = {
    PNPM_HOME = "${config.xdg.dataHome}/pnpm";
    PNPM_STORE_DIR = "${config.xdg.dataHome}/pnpm/store";
  };

  home.sessionPath = [
    "${config.xdg.dataHome}/pnpm"
  ];
}
