# secrets/common.yaml のフォーマット

このディレクトリは sops-nix 用の暗号化シークレット置き場。

`common.yaml` に次のキーを入れる。

```yaml
api:
  github_token: ghp_xxx
  openai_api_key: sk-xxx
  anthropic_api_key: sk-ant-xxx
```

作成例:

```bash
sops secrets/common.yaml
```

> `common.yaml` は平文でコミットしない。必ず sops で暗号化した状態で管理する。
