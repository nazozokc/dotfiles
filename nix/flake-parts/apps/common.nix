# nix/flake-parts/apps/common.nix
# apps/*.nix が共有するコンテキスト。
# identity (誰の dotfiles か) / shell (共通シェルヘルパ) / targets (attr 名の付け方)
# を 1 ファイルに集約し、各 app ファイルは `import ./common.nix { inherit inputs; }`
# で同じ値を参照できるようにしている。
{ inputs }:
let
  identity = import ../../lib/identity.nix;
in
{
  inherit identity;

  # nix/lib/shell.nix: require_nix_features / sudo_nix / is_wsl / is_darwin /
  # require_nixbld / find_wslconfig / check_wslconfig / rebuild_ksycoca
  shell = import ../../lib/shell.nix;

  # nix/lib/targets.nix: システムごとの attr 名・表示 (username だけ注入して使う)
  targetsFor =
    system:
    import ../../lib/targets.nix {
      inherit system;
      inherit (identity) username;
    };

  # system-manager (numtide/system-manager) の flake input
  # OS 層 (systemConfigs) の適用に使う
  systemManager = inputs.system-manager;
}
