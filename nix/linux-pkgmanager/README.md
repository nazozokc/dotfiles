## Quick Start（最小導入）

### flake-parts を使う場合

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    linux-pkgmanager.nix = {
      url = "github:nazozokc/linux-pkgmanager.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [ inputs.linux-pkgmanager.nix.flakeModules.default ];

      nlp = {
        enable = true;
        packages = {
          pacman = [ "bat" "eza" "curl" ];
          apt = [ "bat" "eza" "curl" ];
          dnf = [ "bat" "eza" "curl" ];
        };
      };
    };
}
```

`packages` に書いた pm だけが対象になる。`./packages/apt.nix` のようなファイルを
渡してもよい（[宣言の書き方](#宣言の書き方)）。

```console
$ nix run .#nlp-diff     # 不足分を見る (副作用なし)
$ nix run .#nlp-apply    # 不足分だけ入れる
```

### Home Manager 単体で使う場合

```nix
{ inputs, ... }: {
  imports = [ inputs.linux-pkgmanager.nix.flakeModules.home-manager ];
  programs.nlp = {
    enable = true;
    commonPackages = [ "curl" "git" "jq" ];
    packages = {
      pacman = [ "bat" "eza" ];
      apt = [ "bat" "eza" ];
      dnf = [ "bat" "eza" ];
    };
  };
}
```

`home.packages` に載るのは `nlp` だけ。`switch` のあとに `nlp apply` を手で打つ。

`nix flake init -t github:nazozokc/linux-pkgmanager.nix#minimal` でも同じ最小構成を得られます。

---

# linux-pkgmanager.nix

Nix を宣言の入口として、**ネイティブの**パッケージマネージャー経由で
Linux パッケージを導入する。パッケージ自体を Nix store には置かない。

```nix
# packages/pacman.nix
[
  "man-db"
  "bash-completion"
]
```

これを `nix run` すると、`pacman` が何済みで何が足りないかを報告し、
`apply` で不足分だけ導入する。

宣言を 1 つも書きたくないときは `adopt` が雛形を出す。

```console
$ nix run .#adopt > packages/pacman.nix
```

## 対応 pm

| pm     | 実行ファイル | 明示導入の照会            | 不足判定                                   |
| ------ | ------------ | ------------------------- | ------------------------------------------ |
| pacman | `pacman`     | `pacman -Qqe`             | `pacman -T`（不足名を出す）                |
| apt    | `apt-get`    | `apt-mark showmanual`     | `apt-get install --simulate`（`Inst ` 行） |
| dnf    | `dnf`        | `rpm -qa --userinstalled` | `rpm -q`（充足名を出して反転）             |
| zypper | `zypper`     | `rpm -qa --userinstalled` | `rpm -q`                                   |
| yum    | `yum`        | `rpm -qa`                 | `rpm -q`                                   |

ホストに 1 つでも見つかれば、その pm だけを使う。探す順は
`apt` → `dnf` → `pacman` → `yum` → `zypper`（WSL なら `apt` が先に取られる）。
`status` は 5 つ全部を一覧する。

`yum` は RHEL 7 の rpm に `--userinstalled` が無いので、明示導入と依存導入を
区別できない。`unmanaged` には依存も混ざる。

## 使い方

```console
$ nix run .              # diff と同じ
$ nix run .#diff         # 宣言と導入済みを比較 (副作用なし)
$ nix run .#adopt        # 明示導入済みを宣言の雛形として出す (副作用なし)
$ nix run .#apply        # 不足分だけ導入する
$ nix run .#update       # pm を更新してから不足分を補う
$ nix run .#status       # 検出した pm と宣言の件数
```

`diff` と `status` は pm を一切変更しない。`apply` / `update` だけが
`sudo` を使う。`adopt` も pm を変更しない（**ファイルも書かない**）。
出力は標準出力、人が読む行と注意はすべて標準エラーへ出る。

### adopt

宣言をゼロから書く必要をなくす。既に入っているパッケージを、宣言の雛形として
標準出力に出す。`> packages/<pm>.nix` でそのままリダイレクトできる。

