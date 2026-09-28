{
  description = "nazozo dotfiles (multi-system, apps + nom)";

  # ---------------------------------------------------------------------------
  # Binary cache: この flake では設定しない (cache.nixos.org のみ)
  #
  # Nix 2.35 では nixConfig は client-specified 設定として扱われ、
  # restricted setting (substituters / trusted-public-keys) は
  # Trusted User でないクライアントから渡せない。
  #   → extra-substituters / extra-trusted-public-keys は無視される
  #   → `ignoring untrusted substituter` 警告が出るだけで効かない
  #
  # cache.nixos.org は Nix が信頼済みとしてハードコードしているため
  # 追加の substituters 設定は不要。
  # サードパーティ cache を使いたい場合は
  # /etc/nix/nix.conf (OS 層 = system-manager) 側で設定する。
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # Flake inputs
  # ---------------------------------------------------------------------------
  inputs = {
    # Nix パッケージセット (unstable チャンネル)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # flake を複数モジュールに分割するためのフレームワーク
    flake-parts.url = "github:hercules-ci/flake-parts";

    # LLM エージェントツール群
    llm-agents.url = "github:numtide/llm-agents.nix";

    # ユーザー環境管理 (nixpkgs に追従)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS システム設定管理
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GitHub CLI 拡張: コントリビューショングラフ表示
    gh-graph = {
      url = "github:kawarimidoll/gh-graph";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GitHub CLI 拡張: 日報生成
    gh-nippou = {
      url = "github:ryoppippi/gh-nippou";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GitHub CLI 拡張: 自慢ツール (flake 非対応なので flake = false)
    gh-brag = {
      url = "github:jackchuka/gh-brag";
      flake = false;
    };

    # nix-index の DB をビルド済みで提供 (nix-index 自体のビルドをスキップ)
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude Code 用スキル管理フレームワーク
    agent-skills-nix = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 秘密鍵管理
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GPU ライブラリラッパー (非 NixOS で Nix GUI アプリを動かす)
    nixGL = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Linux OS 設定管理 (非 NixOS ディストリで NixOS モジュールを扱えるようにする)
    # macOS 側の nix-darwin に相当する役割
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ---------------------------------------------------------------------------
    # x86_64-darwin (Intel Mac) 専用スタック
    # nixpkgs 26.11 で x86_64-darwin のサポートが削除されたため、
    # 最後に対応している nixpkgs 26.05 系を利用する (2026 年末まで保守)
    # ---------------------------------------------------------------------------
    nixpkgs-intel = {
      url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    };
    home-manager-intel = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    darwin-intel = {
      # nix-darwin は nixpkgs のリリースと対応するブランチを使う (26.05 系)
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    llm-agents-intel = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    gh-graph-intel = {
      url = "github:kawarimidoll/gh-graph";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    gh-nippou-intel = {
      url = "github:ryoppippi/gh-nippou";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
  };

  # ---------------------------------------------------------------------------
  # Flake outputs
  # ---------------------------------------------------------------------------
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      darwin,
      gh-graph,
      gh-nippou,
      gh-brag,
      nix-index-database,
      llm-agents,
      treefmt-nix,
      agent-skills-nix,
      sops-nix,
      nixGL,
      system-manager,
      # x86_64-darwin (Intel Mac) 専用スタック
      nixpkgs-intel,
      home-manager-intel,
      darwin-intel,
      llm-agents-intel,
      gh-graph-intel,
      gh-nippou-intel,
      ...
    }:
    let
      # username の単一ソースは nix/username.nix
      # (flake の pure 評価では環境変数・whoami を参照できないため)
      # nix/shared.nix はこの値を受け取る側
      # bootstrap が id -un へ自動設定する (ローカルユーザー名)
      username = "nazozokc";

      # この dotfiles リポジトリの GitHub 所有者。
      # clone 先の ghq レイアウト (github.com/<owner>/dotfiles) に使う。
      # ローカルユーザー名 (nix/username.nix) とは別物なので、
      # 別ユーザーで運用していても clone 先は変わらない。fork 時だけ変更する。
      repoOwner = "nazozokc";

      # カスタム overlay (./nix/overlays/default.nix)
      overlay = import ./nix/overlays;

      # nixpkgs インスタンス生成ヘルパー (nix/lib/pkgs.nix)
      # Intel Mac (x86_64-darwin) は 26.05 系スタックを使い分ける
      pkgsFor = import ./nix/lib/pkgs.nix {
        inherit
          nixpkgs
          nixpkgs-intel
          llm-agents
          llm-agents-intel
          gh-graph
          gh-graph-intel
          gh-nippou
          gh-nippou-intel
          overlay
          ;
      };

      # Linux 向け home-manager 設定生成 (nix/modules/linux/build.nix)
      mkLinuxHomeConfig = import ./nix/modules/linux/build.nix {
        inherit
          self
          username
          pkgsFor
          home-manager
          nix-index-database
          sops-nix
          agent-skills-nix
          nixGL
          ;
      };

      # WSL 向け home-manager 設定生成 (nix/modules/wsl/build.nix)
      mkWSLHomeConfig = import ./nix/modules/wsl/build.nix {
        inherit
          self
          username
          pkgsFor
          home-manager
          nix-index-database
          sops-nix
          agent-skills-nix
          ;
      };

      # macOS (nix-darwin) 向け設定生成 (nix/modules/macos/build.nix)
      # Apple Silicon/Intel で 26.11/26.05 系スタックを使い分ける
      mkDarwinConfig = import ./nix/modules/macos/build.nix {
        inherit
          self
          username
          pkgsFor
          nixpkgs
          darwin
          darwin-intel
          home-manager
          home-manager-intel
          sops-nix
          agent-skills-nix
          ;
      };

      # Linux 向け OS 層設定生成 (nix/modules/system/build.nix)
      # systemd ベースの全 Linux ディストロが同じモジュール構成を使う。
      # プラットフォーム差分は nixpkgs.hostPlatform のみ。
      mkSystemConfig = import ./nix/modules/system/build.nix {
        inherit
          system-manager
          username
          ;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports = [
        ./nix/modules/home/packages/treefmt.nix
      ];
      systems = [
        "x86_64-linux" # メイン PC (Arch Linux)
        "aarch64-linux" # ARM Linux (VPS など)
        "aarch64-darwin" # macOS (Apple Silicon)
        "x86_64-darwin" # macOS (Intel Mac)
      ];

      # -------------------------------------------------------------------
      # perSystem: systems に列挙した各システムで自動展開されるセクション
      # -------------------------------------------------------------------
      perSystem =
        { system, ... }:
        let
          pkgs = pkgsFor system;

          # システム判定
          isDarwin = builtins.match ".*-darwin" system != null;

          # darwin 設定名 (Apple Silicon: 無印 / Intel: -x86_64 サフィックス)
          darwinConfigName = if system == "x86_64-darwin" then "${username}-x86_64" else username;

          # nix run .#build で参照するビルドターゲット
          hmConfig =
            if isDarwin then
              "darwinConfigurations.${darwinConfigName}.system"
            else
              "homeConfigurations.${username}.activationPackage";

          # nix run .#switch で渡す --flake ターゲット
          flakeTarget =
            if isDarwin then
              ".#${darwinConfigName}"
            else
              ".#${username}${if system == "aarch64-linux" then "-aarch64" else ""}";

          # OS 層設定 (system-manager) の設定名。
          # homeConfigurations と同じ命名規則に揃える
          systemConfigName = "${username}${if system == "aarch64-linux" then "-aarch64" else ""}";

          # app 実行時に表示する人間向けのシステム名
          sysLabel =
            if system == "x86_64-linux" then
              "Linux (x86_64)"
            else if system == "aarch64-linux" then
              "Linux (aarch64)"
            else if system == "aarch64-darwin" then
              "macOS (Apple Silicon)"
            else if system == "x86_64-darwin" then
              "macOS (Intel)"
            else
              system;

          printInfo = cmd: ''
            echo "  system : ${sysLabel}"
            echo "  target : ${flakeTarget}"
            echo "  cmd    : ${cmd}"
            echo ""
          '';

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

          # Shared shell helpers for runtime environment detection
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
            require_nixbld() {
              # macOS は nix-daemon が store を管理するので対象外
              is_darwin && return 0

              # daemon 運用 (multi-user) なら store 管理は daemon 任せ
              if [[ -S /nix/var/nix/daemon-socket || -e /run/nix-daemon.socket ]]; then
                return 0
              fi

              if ! id -nG | grep -qw nixbld; then
                echo "[ERROR] nixbld グループに所属していません" >&2
                echo "        single-user Nix の /nix/store への書き込みに nixbld 所属が必要です" >&2
                echo "" >&2
                echo "        対処: sudo usermod -aG nixbld \"$USER\"" >&2
                echo "        (既存シェルには反映されません: newgrp nixbld または再ログイン)" >&2
                exit 1
              fi
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
        in
        {
          # perSystem モジュール (treefmt-nix など) が参照する pkgs を
          # x86_64-darwin では 26.05 系スタックに差し替える
          _module.args.pkgs = pkgsFor system;

          devShells = {
            default = pkgs.mkShell {
              name = "dotfiles-default";
              packages = with pkgs; [
                git
                just
              ];
              shellHook = ''
                echo "[devShell:default]"
                git --version
                just --version
              '';
            };

            nix = pkgs.mkShell {
              name = "dotfiles-nix";
              packages = with pkgs; [
                nixfmt
                statix
                deadnix
                nil
                nixd
              ];
              shellHook = ''
                echo "[devShell:nix]"
                nix --version
                nixfmt --version
                statix --version
                deadnix --version
              '';
            };

            editors = pkgs.mkShell {
              name = "dotfiles-editors";
              packages = with pkgs; [
                stylua
                nodejs_24
              ];
              shellHook = ''
                echo "[devShell:editors]"
                stylua --version
                node --version
              '';
            };
          };

          apps = {
            # nix run github:nazozokc/dotfiles
            # bootstrap: ghq でリポジトリを用意してから switch へ委譲する
            #
            # 手元のリポジトリが正なので、既存 clone は fetch のみ (git remote update)
            # とし、作業ツリーと HEAD は一切触らない。
            # ghq get -u は git pull --ff-only を実行するため使わない
            # (ローカルが分岐していると bootstrap 全体が失敗する)
            default = {
              type = "app";
              meta.description = "bootstrap: リポジトリを用意して switch へ委譲する";
              program = "${pkgs.writeShellScriptBin "dotfiles" ''
                set -eo pipefail

                ${nixFeatureGuard}

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

            # nix run .#switch
            # OS 自動検出でユーザー層と OS 層の両方を適用する
            #   WSL   … home-manager のみ (OS 層は Windows 側 .wslconfig の管轄)
            #   macOS … nix-darwin (nix-darwin が OS 層まで持つ)
            #   Linux … home-manager → system-manager (OS 層・sudo 必要)
            switch = {
              type = "app";
              meta.description = "OS 自動判定でユーザー層と OS 層を適用する";
              program = "${pkgs.writeShellScriptBin "switch" ''
                set -eo pipefail

                ${nixFeatureGuard}

                ${detectHelpers}

                require_nixbld

                # 事前チェック: flake の評価エラーを検出
                echo "[pre-flight] nix flake check --no-build ..."
                nix flake check --no-build
                echo ""

                if is_wsl; then
                  echo "  system : WSL (x86_64)"
                  echo "  target : .#${username}-wsl"
                  echo "  cmd    : switch"
                  echo ""
                  check_wslconfig
                  nix run nixpkgs#home-manager -- switch --flake .#${username}-wsl |& ${pkgs.nix-output-monitor}/bin/nom
                  rebuild_ksycoca
                elif is_darwin; then
                  echo "  system : ${sysLabel}"
                  echo "  target : ${flakeTarget}"
                  echo "  cmd    : switch"
                  echo ""
                  # sudo は既定で環境変数を捨てるため、NIX_CONFIG を引き継ぐ
                  sudo_nix nix run nix-darwin -- switch --flake ${flakeTarget} |& ${pkgs.nix-output-monitor}/bin/nom
                else
                  echo "  system : ${sysLabel}"
                  echo "  target : ${flakeTarget}"
                  echo "  cmd    : switch"
                  echo ""
                  nix run nixpkgs#home-manager -- switch --flake ${flakeTarget} |& ${pkgs.nix-output-monitor}/bin/nom

                  # 世代切替で nix store のパスが変わる。ksycoca は mtime が
                  # epoch 固定の store を変更検知できないため、明示再構築する。
                  rebuild_ksycoca

                  # ネイティブ Linux は OS 層 (system-manager) も適用する。
                  # WSL は .wslconfig (Windows 側) の管轄なので対象外。
                  # macOS は nix-darwin が OS 層まで持つため対象外。
                  #
                  # 順序: home-manager (ユーザー層) → system-manager (OS 層)。
                  # sudo 認証が失敗してもユーザー層は適用済みになる。
                  echo ""
                  echo "  system : ${sysLabel}"
                  echo "  target : .#systemConfigs.${systemConfigName}"
                  echo "  cmd    : system-switch"
                  echo ""
                  echo "[!] OS 層を適用します (/etc と systemd システムユニット・sudo 必要)"
                  echo ""
                  nix run ${system-manager}#default -- switch --flake '.#${systemConfigName}' --sudo
                fi
              ''}/bin/switch";
            };

            # nix run .#build
            build = {
              type = "app";
              meta.description = "switch 対象のビルドのみ行う（適用はしない）";
              program = "${pkgs.writeShellScriptBin "build" ''
                set -eo pipefail

                ${nixFeatureGuard}

                ${detectHelpers}

                require_nixbld

                if is_wsl; then
                  echo "  system : WSL (x86_64)"
                  echo "  target : .#${username}-wsl"
                  echo "  cmd    : build"
                  echo ""
                  ${pkgs.nix-output-monitor}/bin/nom build .#homeConfigurations.${username}-wsl.activationPackage
                elif is_darwin; then
                  echo "  system : ${sysLabel}"
                  echo "  target : ${hmConfig}"
                  echo "  cmd    : build"
                  echo ""
                  ${pkgs.nix-output-monitor}/bin/nom build .#${hmConfig}
                else
                  echo "  system : ${sysLabel}"
                  echo "  target : ${hmConfig}"
                  echo "  cmd    : build"
                  echo ""
                  ${pkgs.nix-output-monitor}/bin/nom build .#${hmConfig}
                fi
              ''}/bin/build";
            };

            # nix run .#update
            update = {
              type = "app";
              meta.description = "flake.lock を更新する";
              program = "${pkgs.writeShellScriptBin "update" ''
                set -eo pipefail

                ${nixFeatureGuard}

                ${printInfo "update"}
                nix flake update |& ${pkgs.nix-output-monitor}/bin/nom
              ''}/bin/update";
            };

            # nix run .#system-build
            # system-manager の toplevel (linkFarm) をビルドする。評価のみ・副作用なし
            system-build = {
              type = "app";
              meta.description = "OS 層 (system-manager) の toplevel をビルドする (副作用なし)";
              program = "${pkgs.writeShellScriptBin "system-build" ''
                set -eo pipefail

                ${nixFeatureGuard}

                ${detectHelpers}

                require_nixbld

                if is_darwin; then
                  echo "[!] system-manager は Linux 専用です"
                  exit 1
                fi

                if is_wsl; then
                  echo "[!] WSL は対象外です"
                  echo "    WSL の OS 設定は wsl/.wslconfig (Windows 側) を参照"
                  exit 1
                fi

                echo "  system : ${sysLabel}"
                echo "  target : .#systemConfigs.${systemConfigName}"
                echo "  cmd    : system-build"
                echo ""
                ${pkgs.nix-output-monitor}/bin/nom build .#systemConfigs.${systemConfigName}
              ''}/bin/system-build";
            };

            # nix run .#system-check
            # switch 前の dry-run 相当。sudo 不要。評価エラーと生成物の差分を確認する
            system-check = {
              type = "app";
              meta.description = "OS 層の dry-run。評価と生成物差分を確認する (sudo 不要)";
              program = "${pkgs.writeShellScriptBin "system-check" ''
                set -eo pipefail

                ${nixFeatureGuard}

                ${detectHelpers}

                require_nixbld

                if is_darwin; then
                  echo "[!] system-manager は Linux 専用です"
                  exit 1
                fi

                if is_wsl; then
                  echo "[!] WSL は対象外です"
                  exit 1
                fi

                echo "  system : ${sysLabel}"
                echo "  target : .#systemConfigs.${systemConfigName}"
                echo "  cmd    : system-check"
                echo ""
                # 属性は flake URI の '#' 以降で渡す (--attr フラグは無い)。
                # 素の '.#' では hostname → default の順で解決され、
                # systemConfigs.${systemConfigName} に到達しない
                #
                # system-manager の input は store path に展開されるため、
                # 属性なしの installable は Nix 式として解釈されて失敗する。
                # '#default' を付けて flake として解決させる
                nix run ${system-manager}#default -- build --flake '.#${systemConfigName}'
              ''}/bin/system-check";
            };

            # nix run .#system-switch
            # 実際の適用。/etc と systemd システムユニットを書き換えるため sudo が要る
            system-switch = {
              type = "app";
              meta.description = "OS 層 (/etc・systemd) を適用する (sudo 必要)";
              program = "${pkgs.writeShellScriptBin "system-switch" ''
                set -eo pipefail

                ${nixFeatureGuard}

                ${detectHelpers}

                require_nixbld

                if is_darwin; then
                  echo "[!] system-manager は Linux 専用です"
                  exit 1
                fi

                if is_wsl; then
                  echo "[!] WSL は対象外です"
                  exit 1
                fi

                echo "  system : ${sysLabel}"
                echo "  target : .#systemConfigs.${systemConfigName}"
                echo "  cmd    : system-switch"
                echo ""
                echo "[!] /etc と systemd システムユニットを書き換えます"
                echo "    既存ファイルは .system-manager-backup として退避されます"
                echo ""
                # 属性は flake URI の '#' 以降で渡す (--attr フラグは無い)。
                # 素の '.#' では hostname → default の順で解決され、
                # systemConfigs.${systemConfigName} に到達しない
                #
                # system-manager の input は store path に展開されるため、
                # 属性なしの installable は Nix 式として解釈されて失敗する。
                # '#default' を付けて flake として解決させる
                nix run ${system-manager}#default -- switch --flake '.#${systemConfigName}' --sudo
              ''}/bin/system-switch";
            };
          };
        };

      # -------------------------------------------------------------------
      # flake: perSystem に乗らない静的な出力 (homeConfigurations など)
      # -------------------------------------------------------------------
      flake = {
        # Linux 向け home-manager 設定
        homeConfigurations = {
          ${username} = mkLinuxHomeConfig "x86_64-linux";
          "${username}-aarch64" = mkLinuxHomeConfig "aarch64-linux";
          "${username}-wsl" = mkWSLHomeConfig "x86_64-linux";
        };

        # macOS 向け nix-darwin 設定 (Apple Silicon / Intel Mac)
        darwinConfigurations = {
          ${username} = mkDarwinConfig "aarch64-darwin";
          "${username}-x86_64" = mkDarwinConfig "x86_64-darwin";
        };

        # -------------------------------------------------------------------
        # Linux 向け OS 層設定 (system-manager)
        # -------------------------------------------------------------------
        # home-manager が扱えない /etc・systemd システムユニット等を宣言的に管理する。
        # macOS 側の nix-darwin に相当する役割。
        #
        # 命名は homeConfigurations に揃える:
        #   nazozokc         → x86_64-linux (デスクトップ / VPS などのネイティブ)
        #   nazozokc-aarch64 → aarch64-linux (ARM Linux)
        #
        # プラットフォームを固定する理由:
        #   nix/modules/system/build.nix が nixpkgs.hostPlatform を設定するため、
        #   この derivation の評価は実行マシンに依存しない。
        #   → `nix flake check` を macOS CI で走らせても Linux 向け設定の
        #     評価結果が壊れない
        systemConfigs = {
          ${username} = mkSystemConfig "x86_64-linux";
          "${username}-aarch64" = mkSystemConfig "aarch64-linux";
        };
      };
    };
}
