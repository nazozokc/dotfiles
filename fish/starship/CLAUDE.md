# starship

このディレクトリはstarshipプロンプトの設定を管理しています。

## 構成

`starship.toml` は3つのセクションに分かれています:

- **left module**: プロンプト左側に表示されるモジュール
  - `directory`: 現在ディレクトリ ( Cyan: #80EBDF )
  - `git_branch`: Gitブランチ ( Blue: #769ff0 )
  - `git_status`: Gitステータス ( Blue: #769ff0 )
  - `direnv`: Direnv環境 ( Cyan: #89dceb )
  - `python`: Python仮想環境 ( Yellow: #ffcb6b )
  - `aws`: AWSプロファイル ( Yellow: #ffcb6b )
  - `fill`: 残りを埋めるフィルモジュール
  - `cmd_duration`: コマンド実行時間
  - `time`: 時刻

- **right module**: プロンプト右側に表示されるモジュール (コメントアウト中)
  - `cmd_duration`, `time`

- **prompt module**: プロンプト記号
  - `character`: プロンプト記号、vimモード表示

## 設定特徴

- **フォーマット**: Powerlineスタイルのセパレータ（`\`で継続）
- **色 スキーム**:
  - Blue (#769ff0): Git関連
  - Cyan (#80EBDF, #89dceb): Directory, direnv
  - Yellow (#ffcb6b): Python, AWS
  - Gray (#a0a9cb, #e0af68): Time, cmd_duration
- **vimモード**: 標準は `>`, コマンドモードで `[V]` (緑)

## 関連

- 親リポジトリ: [nazozokc/dotfiles](https://github.com/nazozokc/dotfiles)
- Nix構成: `nix/AGENTS.md`
