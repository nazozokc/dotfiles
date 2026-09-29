# Neovim Configuration

このディレクトリは [nazozokc/dotfiles](https://github.com/nazozokc/dotfiles) の Neovim 設定です。  
lazy.nvim をプラグインマネージャーとして使用しています。

---

## 特徴

- **軽量・高速・充実**: lazy.nvim による遅延読み込み
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
├── lazy-lock.json        # プラグインバージョンロック
├── lua/
│   ├── plugins.lua       # プラグイン定義（空）
│   ├── vim-options.lua   # 基本設定
│   └── plugins/          # プラグイン設定（各ファイル）
└── template/             # sonictemplate のテンプレート
    ├── gitignore/
    ├── javascript/
    ├── lua/
    ├── markdown/
    └── typescript/
```

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

| プラグイン | 用途           |
| ---------- | -------------- |
| nvim-dap   | デバッガー     |
| neotest    | テストランナー |

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

- **tsgo** - TypeScript / JavaScript / JSX / TSX（TypeScript 7 内蔵の LSP / `tsc --lsp --stdio`）
- **clangd** - C / C++（`fallbackFlags: -std=c++20` で compile_commands.json 無しでも動作）
- **sqls** - SQL
- **tailwindcss** - Tailwind CSS（`tailwind.config.*` 検出時のみ起動）
- **html** - HTML / JSX / TSX（JSX/TSX では tsgo と診断が重複しないよう html 限定）
- **lua_ls** - Lua
- **solargraph** - Ruby
- **nixd** - Nix
- **efm** - 汎用フォーマッター

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
