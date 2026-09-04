{ pkgs, username, ... }:

{
  home.username = username;

  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Keep in sync with your nixpkgs channel version
  home.stateVersion = "26.11";
  # WARNING: home.stateVersion は「一度設定したら絶対に変更しない」ことを原則とします。
  # 更新は以下の条件を全て満たした場合のみ許可されます:
  # 1. 変更理由をPR本文に明記
  # 2. nix flake check 通過
  # 3. nix run .#build 通過
  # 4. dotfilesリンク・主要CLI起動確認結果をPRに記録
  # stateVersion の更新はデータの破損や設定の不整合を引き起こす可能性があります。

  home.enableNixpkgsReleaseCheck = false;

  xdg.enable = true;

  programs.home-manager.enable = true;

  home.sessionVariables = {
    DOTFILES_USERNAME = username;
  };
}
