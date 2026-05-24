# wezterm

weztermの設定ファイル

## 構成

| ファイル                       | 説明                                    |
| ------------------------------ | --------------------------------------- |
| `wezterm.lua`                  | エントリーポイント                      |
| `config/appearance.lua`        | 外観（カラースキーム、透明度など）      |
| `config/font.lua`              | フォント設定                            |
| `config/keys.lua`              | キーバインド + コマンドパレットdescription |
| `config/leader.lua`            | Leader key (Ctrl+Shift+Space)、Quick Select、Workspace |
| `config/launch_menu.lua`       | 起動メニュー（コマンドパレットから）    |
| `config/hyperlinks.lua`        | ハイパーリンクルール（URL、ファイルパス） |
| `config/mouse.lua`             | マウス設定                              |
| `config/tab.lua`               | タブ設定                                |
| `config/performance.lua`       | パフォーマンス設定                      |
| `config/session.lua`           | ワークスペースの簡易保存・復元          |
| `utils/platform.lua`           | プラットフォーム固有設定                |

## キーバインディング

Ctrl+Shiftをプレフィックスとして使用。tmuxやScreenのような独自プレフィックスは使わず、Ctrl+単一キーのバインドも無効化している。

Leader key として `Ctrl+Shift+Space` を設定。Leader は追加操作用で、既存の Ctrl+Shift バインドは維持。

### タブ

| キー                  | アクション   |
| --------------------- | ------------ |
| `Ctrl+Shift+T`        | 新規タブ     |
| `Ctrl+Shift+W`        | タブを閉じる |
| `Ctrl+Shift+PageUp`   | 前のタブ     |
| `Ctrl+Shift+PageDown` | 次のタブ     |

### ペイン

#### 操作

| キー           | アクション     |
| -------------- | -------------- |
| `Ctrl+Shift+E` | 横分割         |
| `Ctrl+Shift+D` | 縦分割         |
| `Ctrl+Shift+Q` | ペインを閉じる |
| `Ctrl+Shift+Z` | ペインズーム   |

#### フォーカス（Vim風）

| キー           | アクション |
| -------------- | ---------- |
| `Ctrl+Shift+H` | 左ペイン   |
| `Ctrl+Shift+J` | 下ペイン   |
| `Ctrl+Shift+K` | 上ペイン   |
| `Ctrl+Shift+L` | 右ペイン   |

#### リサイズ

| キー               | アクション   |
| ------------------ | ------------ |
| `Ctrl+Shift+Alt+H` | 左にリサイズ |
| `Ctrl+Shift+Alt+J` | 下にリサイズ |
| `Ctrl+Shift+Alt+K` | 上にリサイズ |
| `Ctrl+Shift+Alt+L` | 右にリサイズ |

### ウィンドウ

| キー               | アクション     |
| ------------------ | -------------- |
| `Ctrl+Shift+Enter` | フルスクリーン |
| `Alt+Enter`        | フルスクリーン |
| `Ctrl+Shift+N`     | 新規ウィンドウ |

### クリップボード

| キー           | アクション |
| -------------- | ---------- |
| `Ctrl+Shift+C` | コピー     |
| `Ctrl+Shift+V` | ペースト   |

### Leader key（Ctrl+Shift+Space）

| キー            | アクション               |
| --------------- | ------------------------ |
| `Leader+Space`  | Quick Select（画面内テキスト選択） |
| `Leader+W`      | ワークスペース切り替え   |
| `Leader+1..9`   | ワークスペース直接切り替え |

### その他

| キー           | アクション                        |
| -------------- | --------------------------------- |
| `Ctrl+Shift+R` | 設定リロード                      |
| `Ctrl+Shift+P` | コマンドパレット                  |
| `Ctrl+Shift+F` | 透明度トグル（デフォルト ↔ 透過） |

## 機能詳細

### Quick Select
`Leader+Space` で起動。画面内の以下のテキストをキーボードで選択・コピーできる：
- HTTP/HTTPS URLs
- ファイルパス（`file.rs:42` 形式）
- Git SHA / hex文字列
- IPv4アドレス

### ワークスペース
`Leader+W` でワークスペース切り替え。`Leader+1..9` で直接切り替えも可能。
ワークスペースは終了時に保存され、次回起動時に復元される（簡易セッション永続化）。

### 起動メニュー
`Ctrl+Shift+P` → "Launch" で使用可能。Fish、Zsh、Bash、Dotfilesディレクトリ、Htopなどをクイック起動。

### ハイパーリンク
`Ctrl+Shift+クリック` で以下のテキストを認識・オープン：
- URL（標準）
- ファイルパス:行:桁 → `$EDITOR +line file` 形式で開く

### プラットフォーム別透過度
- Linux/Wayland: 0.95（軽度透過）
- Linux/X11: 0.90
- macOS: 0.90
- Windows: 0.90

### セッション
現在のワークスペースを `wezterm.state` に保存。次回起動時に自動復元。
対応範囲はワークスペースのみ（ペインレイアウトの復元は対象外）。

---

- [公式ドキュメント](https://wezterm.org/)
- [設定リファレンス](https://wezterm.org/config/lua.html)
