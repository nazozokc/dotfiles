---
name: git-commit
description: Gitコミット・プッシュ・PR作成時のルール
---

# Git 運用ガイドライン

## いつ使うか
- ファイルをコミットするとき
- リモートにプッシュするとき

## 基本ルール
- **日本語コミット禁止**: 英語のみ使用
- **1コミット = 1論理変更**: 複数の異なる変更を混在させない
- **意味のある粒度**: 大きすぎる変更は分割する
- **必ずブランチはAI-agent**: かならずAI-agentにコミットとプッシュしてください
- **コミットをする前に必ずコードレビュー**: コードレビューは../code-review/SKILL.mdを参照

## ブランチ戦略
- **作業ブランチ**: 常に `AI-agent` ブランチを使用
- **PR target**: `AI-agent` → `main` へのマージ
- **ブランチ作成**: `AI-agent` がなければ作成から開始

## コミットメッセージ形式

```
<type>: <summary>
```

### type 一覧
| type | 用途 |
|------|------|
| `feat` | 新機能追加 |
| `fix` | バグ修正 |
| `refactor` | リファクタリング |
| `docs` | ドキュメント変更 |
| `chore` | ビルド・設定変更 |
| `style` | フォーマット・スタイル変更 |

### 例
```
feat: add neovim telescope config
fix: resolve fish greeting display bug
chore: update flake.lock
refactor: simplify home-manager modules
```

## 注意点
- コミット前に `git status` で変更内容を確認
- コミット後に自動生成されたファイル（含めて良いか判断）は別途コミット
- PR作成前に `--force` 系のコマンドは使用禁止
