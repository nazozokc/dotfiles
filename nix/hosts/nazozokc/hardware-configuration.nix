# nix/hosts/nazozokc/hardware-configuration.nix
# ホスト「nazozokc」のハードウェア設定
#
# ⚠️ これはスタブ。実機の disk layout / UUID に合わせて差し替えること。
#    実機で以下を実行し、出力をこのファイルに貼り付ける:
#      nixos-generate-config --show-hardware-config
#
# 差し替えポイント:
#   - fileSystems."/" の device (UUID / label)
#   - fileSystems."/boot" の device (EFI system partition)
#   - boot.initrd.availableKernelModules (ストレージ / USB コントローラ)
#   - swapDevices (swap を使う場合)
{ lib, modulesPath, ... }:
{
  imports = [
    # ハードウェア自動検出のデフォルト設定
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ストレージコントローラ (NVMe / SATA / USB)。必要に応じて追加する
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # ⚠️ スタブ値。実機の UUID に差し替えること
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # ⚠️ スタブ値。実機の EFI パーティションに差し替えること
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  # インストール ISO は x86_64。実機も x86_64 なので固定してよい
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
