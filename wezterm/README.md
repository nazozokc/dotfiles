# wezterm

weztermの設定ファイル

## 構成

| ファイル | 説明 |
|---------|------|
| `wezterm.lua` | エントリーポイント |
| `config/appearance.lua` | 外観（カラースキーム、透明度など） |
| `config/font.lua` | フォント設定 |
| `config/keys.lua` | キーバインド |
| `config/mouse.lua` | マウス設定 |
| `config/tab.lua` | タブ設定 |
| `config/performance.lua` | パフォーマンス設定 |
| `utils/platform.lua` | プラットフォーム固有設定 |

## キーバインディング

Ctrl+Shiftをプレフィックスとして使用。tmuxやScreenのような独自プレフィックスは使わず、Ctrl+単一キーのバインドも無効化している。

### タブ

| キー | アクション |
|------|-----------|
| `Ctrl+Shift+T` | 新規タブ |
| `Ctrl+Shift+W` | タブを閉じる |
| `Ctrl+Shift+PageUp` | 前のタブ |
| `Ctrl+Shift+PageDown` | 次のタブ |

### ペイン

#### 操作

| キー | アクション |
|------|-----------|
| `Ctrl+Shift+E` | 横分割 |
| `Ctrl+Shift+D` | 縦分割 |
| `Ctrl+Shift+Q` | ペインを閉じる |
| `Ctrl+Shift+Z` | ペインズーム |

#### フォーカス（Vim風）

| キー | アクション |
|------|-----------|
| `Ctrl+Shift+H` | 左ペイン |
| `Ctrl+Shift+J` | 下ペイン |
| `Ctrl+Shift+K` | 上ペイン |
| `Ctrl+Shift+L` | 右ペイン |

#### リサイズ

| キー | アクション |
|------|-----------|
| `Ctrl+Shift+Alt+H` | 左にリサイズ |
| `Ctrl+Shift+Alt+J` | 下にリサイズ |
| `Ctrl+Shift+Alt+K` | 上にリサイズ |
| `Ctrl+Shift+Alt+L` | 右にリサイズ |

### ウィンドウ

| キー | アクション |
|------|-----------|
| `Ctrl+Shift+Enter` | フルスクリーン |
| `Alt+Enter` | フルスクリーン |
| `Ctrl+Shift+N` | 新規ウィンドウ |

### クリップボード

| キー | アクション |
|------|-----------|
| `Ctrl+Shift+C` | コピー |
| `Ctrl+Shift+V` | ペースト |

### その他

| キー | アクション |
|------|-----------|
| `Ctrl+Shift+R` | 設定リロード |
| `Ctrl+Shift+P` | コマンドパレット |
| `Ctrl+Shift+F` | 透明度トグル（90% ↔ 75%） |

- [公式ドキュメント](https://wezterm.org/)
- [設定リファレンス](https://wezterm.org/config/lua.html)
