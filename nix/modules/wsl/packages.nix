# nix/modules/wsl/packages.nix
# WSL 固有のパッケージ
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # クリップボード
    xclip
    wl-clipboard

    # アーカイブ
    unzip
    zip

    # ネットワーク
    nmap

    # フォント
    fontconfig

    # セキュリティ/認証
    gnupg
    openssh

    # XDG/デスクトップ統合
    file
    libnotify
    xdg-user-dirs
    xdg-utils
  ];
}
