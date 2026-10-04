# nix/flake-parts/checks.nix
# 壊れないための仕組み。4 つの層で守る。
#
#   checks.eval         宣言の検証 (nix/lib/declared.nix) を評価時に試す。
#                       評価時に落とす設計が本当に落ちるかを固定する
#   checks.shellcheck   生成前のソース (nix/lib/script/*.sh) を lint する。
#                       連結後の lint は writeShellApplication が担う
#   checks.fake-path    5 pm すべての経路を、1 台の Arch 上で検証する
#   checks.consumer     消費側の公開 API (flakeModules.default /
#                       flakeModules.home-manager)
#                       が約束どおり評価できるかを固定する
#
# ホストに apt / dnf / zypper / yum は無いので、これらは実機では絶対に
# テストできない。PATH を差し替えてスタブを解決させることで、
# 生成されるコマンドと差分計算だけを検証する。
# (パッケージの実際の導入・更新は行わない。sudo も呼ばない)
{
  backends,
  check,
  declared,
  flakeModule,
  flake-parts-lib,
  homeManagerModule,
  inputs,
  self,
  ...
}:
let
  # 消費側 flake に渡す入力一式。
  # perSystem の中では `inputs` は「perSystem の外側に使ってください」と
  # わざと落とすエイリアス扱いだが、nested mkFlake には flake 全体の
  # 入力を渡したいので、ここで捕まえておく
  consumerInputs = inputs;

  # 消費側の self の代わり。nested mkFlake が触るのは outPath と inputs だけ
  selfStub = {
    inherit (self) outPath;
    inputs = consumerInputs;
  };
