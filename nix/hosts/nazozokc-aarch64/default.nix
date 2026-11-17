# nix/hosts/nazozokc-aarch64/default.nix
# ホスト「nazozokc-aarch64」(aarch64-linux / ARM デスクトップ・VPS) の設定
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
  # attr 名 (nixosConfigurations.nazozokc-aarch64) と揃える。
  networking.hostName = "nazozokc-aarch64";

  # ---- ブートローダー -------------------------------------------------------
  # UEFI + systemd-boot。aarch64 でも UEFI 機なら同じ構成を使える。
  # installer が /boot に EFI エントリを作った前提。
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    # /boot を世代で埋め尽くさない。直近 10 世代を残す。
    systemd-boot.configurationLimit = 10;
  };
}
