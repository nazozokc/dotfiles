---
name: create-pr
description: PRを作成する際のテンプレート、注意点、手順
---

# PR 作成ガイドライン

## いつ使うか
- `gh pr create` でPRを作成するとき
- PRのタイトル・本文を書くとき

## 基本ルール
- **ブランチは必ず AI-agent**: `AI-agent` → `main` へのPR
- **日本語禁止**: タイトル・本文ともに英語のみ
- **1PR = 1目的**: 複数の無関係な変更を混ぜない
- **コミット済みであること**: PR作成前に全変更がコミット・プッシュ済みであることを確認
- **コードレビュー済みであること**: ../code-review/SKILL.md に従ってレビュー済みであること

## PRタイトル形式
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
```

## PR本文テンプレート
```markdown
## Summary

<!-- What this PR does -->

## Changes

- 

## Notes

<!-- Anything reviewers should know (optional) -->
```

## 作成コマンド
```bash
# ドラフトで確認しながら作成
gh pr create \
  --base main \
  --head AI-agent \
  --title "<type>: <summary>" \
  --body "$(cat <<'EOF'
## Summary



## Changes

- 

## Notes

EOF
)"
```

## 注意点
- PR作成前に `git log --oneline origin/main..HEAD` で差分コミットを確認
- `--force-push` 系は使用禁止
- 既にオープン中のPRがないか `gh pr list` で確認してから作成