```console
$ nix run .#adopt > packages/apt.nix

  注意  apt には既に 3 件の宣言があります。adopt は導入済み全部を出します
  上書きせず、既存宣言と共通する名前を消してから使ってください
```

出るのは「その pm で明示導入済み」のスナップショットで、既存宣言への差分では
ない。だから既存宣言を消してから使う形は取らない。

```console
$ nix run .#adopt

  # packages/pacman.nix — pacman で導入するパッケージ
  #
  # nlp adopt が生成しました (ホスト: arch)。
  # 明示導入済みパッケージをそのまま列挙しています。
  #
  # ここに書くのは「システムのリソース」だけ。
  #   - /etc の設定、/usr/share/man の man page
  #   - systemd unit、カーネルモジュール、firmware
  # 逆に、ユーザーの製品 (エディタ、言語ランタイム、CLI ツール) は
  # Nix (home-manager の home.packages) 経由で入れる。ここには書かない。
  # 二重管理になり、片方だけ古いと事故る。
  #
  # 宣言から外したパッケージは削除されません。unmanaged として
  # 報告されるだけで、何もしません。
  #
  # 照合は `pacman -T` で行います。

  [
    "git"
    "man-db"
    "vim"
  ]
```

人が読む行と注意は標準エラーへ出る。上の実行で同時に出ているのは:

```console
  pacman: pm が受理できないパッケージ名を宣言から外しました
    - a b
  使える文字: 英数字と . + - _ :
  注意  pacman には既に 2 件の宣言があります。adopt は導入済み全部を出します
  上書きせず、既存宣言と共通する名前を消してから使ってください
```

- pm が検出しなかったものは出さない（5 pm 全部が空のリストになるわけではない）
- 宣言検査が却下する名前は除外し、stderr に列挙する
  （pm の出力をそのまま宣言にすると、**評価時に落ちる宣言**を自分で作ってしまう）
- 照会が失敗したら偽の空リストは出さず、終了コード 2 で止まる
  （空の `[ ]` は「導入済み 0 件」という宣言になり、`diff` が常に「不足なし」になる）
- 照会が 0 件を返した場合は空のリストを出すが、「1 個も返らなかった」と stderr で言う

### 出る情報

```console
$ nix run .#diff

  diff · arch · pacman

  host     arch (pacman) · 2 宣言

  installed   1
  missing     1
    - man-db
  unmanaged  11  宣言に無いが明示導入済み
    - base
    - base-devel
    ... 他 9 個
```

- `installed` … 宣言のうち不足でなかった分
- `missing` … 宣言にあるが未導入。`apply` が入れる
- `unmanaged` … 明示導入済みだが宣言に無い。**報告のみ**、何も起きない
- 一覧は `missing` 20 件、`unmanaged` 10 件まで。超えた分は `... 他 n 個` で畳む
  （省略されるのは表示だけで、宣言や照合には全部に入っている）
- 宣言が空の pm を使うと `pacman は宣言なし (packages/pacman.nix)` だけ出して終わる

```console
$ nix run .#status

  status · arch · pacman

  pm       binary                       declared  lock
    apt       (not found)                       3  -
    dnf       (not found)                       2  -
    pacman    pacman@/usr/bin/pacman            2  free
    yum       (not found)                       2  -
    zypper    (not found)                       2  -
```

`status` は pm に照会しない。実行ファイルのパス、宣言件数、ロックの有無だけを見る。

## 宣言の書き方

宣言は 2 層ある。低位が `declared`、高位が `packages` などのオプションで、
`declared` を書くと高位はすべて無視される。

### 低位: `declared`

pm 名 → リスト（またはファイル）をそのまま書く。優先順位の解決はない。

```nix
nlp.declared = {
  pacman = ./packages/pacman.nix;
  apt = [
    "man-db"
    "bat"
  ];
};
```

### 高位: `packages` / `commonPackages` / `managers`

短い宣言を書くための層。`nix/lib/normalize.nix` が `declared` と同じ形に落とす。

