---
name: nix
description: Nix設定を管理するときのガイドライン
---

# Nix 運用ガイドライン

## flake.lock の更新手順
```bash
# 1. 更新を実行（このコマンドが flake に定義されている場合のみ実行）
nix run .#update

# 2. 変更をステージング
git add .

# 3. コミット（日本語禁止）
git commit -m "update flake.lock:YYYYMMDD"

# 4. リモートにプッシュ
git push

## 代替手順（nix run が定義されていない場合）
```bash
nix flake update
```

## ビルド確認
```bash
# nixpkgs overlay など
nix build .#<target>

# home-manager の場合（hostは設定名に置き換え）
home-manager switch --flake .#<host>
```

## コード変更時の心得
- **設計は崩さない**: 既存のnixの構造を尊重する
- **自己レビュー**: 自分のコードを過信しない、徹底的に確認する
- **シンプルさ**: 複雑化せず、読みやすいコードを優先
- **情報源**: 困ったら https://nix.dev/ を参照

## 注意点
- nixは宣言的な構成管理。副作用のある操作は慎重に
- パッチやオーバーレイは最小限に

## ルール違反・判断できない場合
- 禁止事項に該当する操作を求められた場合は、実行せずユーザーに理由を説明して確認を取る
- スキルの手順に従えない状況（コマンドが存在しないなど）は、スキップせず必ずユーザーに報告する
