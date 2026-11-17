# nix/hosts/nazozokc/default.nix
# ホスト「nazozokc」(x86_64-linux デスクトップ) の設定
#
# hardware-configuration.nix は `nixos-generate-config` が生成するもの。
# 初回はスタブが入っているので、実機の disk layout に合わせて
# `nixos-generate-config --show-hardware-config` の出力で置き換えること。
_: {
  imports = [
    ./hardware-configuration.nix
  ];

  # ---- ホスト名 -------------------------------------------------------------
  # ホスト固有値は hosts/<name>/ に閉じる (system.nix は共通設定だけを持つ)。
  # attr 名 (nixosConfigurations.<name>) と揃える。
  networking.hostName = "nazozokc";

  # ---- ブートローダー -------------------------------------------------------
  # UEFI + systemd-boot。NixOS の標準構成。
  # installer が /boot に EFI エントリを作った前提 (nixos-infect 等では不要)。
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    # /boot を世代で埋め尽くさない。直近 10 世代を残す。
    systemd-boot.configurationLimit = 10;
  };
}
