# nix/flake-parts/apps/bootstrap.nix
# apps.default — `nix run github:nazozokc/dotfiles` の入口
#
# 1. ghq の clone 先を用意する (クローン済みなら fetch のみ)
# 2. 実行環境のユーザー名 (id -un) を nix/username.nix へ同期する
# 3. そのディレクトリから `nix run .#switch` へ委譲する
#
# 手元のリポジトリが正なので、既存 clone は fetch のみ (git remote update) とし、
# 作業ツリーと HEAD は一切触らない。
# ghq get -u は git pull --ff-only を実行するため使わない
# (ローカルが分岐していると bootstrap 全体が失敗する)
{ inputs, ... }:
let
  c = import ./common.nix { inherit inputs; };
  repoOwner = c.identity.repoOwner;
in
{
  perSystem =
    { pkgs, ... }:
    {
      apps.default = {
        type = "app";
        meta.description = "bootstrap: リポジトリを用意して switch へ委譲する";
        program = "${pkgs.writeShellScriptBin "dotfiles" ''
          set -eo pipefail

          ${c.shell.nixFeatureGuard}

          # ghq root の解決順は 環境変数 → $HOME/ghq
          # ([ghq] root の git config は dotfiles 未適用時には存在しないため参照しない)
          root="''${GHQ_ROOT:-$HOME/ghq}"
          # clone 先はリポジトリ所有者で決める (ローカルユーザー名とは別)
          remote="github.com/${repoOwner}/dotfiles"
          dir="$root/$remote"

          # git バイナリの解決。ghq も git も無い初期環境では
          # nix shell で一時的に git を呼び出す
          git_do() {
            if command -v git >/dev/null 2>&1; then
              git "$@"
            else
              nix shell nixpkgs#git -c git "$@"
            fi
          }

          # クローン済みなら fetch のみ、未クローンなら clone
          # ghq は submodule を初期化するため git 必須。ghq が無ければ git で代用
          if [ -d "$dir/.git" ]; then
            git_do -C "$dir" remote update
          elif command -v ghq >/dev/null 2>&1; then
            GHQ_ROOT="$root" ghq get "$remote"
          else
            git_do clone "https://$remote.git" "$dir"
          fi

          cd "$dir"

          # ユーザー名を実行環境から反映する。
          # flake の pure 評価では環境変数を参照できないため、
          # bootstrap がこのファイル (単一ソース) を書き換える。
          # 書き換えた後なら switch / home-manager の再評価も同値を見る。
          user="$(id -un)"
          file="nix/username.nix"
          current=""
          if [ -f "$file" ]; then
            current="$(sed -n 's/^"\(.*\)"$/\1/p' "$file" | head -n1)"
          fi

          if [ "$current" = "$user" ]; then
            echo "  user  : $user"
          elif [ -e "$file" ] && [ ! -w "$file" ]; then
            echo "  [!] $file に書き込めません (書き込み権限なし)"
            echo "      定義は $current のままです"
          else
            if [ -f "$file" ]; then
              # 値が書かれた行だけ差し替える (コメントは残す)
              tmp="$(mktemp)"
              sed "s/^\"$current\"$/\"$user\"/" "$file" > "$tmp"
              mv "$tmp" "$file"
            else
              printf '# ユーザー名の単一ソース (bootstrap が id -un から自動生成)\n# 詳細: nix/README.md の「username の決定」\n"%s"\n' "$user" > "$file"
            fi
            echo "  user  : ''${current:-未定義} → $user ($file を更新 / commit してください)"
          fi

          echo ""
          echo "  repo  : $dir"
          echo "  head  : $(git_do rev-parse --short HEAD) / $(git_do branch --show-current)"
          echo ""

          # ユーザー層・OS 層の適用は switch に委譲する
          # (OS 自動判定・事前チェック・WSL の .wslconfig チェックを持ちえているため)
          exec nix run .#switch
        ''}/bin/dotfiles";
      };
    };
}
