# nix/lib/shell.nix
# app が注入する共通シェルヘルパ (bash の関数定義のみ。実行は apps 側で行う)
#
# apps.default / switch / build / update / system-* が全部共有する唯一の場所。
# ここで作った文字列を各 app の writeShellScriptBin へ埋め込む。
{
  # nix-command / flakes を確実に有効にする共通シェルヘルパ
  #
  # なぜ必要か:
  #   `--extra-experimental-features` は起動した nix プロセスにのみ効く設定で、
  #   子プロセス (app 内の nix、home-manager が内部で起動する nix) へは
  #   伝播しない。実測 (Nix 2.35):
  #     NIX_CONFIG="experimental-features =" \
  #       nix run --extra-experimental-features "nix-command flakes" .#app
  #     → app 内の nix には experimental-features が無く
  #       `nix flake check` が
  #       "experimental Nix feature 'nix-command' is disabled" で失敗する
  #   つまり初回 bootstrap は 2 段目 (nix run .#switch) で必ず落ちる。
  #
  # 対処:
  #   NIX_CONFIG はプロセス環境なので子・孫プロセスまで継承される。
  #   ただし list 型設定 (experimental-features) は NIX_CONFIG の指定で
  #   設定ファイルの値を置き換えてしまうため、
  #   実効値 (nix config show) に不足分を加えたものを書き戻す。
  #   既に有効な環境では何もしない (NIX_CONFIG を汚さない)。
  nixFeatureGuard = ''
    # 実効値の experimental-features に $2 が含まれるか
    nix_has_feature() {
      case " $1 " in
        *" $2 "*) return 0 ;;
        *) return 1 ;;
      esac
    }

    # 不足している experimental feature を NIX_CONFIG へ足す
    require_nix_features() {
      local features forced nl

      # `nix config show` 自体が nix-command を要求する。
      # 素で通るならその出力が実効値 (システム → ユーザー設定の順で解決済み)。
      features="$(nix config show 2>/dev/null | sed -n 's/^experimental-features[[:space:]]*=[[:space:]]*//p' || true)"

      if [ -z "$features" ]; then
        # 無効な環境。フラグを一時的に与えて実効値を読む。
        # (この出力には環境設定側の feature も混ざっている)
        features="$(nix --extra-experimental-features "nix-command flakes" config show 2>/dev/null \
          | sed -n 's/^experimental-features[[:space:]]*=[[:space:]]*//p' || true)"
        forced=1
      else
        forced=0
      fi

      # 環境側で有効なら何もしない
      if [ "$forced" = 0 ] && nix_has_feature "$features" flakes; then
        return 0
      fi

      nix_has_feature "$features" nix-command || features="$features nix-command"
      nix_has_feature "$features" flakes || features="$features flakes"

      nl=$'\n'
      export NIX_CONFIG="''${NIX_CONFIG:+$NIX_CONFIG$nl}experimental-features = $features"

      echo "[!] nix-command / flakes が未有効だったため、この実行だけ NIX_CONFIG で有効化します"
      echo "    (--extra-experimental-features は子プロセスへ伝播しないため)"
      echo ""
    }

    # sudo は既定 (env_reset) で環境変数を捨てるため NIX_CONFIG を引き継ぐ
    sudo_nix() {
      if [ -n "''${NIX_CONFIG-}" ]; then
        sudo env "NIX_CONFIG=$NIX_CONFIG" "$@"
      else
        sudo "$@"
      fi
    }

    require_nix_features
  '';

  # 実行環境の判定 (WSL / macOS / nixbld 所属 / .wslconfig / ksycoca)
  detectHelpers = ''
    is_wsl() {
      [ -d /run/WSL ] || grep -qi microsoft /proc/version 2>/dev/null
    }

    is_darwin() {
      [ "$(uname)" = "Darwin" ]
    }

    # single-user Nix (daemon 無し) では /nix/store (root:nixbld 1775) への
    # 書き込みに nixbld グループ所属が必須。
    # system-manager の userborn が /etc/group を宣言どおり書き戻すため、
    # installer が追加した所属が一度消えると nix アプリがすべて
    # "Permission denied" (=「実行権限がなくなる」ように見える) で死ぬ。
    # 再発を防げない段階でも、原因を即座に特定できるように先に検出する。
    #
    # 判定のみ。0 = 問題なし / 1 = 不足
    nixbld_membership_ok() {
      # macOS は nix-daemon が store を管理するので対象外
      if is_darwin; then
        return 0
      fi

      # daemon 運用 (multi-user) なら store 管理は daemon 任せ
      if [[ -S /nix/var/nix/daemon-socket || -e /run/nix-daemon.socket ]]; then
        return 0
      fi

      if id -nG | grep -qw nixbld; then
        return 0
      fi

      return 1
    }

    # 不足していても止めない版 (switch)。理由は後段のビルドで出るが、
    # あのエラー (Permission denied) だけでは原因が特定できないため、
    # 先に原因を明示だけしておく。
    warn_nixbld() {
      if nixbld_membership_ok; then
        return 0
      fi

      echo "[!] nixbld グループに所属していません" >&2
      echo "    single-user Nix では /nix/store への書き込みに nixbld 所属が必要です" >&2
      echo "    対処: sudo usermod -aG nixbld \"$USER\"" >&2
      echo "    (既存シェルには反映されません: newgrp nixbld または再ログイン)" >&2
    }

    # 不足していれば停止させる版 (build / system-*)
    require_nixbld() {
      if nixbld_membership_ok; then
        return 0
      fi

      warn_nixbld
      exit 1
    }

    # Windows ユーザープロファイルの .wslconfig パスを検出
    # (USERPROFILE env が無い場合は /mnt/c/Users/ から実ユーザーをスキャン)
    find_wslconfig() {
      local profile
      profile="''${USERPROFILE%/}"
      if [[ -z "$profile" ]]; then
        for d in /mnt/c/Users/*/; do
          case "$(basename "$d")" in
            "All Users"|"Default"|"Default User"|"Public") continue ;;
          esac
          if [[ -e "$d/.wslconfig" || -d "$d/AppData" ]]; then
            profile="''${d%/}"
            break
          fi
        done
      fi
      [[ -n "$profile" ]] && echo "$profile/.wslconfig"
    }

    # .wslconfig が dotfiles の wsl/.wslconfig と一致するか事前チェック
    # (Windows側 %USERPROFILE%\.wslconfig を参照するため)
    check_wslconfig() {
      local wslconfig target
      wslconfig="$(find_wslconfig)"
      if [[ -z "$wslconfig" || ! -e "$wslconfig" ]]; then
        echo "[!] .wslconfig が見つかりません (''${wslconfig:-/mnt/c/Users/*/})"
        echo "    Windows 側で手動コピー: cp wsl/.wslconfig \$env:USERPROFILE\\.wslconfig"
      elif [[ -L "$wslconfig" ]]; then
        target="$(readlink "$wslconfig")"
        case "$target" in
          *"/wsl/.wslconfig"|*"\\wsl\\.wslconfig") echo "[ok] .wslconfig -> $target" ;;
          *) echo "[!] .wslconfig のリンク先が dotfiles の wsl/.wslconfig ではありません: $target" ;;
        esac
      else
        echo "[!] $wslconfig は symlink ではありません (手動で管理してください)"
      fi
    }

    # KDE の KService キャッシュ (ksycoca) は XDG_DATA_DIRS 配下の
    # .desktop を「ディレクトリ mtime」で比較して更新要否を判定する。
    # nix store は再現性のため mtime が epoch (=1) に固定されているので、
    # home-manager の世代が切り替わっても ~/.nix-profile/share の
    # mtime は変わらず、ksycoca は「変化なし」と判断して旧 store パスを
    # 保持し続ける。結果として GUI 起動が
    # "You are not authorized to execute this file." で全滅する。
    # (ファイルのパーミッションは正常。壊れているのはキャッシュだけ)
    #
    # kbuildsycoca6 は mtime に関係なく全件読み直すので、世代切替後に
    # 明示実行すれば symlink の解決結果へ必ず追従する。
    # ツールが無い環境 (KDE 未導入) では何もしない。
    rebuild_ksycoca() {
      is_darwin && return 0

      local builder=""
      for c in kbuildsycoca6 kbuildsycoca5; do
        if command -v "$c" >/dev/null 2>&1; then
          builder="$c"
          break
        fi
      done

      if [[ -z "$builder" ]]; then
        return 0
      fi

      # ksycoca を参照しているプロセスが居なければ何もしない (WSL 等の軽量環境)
      if ! pgrep -x plasmashell >/dev/null 2>&1 \
        && ! pgrep -x kded6 >/dev/null 2>&1; then
        return 0
      fi

      echo "[ksycoca] KService キャッシュを再構築 ..."
      if ! "$builder" --noincremental; then
        local backup
        backup="$HOME/.cache/ksycoca-stale-$(date +%Y%m%d-%H%M%S)"
        echo "[ksycoca] 再構築に失敗しました (旧キャッシュを $backup へ退避します)" >&2
        mkdir -p "$backup"
        mv -f "$HOME"/.cache/ksycoca6_* "$backup"/ 2>/dev/null || true
        return 0
      fi

      # KSharedDataCache は mmap で読むので、既存プロセスは再構築前の
      # inode を掴んだままになる。ファイルは新くなっているが、
      # 実行中のセッション (アプリメニュー等) は旧パスを参照し続ける。
      # 破壊的な plasmashell 再起動は自動では行わない。
      echo "         実行中のセッションは再構築前の inode を保持しています"
      echo "         アプリメニューから起動しない場合は:"
      echo "           systemctl --user restart plasma-plasmashell.service"
    }
  '';
}
