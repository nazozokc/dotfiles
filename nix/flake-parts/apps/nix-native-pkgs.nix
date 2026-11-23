# nlp の新仕様 (flat packages + packagesByPm) を使う。
# autoDetect は既定 true なので、packages は全 pm に配られ、
# 実際に使う pm は実行時の PATH で決まる。
{ inputs, ... }:
{
  imports = [ inputs.linux-pkgmanager-nix.flakeModules.default ];

  nlp = {
    packages = import ../../native-pkgs/common.nix;
    # パスのまま渡すと packages (flat) と連結されないので、必ず import してリストにする
    packagesByPm = {
      apt = import ../../native-pkgs/apt.nix;
      dnf = import ../../native-pkgs/dnf.nix;
      pacman = import ../../native-pkgs/pacman.nix;
      yum = import ../../native-pkgs/yum.nix;
      zypper = import ../../native-pkgs/zypper.nix;
    };
  };
}
