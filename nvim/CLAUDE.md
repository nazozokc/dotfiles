# Neovim Configuration

このディレクトリは [nazozokc/dotfiles](https://github.com/nazozokc/dotfiles) の Neovim 設定です。  
プラグインの宣言は Lua で、**実体とバージョンは Nix が管理**しています。  
lazy.nvim は plugin manager としてのみ使い、install 先を nix store へ差し替えます。

---

## 特徴

- **軽量・高速・充実**: lazy.nvim による遅延読み込み
- **再現性**: プラグイン実体・バージョンが nix store に固定される
- **LSP 完備**: TypeScript, Lua, Ruby, Nix, HTML など標準サポート
- **モダンUI**: カスタムダッシュボード、ステータスライン、ファジーファインダー
- **Treesitter**: シンタックスハイライト・インデント
- **DAP統合**: デバッグ機能
- **テンプレート**: 各種ファイルタイプ用テンプレート

---

## ディレクトリ構成

```
nvim/
├── init.lua              # エントリーポイント・キーマップ
├── lazy-lock.json        # 種 (seed)。実体は farm (nix store) から解決される
├── lua/
│   ├── plugins.lua       # プラグイン定義（空）
│   ├── vim-options.lua   # 基本設定
│   └── plugins/          # プラグイン設定（各ファイル）
├── nvim-plug-manage/     # プラグイン実体のバージョン管理 (flake.nix / flake.lock / sync-inputs.lua)
└── template/             # sonictemplate のテンプレート
    ├── gitignore/
    ├── javascript/
    ├── lua/
    ├── markdown/
    └── typescript/
```

---

## プラグインの仕組み

```
nvim/lua/plugins/*.lua             宣言 (lazy-loading / dependencies / opts)
nvim/nvim-plug-manage/sync-inputs.lua  宣言から flake.nix の inputs へ自動同期 (nvim-install が呼ぶ)
nvim/nvim-plug-manage/flake.nix    プラグインの input 一覧 (入力名 = lazy の plugin.name)
nvim/nvim-plug-manage/flake.lock   rev / narHash の正本
nix/modules/home/programs/nvim/plugins/default.nix  lock から farm (symlink 一覧) を組む
```

- `LAZY_NIX_PLUGINS` が farm の path。`nix run .#switch` で Neovim が使う
  wrapper に `export` される (`nix/modules/home/programs/nvim/default.nix` の
  `extraWrapperArgs` の `--set`)。
- `init.lua` は `os.getenv("LAZY_NIX_PLUGINS")` を見て `lazy.setup` の
  `dev.path` / `dev.fallback` を組み立てる。
  - 設定あり → プラグインは全部 farm から解決 (`_.is_local`)
  - 未設定 → 従来の git clone bootstrap にフォールバック
- プラグインを追加する手順は `nix/AGENTS.md` の「Neovim プラグイン管理」を参照。

### 更新

```bash
# lua/plugins の宣言を flake.nix の inputs へ自動追加して lock
nix run .#nvim-install

# 全プラグインを最新へ bump
nix run .#nvim-update

# 反映
nix run .#switch
```

- `nvim-install` は `sync-inputs.lua` (`nvim -l`) で `lua/plugins/*.lua` を読み、
  flake.nix に無い plugin.name だけを追加してから `nix flake lock` を回す。
  既存 input の url は触らない (fork / codeberg 等の URL 例外を保持)。
  Lua から消えた input は orphan として報告するだけで削除しない。
- `nvim-update` は `nix flake update` で全 input を bump する。
  rev と narHash が同時に動くのでハッシュを手で書かない。
- 例外の3件 (`lazy.nvim` / `denops.vim` / `telescope-fzf-native.nvim`) だけは
  root の nixpkgs input 由来なので `nix run .#update` で動く。

### 注意事項

- `lazy-lock.json` には触らない。farm が全プラグインを持つので lazy は git clone しない。
- ただし lazy.nvim が書き込む実体は **state 配下**
  (`~/.local/state/nvim/lazy/lazy-lock.json`) にある。`~/.config/nvim/lazy-lock.json`
  は nix store への symlink (read-only) なので直接書き込めない。
- `build = "..."` ステップは原則不要。`:TSUpdate` のように外部 fetch を
  行うステップは Nix (read-only store) では機能しない。
- farm は `pkgs.vimUtils.buildVimPlugin` を使わない (`neovimRequireCheckHook` が
  素のソースでは依存を require できないため)。ビルド時に焼くのは `doc/tags` だけ。

---

## 主要プラグイン

### LSP / 補完

| プラグイン      | 用途                       |
| --------------- | -------------------------- |
| nvim-lspconfig  | LSP設定                    |
| nvim-cmp        | 補完エンジン               |
| LuaSnip         | スニペット                 |
| Lspsaga         | LSP UI拡張                 |
| actions-preview | コードアクションプレビュー |

### Fuzzy Finder / ナビゲーション

| プラグイン     | 用途                        |
| -------------- | --------------------------- |
| snacks.nvim    | Picker, Dashboard, Zen mode |
| telescope.nvim | ファジーファインダー        |
| oil.nvim       | ファイルエクスプローラー    |
| dropbar.nvim   | Winbar / パンくずリスト     |
| flash.nvim     | ジャンプ                    |

### UI / 見た目

| プラグイン     | 用途             |
| -------------- | ---------------- |
| kanagawa.nvim  | カラースキーム   |
| lualine.nvim   | ステータスライン |
| noice.nvim     | コマンドラインUI |
| nvim-notify    | 通知             |
| nvim-scrollbar | スクロールバー   |

### Git

| プラグイン    | 用途         |
| ------------- | ------------ |
| gitsigns.nvim | Git sign     |
| lazygit.nvim  | LazyGit 統合 |
| octo.nvim     | GitHub 統合  |

### エディタ機能

| プラグイン      | 用途                   |
| --------------- | ---------------------- |
| nvim-treesitter | シンタックスハイライト |
| nvim-autopairs  | 括弧補完               |
| Comment.nvim    | コメントアウト         |
| substitute.nvim | 置換                   |
| which-key.nvim  | キーマップヘルプ       |
| toggleterm.nvim | ターミナル             |

### デバッグ / テスト

| プラグイン  | 用途            |
| ----------- | --------------- |
| nvim-dap    | デバッガー      |
| neotest     | テストランナー  |
| crates.nvim | Cargo.toml 管理 |

---

## キーマップ

### Leader キー

`<Leader>` = `Space`

### 基本

| キー               | 動作               |
| ------------------ | ------------------ |
| `<Leader><Leader>` | ファイル検索       |
| `<Leader>g`        | Grep               |
| `<Leader>b`        | バッファ一覧       |
| `<Leader>r`        | 最近使ったファイル |
| `<Leader>h`        | 検索ハイライト解除 |
| `<Leader>z`        | Zen mode           |

### LSP

| キー         | 動作                       |
| ------------ | -------------------------- |
| `K`          | ホバー                     |
| `gd`         | 定義へ移動                 |
| `ga`         | コードアクション (Lspsaga) |
| `<Leader>ca` | コードアクション (preview) |
| `<Leader>gd` | 定義へ移動                 |
| `<Leader>gr` | 参照一覧                   |

### UI

| キー         | 動作                   |
| ------------ | ---------------------- |
| `<Leader>t`  | ターミナル             |
| `<Leader>c`  | dotfiles を Oil で開く |
| `<Leader>e`  | Trouble (診断一覧)     |
| `<Leader>so` | SymbolsOutline         |
| `<Leader>;`  | Dropbar pick           |
| `<F2>`       | Twilight               |

### DAP

| キー         | 動作                 |
| ------------ | -------------------- |
| `<F5>`       | 実行 / 継続          |
| `<F10>`      | ステップオーバー     |
| `<F11>`      | ステップイン         |
| `<F12>`      | ステップアウト       |
| `<Leader>db` | ブレークポイント切替 |

### ウィンドウ移動

| キー    | 動作     |
| ------- | -------- |
| `<C-h>` | 左へ移動 |
| `<C-j>` | 下へ移動 |
| `<C-k>` | 上へ移動 |
| `<C-l>` | 右へ移動 |

---

## LSP サポート

以下の言語サーバーを設定済み：

- **tsc** - TypeScript / JavaScript / JSX / TSX（TypeScript 7 内蔵の LSP / `tsc --lsp --stdio`）
- **clangd** - C / C++（`fallbackFlags: -std=c++20` で compile_commands.json 無しでも動作）
- **sqls** - SQL
- **tailwindcss** - Tailwind CSS（`tailwind.config.*` 検出時のみ起動）
- **html** - HTML / JSX / TSX（JSX/TSX では tsgo と診断が重複しないよう html 限定）
- **lua_ls** - Lua
- **solargraph** - Ruby
- **rust-analyzer** - Rust（rustaceanvim が設定。`nix run .#switch` 反映後に有効）
- **nixd** - Nix
- **efm** - 汎用フォーマッター

### Rust（rustaceanvim）

rust-tools.nvim（archived）の代わりに [rustaceanvim](https://github.com/mrcjkb/rustaceanvim) を使う。
filetype plugin 形式なので `lazy = false`。

- **rust-analyzer の取得元**: home-manager の PATH には rustup shim があるため、
  wrapper 環境変数 `RUST_ANALYZER`（nix store の実体）を `server.cmd` に渡す。
  shim 経由だと `rust-analyzer` への再帰で落ちる
- **設定**: `cargo.features = "all"`、`procMacro.enable = true`、
  `checkOnSave = true`（`check.command = "clippy"`）
- **rust バッファのキーマップ**:

| キー         | 動作                           |
| ------------ | ------------------------------ |
| `K`          | Hover actions                  |
| `<Leader>rr` | Runnables                      |
| `<Leader>rd` | Debuggables（DAP で実行）      |
| `<Leader>rm` | Expand Macro                   |
| `<Leader>th` | Inlay Hints トグル（自動有効） |

- **デバッグ**: codelldb（`vscode-extensions.vadimcn.vscode-lldb`）。
  wrapper 環境変数 `CODELLDB` / `LIBLLDB` から `rustaceanvim.dap` が
  adapter を組み、Attach 時に `dap.configurations.rust` を自動登録する
- **テスト**: neotest（`hoxbro/neotest-rust`）が PATH 上の `cargo-nextest` を使う
- **Cargo.toml**: crates.nvim（crates.io のバージョン補完）。

### SQL の接続設定（.sqls/config.yml）

sqls の DB 接続はプロジェクトルートの `.sqls/config.yml` で行う：

```yaml
connections:
  - alias: local
    driver: sqlite3
    dataSourceName: ./db.sqlite3
```

プロジェクトごとに配置すれば、sqls 起動時に自動で読み込まれる。

---

## テンプレート

[mattn/vim-sonictemplate](https://github.com/mattn/vim-sonictemplate) を使う。
設定は `lua/plugins/template.lua`、実体は `template/` に置く。

### 使い方

空バッファ（新規ファイル）を開いてコマンドラインで `tmp` → `:Template`。
候補が補完されるので、名前を選ぶか直接入力する。

```vim
:Template basic     " template/javascript/base-basic.js を適用
:Template           " 候補を補完で表示
```

### ファイル命名規則

`template/< Vim の filetype >/<kind>-<name>.<ext>` の3要素构成。
ディレクトリ名は拡張子ではなく **filetype**（`javascript` / `typescript` / `markdown`）。

| kind   | 用途                     |
| ------ | ------------------------ |
| `base` | バッファが空のときに使う |
| `snip` | バッファに文字があるとき |
| `file` | バッファ名から絞り込む   |

### 使えるキーワード

| キーワード                        | 展開結果                                   |
| --------------------------------- | ------------------------------------------ |
| `{{_name_}}`                      | ファイル名（識別子に適した形）             |
| `{{_expr_:expand('%:t:r')}}`      | ファイル名（拡張子なし・原形）             |
| `{{_input_:author}}`              | `git config user.name` fallback `nazozokc` |
| `{{_expr_:strftime('%Y-%m-%d')}}` | 展開日                                     |
| `{{_cursor_}}`                    | カーソル位置                               |

> `{{_name_}}` は `-` や `.` を `_` に置換する。コメントヘッダや
> CLI 名など「表示用」には `{{_expr_:expand('%:t:r')}}` を使う。

---

## 設定値

- インデント: 2スペース
- 行番号: 表示 + 相対行番号
- Insertモード中は相対行番号を無効化
- Swapファイル: 無効

---

## 使用方法

この設定は dotfiles リポジトリの一部です。

```bash
cd ~/ghq/github.com/nazozokc/dotfiles
nix run .#switch
```

Home Manager により `~/.config/nvim` にシンボリックリンクが作成されます。
