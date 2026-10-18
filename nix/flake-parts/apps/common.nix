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
  # nixbld_membership_ok / warn_nixbld / require_nixbld /
  # find_wslconfig / check_wslconfig / rebuild_ksycoca
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

  # 同じ input の「未解決 flake ref 文字列」。
  #
  # なぜ必要か: app の program は 1 つの文字列として評価される。program に
  # ${systemManager} (解決済み inputs = 評価済み flake 出力) を埋め込むと、
  # apps.* の評価だけで system-manager flake が出力評価され、
  # その推移的 input である nmt の tarball URL (git.sr.ht) まで強制される。
  # nmt は flake.lock に固定ノードが無いため毎回ネットワーク取得になり、
  # `nix run .#switch` の offline 実行が壊れる (= ネットワークが不安定な環境では
  # 評価が数十秒ブロックされ、その間のNICトラフィックがセッションを巻き込む)。
  #
  # ref 文字列を埋め込めば version は flake.lock から解決されるため、
  # #switch の評価はネットワーク不要になる。OS 層の実行時にだけ取得が要る。
  systemManagerRef = "github:numtide/system-manager";

  # Neovim プラグインの正本ディレクトリ (flake.nix + flake.lock)。
  # 実体とバージョンはここに集約され、nvim/.../plugins/default.nix が farm を組む。
  nvimPlugDir = "nvim/nvim-plug-manage";

  # GitHub API の未認証レート制限は 60/h。プラグイン 135 件を lock すると
  # 確実に越えて HTTP 403 になる。gh がログイン済みなら access-tokens として
  # NIX_CONFIG へ足す (子の nix プロセスまで届く)。
  ghAccessToken = pkgs: ''
          if ! printf '%s' "''${NIX_CONFIG:-}" | ${pkgs.gnugrep}/bin/grep -q '^access-tokens'; then
            _gh_token="$(${pkgs.gh}/bin/gh auth token 2>/dev/null || true)"
            if [ -n "$_gh_token" ]; then
              export NIX_CONFIG="''${NIX_CONFIG:+$NIX_CONFIG
    }access-tokens = github.com=$_gh_token"
            fi
            unset _gh_token
          fi
  '';
}
