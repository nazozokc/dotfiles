# nix/modules/system/nix-installation.nix
# ホストの Nix 導入モードの宣言と、その実行時検証
#
# userborn が何をするか (system-manager は USERBORN_MUTABLE_USERS=true):
#   - 既存グループは `(既存メンバー − 前回 config) ∪ 今回 config` に更新される。
#     つまり「空を宣言した」だけでは既存の所属は消えない。
#   - 一方「前回 config にあったが今回 config に無い」グループは空にされる (drain)。
#   - `users-groups.nix` は `wheel` / `sudo` / `audio` / `video` / `nixbld` を
#     常に gid 付きで宣言する。gid は `mkDefault` なので実ホストの gid を上書きしない。
#
# よってこのモジュールの仕事は「`nixbld` の所属を足すか外すか」だけ。
# 導入モードを誤ると次のどちらかが起きる:
#   - `nixbld` モードと宣言して実際は `user`   : 無意味なグループが増えるだけ
#   - `nixbld` モードと宣言して実際は `daemon` : 実行ユーザーが `nix-daemon` を
#     迂回して `/nix/store` を直接書けるようになる (権限の降格)
#
# 導入モードは Eval 時に観測できない (pure eval なので /etc/nix/nix.conf や
# daemon-socket を読み込めない) ため、宣言し activation 時に実ホストと突き合わせる。
{
  lib,
  config,
  username,
  ...
}:

let
  cfg = config.dotfiles.system;
