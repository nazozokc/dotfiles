{ pkgs, username, ... }:

{
  ########################################
  # nix-darwin 基本設定
  ########################################
  system.stateVersion = 4;
  system.primaryUser = "nazozokc"; # darwin-rebuild を実行するユーザー名

  ########################################
  # Nix 自体の設定
  ########################################
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [ username ];
    };
  };

  ########################################
  # ユーザー定義
  ########################################
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  ########################################
  # シェル
  ########################################
  programs.fish.enable = true;

  ########################################
  # macOS セキュリティ / 権限
  ########################################
  security.pam.services.sudo_local.touchIdAuth = true;

  ########################################
  # macOS システム設定（最低限）
  ########################################
  system.defaults = {
    dock.autohide = true;
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
    };
  };

  ########################################
  # 環境変数
  ########################################
  environment.systemPackages = with pkgs; [
    git
  ];

  ########################################
  # フォント（必要なら）
  ########################################
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];
}