```nix
nlp = {
  packages = {
    pacman = [
      "man-db"
      "bash-completion"
    ];
    apt = [ "man-db" "bash-completion" ];
  };
  commonPackages = [ "curl" "git" ];
  managers.dnf.enable = true; # packages に書かずに pm を有効にする
};
```

解決の順序（`nix/lib/normalize.nix`）:

| 段階              | 内容                                                                    |
| ----------------- | ----------------------------------------------------------------------- |
| 1. どちらを使う   | `declared` が空でなければ `declared` だけを使う。高位はすべて無視する   |
| 2. 有効な pm      | `packages` に pm 名がある ∪ `managers.<pm>.enable = true` ∪ 検出した pm |
| 3. 宣言を組み立て | `packages.<pm> ++ commonPackages`。重複は 1 個に畳む                    |

現行の実装そのままの注意:

- `autoDetect = true` は `backends.<pm>.detect` を要求するが、`backends.nix` に
  `detect` フィールドがまだ無いので **1 pm も有効にならない**。pm を列挙したい
  ときは `packages` か `managers` を使う
- `commonPackages` は「有効な pm」の宣言にだけ足される。有効な pm が 1 つも無い
  と足す先が無いので、何もしない
- `packages.<pm>` にファイル（パス）を書くと、そのパスがそのまま宣言になる。
  `commonPackages` は連結しない
- `managers.<pm>.enable = false` は pm を宣言から外す指定ではない。
  `packages.<pm>` を書いている pm は有効なまま残る。宣言から外すのは
  `packages` から消すこと
- `update` サブモジュール（`enable` / `onActivation` / `flags`）は宣言だけで、
  まだ実行体に配線していない。`nlp update` は手動で叩く