in
{
  options.dotfiles.system = {
    nixStoreAccess = lib.mkOption {
      type = lib.types.enum [
        "daemon"
        "nixbld"
        "user"
      ];
      default = "daemon";
      example = "nixbld";
      description = ''
        ホストの `/nix/store` を誰がどう書き込むか (Nix の導入モード)。

        | 値        | 該当する導入方法                                                                                            | userborn への宣言 |
        | --------- | ----------------------------------------------------------------------------------------------------------- | ----------------- |
        | `daemon`  | multi-user 導入 (`--daemon` / `apt install nix` / `dnf install nix`)。`nix-daemon` が `nixbld` の build user を管理 | 宣言しない        |
        | `nixbld`  | 旧 installer の single-user 導入 (`/nix/store` が `root:nixbld 1775`)。実行ユーザーが `nixbld` に居る必要がある       | `nixbld` の member に実行ユーザーを追加 |
        | `user`    | 新 installer の single-user 導入 (`/nix/store` が実行ユーザー所有、`nixbld` グループ自体が無い)                     | 宣言しない        |

        既定は `daemon`。最も副作用が小さい (権限昇格なし・build user を壊さない) ため。

        `nixbld` の所属は userborn が管理する対象なので、`users.groups` への宣言で
        足す。`sudo usermod -aG nixbld` で入れた所属は userborn の更新で
        巻き込まれる可能性があり、Nix 側の宣言に書いておく。

        宣言は評価時に実ホストを読めないため、activation の
        `preActivationAssertions` で実ホストと突き合わせ、ずれを報告する。
      '';
    };
  };

  # `nixbld` の member 宣言は single-user (nixbld モード) だけ。
  #
  # 宣言しないモードでは:
  #   - `daemon` : 実行ユーザーが `nixbld` に居ると `nix-daemon` を迂回して
  #     store を直接書ける (権限の降格)。nix-daemon の build user 自体は
  #     userborn の管理外なので、`nixbld` の gid を触っても壊れない。
  #     よってここは「実行ユーザーを足さない」ことだけが目的。
  #   - `user`   : store が実行ユーザー所有で `nixbld` グループ自体が無い。作っても無意味。
  config = {
    users = lib.mkIf (cfg.nixStoreAccess == "nixbld") {
      groups.nixbld.members = [ username ];
    };

    # 宣言した導入モードと実ホストの突き合わせ。
    #
    # 外部コマンド (stat / getent / id / grep) に依存しないよう、test の
    # ファイルテスト演算子と /etc/group の読み出しだけで判定する。
    # sudo の secure_path に依存させないため。
    #
    # 失敗の重み付け:
    #   - 宣言が `nixbld` なのに実ホストが nixbld 以外 → activation を中断する。
    #     そのまま進めると /etc/group の nixbld を潰し、実行ユーザーが nix-daemon を
    #     越えて store を直接書ける状態になる (権限の降格)。
    #   - 実ホストが user / daemon なのに宣言がずれている → warning のみ。
    #     この場合は /etc/group に触れないので実害がない。
    # 1 つのリポジトリを複数ホストで共有するため、ずれ警告では止めない。
    system-manager.preActivationAssertions.nixStoreAccess = {
      enable = true;

      # 空白を含む name は system-manager 側の
      # `failed_assertions+=${name}` が配列 append として解釈し壊れるので使わない
      name = "nixStoreAccess";

      script = ''
        declared="${cfg.nixStoreAccess}"
        me="${username}"
        fatal=0

        # ---- 実モードの判定 -------------------------------------------------
        # 1) nix-daemon が動いていれば multi-user。
        #    socket は Unix ドメインソケットなので -S で判定できる。
        if [ -S /nix/var/nix/daemon-socket ] || [ -S /run/nix-daemon.socket ]; then
          detected=daemon

        # 2) そうでなければ store の所有者を考える。
        #    -O は「存在して、有効 uid が所有者なら真」。
        #    新 installer の single-user 導入 (store が実行ユーザー所有) がこれ。
        elif [ -O /nix/store ]; then
          detected=user

        # 3) それも違う = store が root 所有。nixbld 経由でしか書けない。
        else
          detected=nixbld
        fi

        # ---- nixbld モードの追加確認 ---------------------------------------
        if [ "$detected" = nixbld ]; then
          nixbld_members=""
          nixbld_found=0
          while IFS=: read -r gname _gpw _gid gmem; do
            if [ "$gname" = nixbld ]; then
              nixbld_members="$gmem"
              nixbld_found=1
              break
            fi
          done < /etc/group

          # nixbld グループが無いのに nixbld モード = 別の導入手順
          if [ "$nixbld_found" -eq 0 ]; then
            detected=unknown
          fi
        fi

        # ---- 宣言と実ホストの比較 -------------------------------------------
        if [ "$detected" != "$declared" ]; then
          if [ "$declared" = nixbld ]; then
            echo "dotfiles.system.nixStoreAccess = \"nixbld\" だが実ホストは \"$detected\"。"
            echo "  このまま進めると userborn が実行ユーザーを nixbld グループへ追加し、"
            echo "  nix-daemon を迂回して store を直接書ける状態になる。activation を中断する。"
            fatal=1
          else
            echo "dotfiles.system.nixStoreAccess = \"$declared\" だが実ホストは \"$detected\"。"
            echo "  /etc/group には触れないので実害はない。宣言を直しておくこと。"
          fi
          echo "  (nix/modules/system/nix-installation.nix で宣言し直す)"
          echo ""

          case "$detected" in
            daemon)
              echo "  実際: nix-daemon が稼働中 (multi-user 導入)"
              echo "  → dotfiles.system.nixStoreAccess = \"daemon\";"
              ;;
            user)
              echo "  実際: /nix/store が実行ユーザー所有 (single-user 導入)"
              echo "  → dotfiles.system.nixStoreAccess = \"user\";"
              ;;
            nixbld)
              echo "  実際: /nix/store が root 所有 + nixbld グループあり"
              echo "  → dotfiles.system.nixStoreAccess = \"nixbld\";"
              echo "    さらに実行ユーザーをグループへ追加すること:"
              echo "      sudo usermod -aG nixbld \"$me\""
              ;;
            *)
              echo "  実際: /nix/store が root 所有だが nixbld グループが無い"
              echo "  → 宣言値はいずれにも当てはまらない (導入手順と食い違っています)"
              ;;
          esac

          if [ "$fatal" = 1 ]; then
            exit 1
          fi
        fi

        # ---- nixbld モード: 所属は警告のみ ----------------------------------
        # 今回の switch 自体が userborn で所属を追加するので、
        # まだ所属していなくても止めても解決しない。
        if [ "$detected" = nixbld ]; then
          member=1
          for m in ''${nixbld_members//,/ }; do
            if [ "$m" = "$me" ]; then
              member=0
              break
            fi
          done

          if [ "$member" -ne 0 ]; then
            echo "warning: nixbld グループに $me が居ない。"
            echo "  今回の switch で userborn が所属を追加する (要再ログイン or newgrp nixbld)"
          fi
        fi

        exit 0
      '';
    };
  };
}