in
{
  perSystem =
    { lib, pkgs, ... }:
    let
      # flake module が組む nlp と必ず同じ定義を検査する
      nlp = import ../lib/nlp.nix {
        inherit
          backends
          declared
          lib
          pkgs
          ;
      };

      # 宣言の検証 (nix/lib/declared.nix) を意図的に飛ばして作った nlp。
      #
      # 宣言が「1 枚目の防御 (評価時に落とす)」を通り過ぎた場合でも、
      # 「2 枚目の防御 (単一引用符埋め込み + eval 不使用)」で
      # 実行が起きないことを tests/fake-path/run が実測する
      hostileNlp = import ../lib/nlp.nix {
        inherit
          backends
          lib
          pkgs
          ;
        # 宣言に意図的に悪い名前が入っているので、
        # shellcheck の SC2016 (単一引用符 = 展開されない) だけを黙らせる
        excludeShellChecks = [ "SC2016" ];
        declared = {
          # 宣言の検証を通らない名前だけを集める。
          # これらが「1 個の引数として」pm へ渡ることと、
          # コマンドとして実行されないことを確認する
          pacman = [
            "\$(touch PWNED)"
            "a b"
            "'quoted'"
            "x; touch PWNED"
            "*"
          ];
        };
      };

      # tests/fake-path/run を派生の中で回す。
      # nlp の「作り方」だけを差し替えて、同じハーネスで測る
      #
      # mkDerivation ではなく runCommand を使う。
      # stdenv では checkPhase が installPhase より先に走るため、
      # installPhase で作ったディレクトリを cd できない
      harness =
        {
          name,
          subject,
          nlp,
          hostileNlp,
        }:
        pkgs.runCommand name
          {
            nativeBuildInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.gnugrep
            ];
          }
          ''
            cp -r ${../../tests/fake-path} src
            # store からコピーしたファイルは 444 なので書き換え権限を戻す
            chmod -R u+w src
            chmod +x src/stub src/run

            # サンドボックスには /usr/bin/env も /bin/sh も同じ名前では無いので、
            # shebang を nixpkgs の実装へ差し替える。
            # stub は POSIX sh として書いているので bash で走らせても問題ない
            sed -i "1s|^#!.*|#!${pkgs.bash}/bin/bash|" src/run src/stub

            cd src

              # harness は nlp を呼ぶたびにスタブだけの PATH を組み立てるので、
              # ここでは harness 自身が必要とする mktemp / grep だけ用意する。
              # nlp は writeShellApplication が自前で PATH を作るので
              # ここに含める必要は無い
              echo "  ${subject}"
              PATH="${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:$PATH" \
                NLP=${nlp}/bin/nlp \
                NLP_HOSTILE=${hostileNlp}/bin/nlp \
                ./run

              touch $out
          '';

      fakePathHarness = harness {
        name = "fake-path-harness";
        subject = "nlp (nix/lib/nlp.nix を直接)";
        inherit nlp hostileNlp;
      };

      # ------------------------------------------------------------------------
      # 消費側の公開 API
      #
      # 公開 API は「別の flake が使うもの」なので、公開 API の経路を
      # 使わずにテストしても公開 API のテストにはならない。
      # ここでは inputs を移した消費側 flake (tests/consumer/module.nix) を
      # そのまま評価する。lib.evalModules だと perSystem の型付けと
      # apps / packages の転置を自分で再現することになり、
      # 本来の経路と別のものを作ってしまう
      # ------------------------------------------------------------------------
      system = pkgs.stdenv.hostPlatform.system;

      consumerFlake =
        flake-parts-lib.mkFlake
          {
            inputs = consumerInputs;
            # self には自分の出力を入れる。消費側 flake と同じ呼び出し方
            self = selfStub;
          }
          (
            import ../../tests/consumer/module.nix { nlpModule = flakeModule; }
            // {
              # 1 system だけ評価する。check 自体も perSystem で 1 system ずつ走る
              systems = [ system ];
            }
          );

      apps = consumerFlake.apps.${system} or { };
      consumerPackages = consumerFlake.packages.${system} or { };

      # home-manager 版は選択肢が 1 つ (home.packages に載せる) だけなので、
      # home-manager を input に入れないで形と中身を見る
      #
      # home.packages の型は home-manager 側のもの (listOf package) をそのまま再現する。
      # ここを捏造すると「実際に home-manager が使う型が通る」ことを検証にならない
      homeStub =
        { lib, ... }:
        {
          options.home.packages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
          };
        };

      evalHome =
        extra:
        (lib.evalModules {
          specialArgs.pkgs = pkgs;
          modules = [
            homeManagerModule
            homeStub
            extra
          ];
        }).config;

      homeOn = evalHome {
        programs.nlp = {
          enable = true;
          declared.pacman = ../../packages/pacman.nix;
        };
      };

      homeOff = evalHome { programs.nlp.declared.pacman = ../../packages/pacman.nix; };

      # home.packages に入るのは「nlp 1 つ」だけなので、
      # enable = true は 1 件 / false は 0 件で比べる
      homeOnPackages = homeOn.home.packages or [ ];
      homeOffPackages = homeOff.home.packages or [ ];

      # 接頭辞 nlp- の 5 コマンド + apps.default (defaultApp = "diff")
      expectedApps = [
        "default"
        "nlp-adopt"
        "nlp-apply"
        "nlp-diff"
        "nlp-status"
        "nlp-update"
      ];

      appNames = builtins.attrNames apps;

      # 「受理された」だけでは「ファイルの中身が焼き込まれた」ことは分からない。
      # normalized を直接比べる
      imported =
        (check {
          pacman = ../../packages/pacman.nix;
        }).normalized.pacman;

      # 1 件の検査結果。report の形は checks.eval (tests/eval/cases.nix) と揃える
      assertion = name: cond: detail: {
        inherit name;
        ok = cond;
        inherit detail;
      };

      assertions = [
        (assertion "app 名が 4 コマンド + default に揃う" (
          appNames == expectedApps
        ) "期待: ${lib.concatStringsSep " " expectedApps} / 実際: ${lib.concatStringsSep " " appNames}")
        (assertion "各 app に program と description がある" (lib.all (
          n: (apps.${n}.program or "") != "" && (apps.${n}.meta.description or "") != ""
        ) appNames) "実際: ${lib.concatStringsSep " " appNames}")
        (assertion "apps.default が diff と同じ app を指す" (
          (apps.default or null) == (apps."nlp-diff" or null)
        ) "defaultApp = diff を設定しているのに別物を指している")
        (assertion "packages.nlp が出る" (consumerPackages ? nlp) "packages に nlp が無い")
        (assertion "ファイルの宣言が import される" (
          imported == [
            "man-db"
            "bash-completion"
          ]
        ) "実際: ${lib.concatStringsSep " " imported}")
        (assertion "home.packages に nlp が載る" (
          builtins.length homeOnPackages == 1 && (lib.head homeOnPackages).name == "nlp"
        ) "実際: ${builtins.toString (builtins.length homeOnPackages)} 個")
        (assertion "enable = false では home.packages に入らない" (
          homeOffPackages == [ ]
        ) "実際: ${builtins.toString (builtins.length homeOffPackages)} 個")
      ];

      consumerReport = lib.concatMapStringsSep "\n" (
        a: (if a.ok then "PASS " else "FAIL ") + a.name + (if a.ok then "" else " / " + a.detail)
      ) assertions;

      # 生成された app を実際に起動する。
      #
      # 評価だけでは「program が store 内の実行ファイルを指しているか」まで
      # 分からない。app ラッパー → nlp → ホスト判定まで繋がことを見る
      #
      # サンドボックスには pm が無いので「pm 未検出」で止まるのが正解。
      # ここで止まらなければ、nlp が起動していない (配線を壊している)
      #
      # nlp-diff が無いときは評価時に落とす。上の assertion でも検出するが、
      # program を取れないと「何も走らない check」が静かに通ってしまう
      appProgram = apps."nlp-diff".program;

      consumerCheck =
        pkgs.runCommand "consumer-api"
          {
            nativeBuildInputs = [
              pkgs.bash
              pkgs.coreutils
              pkgs.gnugrep
            ];
          }
          ''
            printf '%s\n' "${consumerReport}" > report.txt
            printf '%s\n' "$report"

            # app が起動できること。rc=1 + 「pm なし」の報告が正解
            set +e
            PATH="${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:$PATH" \
              ${appProgram} > app.txt 2>&1
            rc=$?
            set -e

            # 結果も report.txt に積む。stdout にだけ書くと
            # 下の grep に掛からず、落ちた check が通ってしまう
            if [ "$rc" -eq 1 ] && grep -qF 'パッケージマネージャーがありません' app.txt; then
              echo "PASS nlp-app が起動して pm 未検出を報告する" >> report.txt
            else
              echo "FAIL nlp-app の起動 / 期待: rc=1 / 実際: rc=$rc" >> report.txt
              cat app.txt >&2
            fi

            if grep -q '^FAIL' report.txt; then
              cat report.txt >&2
              exit 1
            fi

            printf '  consumer: %s 項目の検査\n' "${builtins.toString (builtins.length assertions)}"
            echo ok > "$out"
          '';

      # 生成前のソースを lint する。
      # 各ファイルは「1 つの責務だけを持つ」ので、連結後にしか
      # 気づけない「ファイル境界をまたぐ変数参照」を_sources_ で拾える
      shellcheck =
        pkgs.runCommand "script-shellcheck"
          {
            nativeBuildInputs = [
              pkgs.shellcheck
              pkgs.coreutils
            ];
          }
          ''
            cd ${../lib/script}
            shellcheck --severity=style *.sh
            echo "  shellcheck: $(ls *.sh | wc -l) ファイル" >&2
            echo ok > "$out"
          '';

      # 宣言の検証を評価時に試す。1 つでも通るはずのものが落ちたら失敗
      evalCheck =
        let
          cases = import ../../tests/eval/cases.nix {
            inherit check lib;
          };
        in
        pkgs.runCommand "declared-eval-check"
          {
            nativeBuildInputs = [
              pkgs.coreutils
            ];
            inherit (cases) report summary;
          }
          ''
            printf '%s\n' "$report" > report.txt
            printf '  %s\n' "$summary"
            if grep -q '^FAIL' report.txt; then
              cat report.txt >&2
              exit 1
            fi
            echo ok > "$out"
          '';
    in
    {
      checks = {
        consumer = consumerCheck;
        eval = evalCheck;
        fake-path = fakePathHarness;
        inherit shellcheck;
      };
    };
}