- どちらの層でも宣言検査（[書けない名前](#書けない名前)）は同じものを通る

### パッケージ名

`packages/<pm>.nix` は素のリスト。パッケージ名は、その pm が受理する名前で書く。
同じ用途でも pm をまたぐと名前が違うことがある。宣言は pm ごとに 1 ファイルに
分けても、1 つの flake にインラインで書いてもよい。

| 用途     | pacman            | apt               | dnf               | zypper / yum      |
| -------- | ----------------- | ----------------- | ----------------- | ----------------- |
| man page | `man-db`          | `man-db`          | `man-pages`       | `man`             |
| 補完     | `bash-completion` | `bash-completion` | `bash-completion` | `bash-completion` |

### 書けない名前

パッケージ名は `英数字と . + - _ :` だけを使います。
空白や `$` / `;` / `\`` / glob 文字を含む名前は**評価時にエラー**になる。

```console
$ nix run .
error: nlp: declared.pacman (/nix/store/…-source/packages/pacman.nix) の宣言に
       pm が受理できないパッケージ名があります
       名前: "ripgrep; rm -rf /"
       使える文字: 英数字と . + - _ :
```

インラインで書いた場合は `declared.pacman` とだけ出るので、
どの pm のどの宣言が悪いのかがそのまま分かる。

黙って直さない。空白を含む名前は引数の区切りに裂け、宣言に無い名前を
黙って落とすと「不足なし」に見える。どちらも嘘になるので、黙って直すより落とす。

| 名前                        | 判定           |
| --------------------------- | -------------- |
| `gcc-c++` `python3.11`      | 受理           |
| `lib32-gtk3` `perl-Foo_bar` | 受理           |
| `a b` `ripgrep; rm -rf /`   | 評価時にエラー |
| `x$(id)` `x\`id\``          | 評価時にエラー |
| `*` `-rf` `foo\tbar`        | 評価時にエラー |

`nix run .` は `packages/<pm>.nix` の宣言を読み、`nlp` を組み立てる前に
この検査を通す。**コマンドを 1 度も実行する前に**落とす。

この規則は宣言検査と `adopt` で同じ定義を使う。`adopt` が pm の出力を
そのまま宣言へ書くと、`nix run .` が評価時に落ちるのは自分で作った
宣言が原因になってしまう。だから `adopt` 側でも却下される名前を外す。

宣言に**存在しない名前**(形は正しいが pm が持っていないもの)を混ぜた場合は
評価時に落ちないので、実行時に落とす。`nlp` は照合コマンドの終了コードと
stderr を pm ごとに判定し、答えが壊れていれば終了コード 2 で止まる。

```console
  apt: 照合コマンドが異常です (rc=100)
  宣言に実在しないパッケージ名があるか、pm が実行できない状態
    E: Unable to locate package opencode
```

pm ごとに 1 ファイルなので、対象をまたぐ宣言は素直に書ける。

## 他の flake から使う

このリポジトリは flake input として取り込み、消費側の flake で宣言する。
実行体はその評価で組み立てられる。導入そのものはホストの pm と `sudo` が要るので、
`nix build` や評価の途中では走らない。`nix run .#nlp-apply` が、その flake の宣言で動く。

### flake-parts

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    linux-pkgmanager.nix = {
      url = "github:nazozokc/linux-pkgmanager.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.linux-pkgmanager.nix.flakeModules.default ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # 宣言は flake の設定。packages/*.nix を消費側に置かない
      nlp.declared = {
        # 1 pm = 1 ファイルに分けるときは、パスをそのまま書く。
        # このリポジトリ自身の packages/<pm>.nix と同じ形
        pacman = ./packages/pacman.nix;
        apt = [
          "man-db"
          "bat"
        ];
      };
    };
}
```

`declared` の値はリストでもパスでもよい。パスは評価時に `import` され、
中身がリストでなければ評価時に落ちる。混在も許す（pm ごとに 1 つの値）。

```nix
{
  # packages/pacman.nix
  [
    "man-db"
    "bash-completion"
  ]
}
```

このツールが出すのは実行体だけ。いつ動かすかは消費側の config が決める。
評価しただけではホストの pm は動かない。

```nix
# たとえば自分の flake で switch という名前に載せる。名前はユーザー側の都合。
apps.switch = config.apps.nlp-apply;
```

`declared` の代わりに高位の `packages` / `commonPackages` / `managers` でもよい。
解決の規則は [宣言の書き方](#宣言の書き方) に書いたとおり。

```console
$ nix run .#nlp-diff     # 宣言と導入済みを比較 (副作用なし)
$ nix run .#nlp-adopt    # 明示導入済みを宣言の雛形として出す (副作用なし)
$ nix run .#nlp-apply    # 不足分だけ導入する
$ nix run .#nlp-update   # pm を更新してから不足分を補う
$ nix run .#nlp-status   # 検出した pm と宣言の件数
```

`nlp-` は消費側がもともと持っている `apps.diff` を潰さないための接頭辞。
空にしたいときは `nlp.appPrefix = ""`。`nix run .` を diff にしたいときは
`nlp.defaultApp = "diff"`。

宣言は部分指定でよい。書いた pm だけを使い、書かなかった pm は
空リスト（`diff` は「宣言なし」と表示）になる。

`nlp.enable = false` にすると `packages.nlp` と apps を一切出さない。
モジュールを `imports` に置いただけの変化で足したくないときの逃げ道。
（home-manager 側は逆に `enable` の既定が `false`。）

### home-manager

home-manager には `flakeModules.home-manager` を置く（`flakeModules.homeManager` と
`flakeModules.home-manager-nlp` は同じファイルの別名）。出るのは
`home.packages` に載る nlp だけで、apps は出さない。

```nix
{
  imports = [ inputs.linux-pkgmanager.nix.flakeModules.home-manager ];

  programs.nlp = {
    enable = true;
    declared.pacman = ./packages/pacman.nix;
  };
}
```

```console
$ home-manager switch   # nlp が PATH に入るだけ
$ nlp diff              # 宣言と導入済みを比較 (副作用なし)
$ nlp adopt             # 明示導入済みを宣言の雛形として出す (副作用なし)
$ nlp apply             # 不足分だけ導入する (switch のあと手動)
```

`programs.nlp` には `declared` の代わりに `packages` / `commonPackages` /
`managers` も書ける。解決の規則は flake-parts 版と同じ
（[宣言の書き方](#宣言の書き方)）。`programs.nlp.package` を指定すれば、
宣言はそのままに実行体だけを差し替えられる。

`enable` の既定は `false`。`true` にすると `home.packages` に入る
（Linux のときだけ。darwin には載らない）。`false` のままだと何も起きない。

`apply` / `update` は `sudo` が要るので **activation では走らせない。**
パスワード入力を activation に挟むと、非対話の `switch` や CI で必ず詰まる。
運用は「switch のあとに `nlp apply`」で固定する。

`flakeModules.default` と `flakeModules.home-manager` はどちらも `imports` に置く
ものだが、同じ config に 2 つ入れてはならない。どちらか 1 つを選ぶ。

`homeManagerModules.default` も同じモジュールを返す。ただし Nix は
`homeManagerModules` を既知の flake output 名として知らないので、
`nix flake check` が `warning: unknown flake output 'homeManagerModules'` を出す。
警告を出したくないなら `flakeModules.home-manager` を使う。

### flake-parts を使わない場合

`lib.mkApps` が実行体と app 一式を返す。宣言の検査は同じものを通る。

```nix
outputs =
  { nixpkgs, linux-pkgmanager.nix, ... }:
  let
    systems = [ "x86_64-linux" ];
    each = system:
      linux-pkgmanager.nix.lib.mkApps {
        pkgs = nixpkgs.legacyPackages.${system};
        declared.pacman = [
          "man-db"
          "bash-completion"
        ];
      };
  in
  {
    packages = nixpkgs.lib.genAttrs systems (system: {
      nlp = (each system).package;
    });
    apps = nixpkgs.lib.genAttrs systems (system: (each system).apps);
  };
