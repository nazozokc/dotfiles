# nix/flake-parts/checks.nix
# 品質ゲート: deadnix / statix / my-scripts / nu-check / typos
# treefmt の check は treefmt-nix flakeModule (packages/treefmt.nix) が提供する。
#
# 全チェックは flake のソース (${self}) に対して走らせる。
# `nix flake check` に含まれるので、CI は素の flake check で足りる。
{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks = {
        # my-scripts 自体もビルドしてoverlayの評価/依存を検証する
        inherit (pkgs) my-scripts;

        # 未使用バインディングの検出 (--fail: findings で exit 1)
        deadnix = pkgs.runCommand "check-deadnix" { } ''
          echo "deadnix ${self}" >&2
          ${pkgs.deadnix}/bin/deadnix --fail ${self}
          touch $out
        '';

        # Nix リント (warnings で exit 1)
        statix = pkgs.runCommand "check-statix" { } ''
          echo "statix check ${self}" >&2
          ${pkgs.statix}/bin/statix check ${self}
          touch $out
        '';

        # packages/ の Nushell スクリプト構文チェック
        # source するだけで main は実行しない (parse エラーで非ゼロ終了)
        nu-check = pkgs.runCommand "check-nu" { } ''
          echo "nu source ${self}/packages/*.nu" >&2
          for f in ${self}/packages/*.nu; do
            echo "  $f" >&2
            ${pkgs.nushell}/bin/nu --no-config-file -c "source $f"
          done
          touch $out
        '';

        # つづりミス検出 (設定はリポジトリ直下の _typos.toml)
        typos = pkgs.runCommand "check-typos" { } ''
          echo "typos ${self}" >&2
          cd ${self}
          ${pkgs.typos}/bin/typos .
          touch $out
        '';
      };
    };
}