```

実行体だけ欲しいときは、これまで通り `lib.mkNlp` が derivation を返す。

宣言に**存在しない名前**を1つ混ぜると、pm が異常終了して照合結果が空に
なる。`nlp` は stderr の `E:` / `error:` を検出して終了コード 2 で止まる
ので、黙って「不足なし」には見えない。同じ理由で、未知の pm 名と
リストでない宣言も評価時に落とす。

### なぜ input 属性ではなく option なのか

flake の input に置けるのは `url` / `follows` / `inputs` だけ。`declared` を
input に書くと弾かれる。

```console
$ nix eval .
error: flake input attribute 'declared' is a thunk while a string,
Boolean, or integer is expected
```

宣言は「値」なので input には載せず、flake の option（または `lib.mkApps` の引数）
として渡す。

公開しているもの:

| output                                      | 内容                                                                                       |
| ------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `flakeModules.default` / `flakeModules.nlp` | flake-parts モジュール。`nlp` の宣言から `packages.nlp` と `apps.nlp-*` を出します         |
| `flakeModules.home-manager`                 | home-manager モジュール。`programs.nlp` の宣言から `home.packages` へ nlp を出します       |
| `flakeModules.homeManager`                  | `flakeModules.home-manager` と同じファイル                                                 |
| `flakeModules.home-manager-nlp`             | `flakeModules.home-manager` と同じファイル                                                 |
| `homeManagerModules.default` / `.nlp`       | home-manager 用モジュールの別名。`nix flake check` が unknown flake output と警告します    |
| `templates.default` / `templates.minimal`   | `nix flake init -t github:nazozokc/linux-pkgmanager.nix#minimal` の元になる最小構成        |
| `lib.mkApps`                                | 宣言から `{ package, apps }` を返す関数                                                    |
| `lib.mkNlp`                                 | 宣言を受け取って nlp の derivation を返す関数                                              |
| `lib.pms`                                   | 対応している pm 名の一覧                                                                   |
| `lib.backends`                              | pm ごとのコマンド定義（純データ）                                                          |
| `lib.validate`                              | 宣言を検査して、通らなければ throw する関数                                                |
| `lib.check`                                 | 検査だけする。問題を文字列のリストで返す                                                   |
| `packages.<system>.nlp`                     | その flake の宣言で組んだ nlp                                                              |
| `apps.<system>.*`                           | `diff` / `adopt` / `apply` / `update` / `status`（`defaultApp` を設定すれば `default` も） |
| `checks.<system>.*`                         | `eval` / `shellcheck` / `fake-path` / `consumer` / `treefmt`                               |
| `githubActions.matrix`                      | CI 専用。`nix flake check` が unknown flake output と警告します                            |

`nixosModules` には出してない。Nix の flake schema は `nixosModules.<system>.<name>`
を期待するので、このリポジトリの `{ default; nlp; }` という形は解釈されず捨てられる。
NixOS で使う場合も home-manager 経由なので、`flakeModules.home-manager` を使う。

このリポジトリ自身の `apps` は接頭辞なし（`nix run .#diff`）。
消費側のモジュールは既定で `nlp-diff` のように接頭辞を付ける。

## 削除をしない理由

apt / dnf / yum / zypper の `autoremove` は、このツールが把握していない
`.packages` まで巻き込んで消す。宣言から外したパッケージが
`autoremove` の対象になると、意図していないものが消える。

だから **削除系のコマンドは一切持たない。**
宣言から外したパッケージは `unmanaged` に現れるので、放置するかどうかは
自分で決める。

## 開発

```console
$ nix flake check --all-systems   # 5 pm すべての経路を検証
$ nix fmt                          # nixfmt / shfmt / statix / deadnix / prettier
```

5 層で守る。

| check               | 何を見る                                                                   |
| ------------------- | -------------------------------------------------------------------------- |
| `checks.eval`       | 宣言の検査が実際に落ちるかを、受理・却下ケースで固定する                   |
| `checks.shellcheck` | 連結前の `nix/lib/script/*.sh` を lint する                                |
| `checks.fake-path`  | 5 pm すべてのコマンド生成と差分計算を、PATH 差し替えで実測する             |
| `checks.consumer`   | 公開 API を入力に載せた消費側 flake を実際に評価して、出た apps を起動する |
| `checks.treefmt`    | `nix fmt` の整形チェック（treefmt-nix が出す）                             |

`checks.fake-path` は `tests/fake-path/` のスタブで pm コマンドを差し替える。
ホストに 1 つしかない pm でも、apt / dnf / zypper / yum の経路まで通せる
(パッケージの実際の導入・更新は行わない。`sudo` も呼ばない)。

さらに検査を意図的に飛ばした nlp も作らせ、`$(touch PWNED)` のような宣言から
コマンドが実行されないことを測っている。宣言検査が 1 枚落としても
実行されないことを固定するため。

`checks.consumer` は `tests/consumer/module.nix` を入力に載せた消費側 flake
として評価する。`lib.evalModules` で再現すると `perSystem` の型と
`apps` / `packages` の転置を自分で作ることになり、公開 API の経路とは
別のものを作ってしまう。生成された `nlp-diff` の実物はビルドして起動し、
pm 未検出で止まることまで見る。

設計の詳細は [DESIGN.md](./DESIGN.md) を参照。

### CI

`.github/workflows/ci.yaml` は matrix を flake から組み立てる。
`githubActions` output が唯一の出典で、workflow には check 名を書かない。

```console
$ nix eval --json .#githubActions.matrix.include | jq '.[0]'
{
  "attr": "checks.aarch64-linux.\"consumer\"",
  "name": "consumer",
  "os": [
    "ubuntu-24.04-arm"
  ],
  "system": "aarch64-linux"
}
```

- `nix-github-actions` の `mkGithubMatrix` が check 名と runner を pairing する
- `attrPrefix = "checks"` なので `checks.<system>.<name>` をそのまま使う
- 対象は `x86_64-linux` と `aarch64-linux`
- `treefmt` も含め、matrix は check × system の組で埋まる（5 × 2 = 10）

`attr` には `-` を含む名前が引用符つきで入る（`fake-path` → `"fake-path"`）。
workflow では env 経由で渡して、shell の引用規則に依存させないようにしている。

check を 1 つ足したときは matrix が自動で増える。workflow を編集しなくてよい。

`.github/dependabot.yml` で nixpkgs は日次、GitHub Actions は週次で更新する。
nixpkgs を上げた途端に全部赤にならないよう、依存ごとにグループを割って
1 PR にまとめる。
