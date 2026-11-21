#!/usr/bin/env nu
# wsl-setup.nu - Apply WSL system config (requires root)
#  1. Deploy wsl/wsl.conf to /etc/wsl.conf
#  2. Generate ja_JP.UTF-8 locale (Arch)
# Usage (fish):  sudo -E (which nu) ~/.scripts/wsl-setup.nu
# Usage (bash):  sudo -E $(which nu) ~/.scripts/wsl-setup.nu
#   sudo 実行時は root の PATH に nu が無いことが多いため本体を明示する
#   (nu が root の PATH に入っている環境なら sudo ~/.scripts/wsl-setup.nu でも動く)

def main [] {
  if ((^id -u | str trim) != "0") {
    print -e "Error: run with sudo (root required)"
    exit 1
  }

  # リポジトリルートを解決 (~/.scripts symlink 経由でも直パスでも対応)
  let script_dir = (^realpath $env.FILE_PWD | str trim)
  let repo_root = ($script_dir | path dirname)
  let wsl_conf_src = $"($repo_root)/wsl/wsl.conf"

  if not ($wsl_conf_src | path exists) {
    print -e $"Error: ($wsl_conf_src) not found"
    exit 1
  }

  print $"==> Deploying ($wsl_conf_src) -> /etc/wsl.conf"
  ^install -m 644 $wsl_conf_src /etc/wsl.conf
  print "    Done."

  print "==> Ensuring ja_JP.UTF-8 locale..."
  let locale_found = (^grep -qx 'ja_JP.UTF-8 UTF-8' /etc/locale.gen e> /dev/null | complete)
  if $locale_found.exit_code != 0 {
    "ja_JP.UTF-8 UTF-8\n" | save --append /etc/locale.gen
    print "    Added ja_JP.UTF-8 UTF-8 to /etc/locale.gen"
  }
  ^locale-gen
  print "    Done."

  print ""
  print "==> Apply requires WSL restart. On Windows run:"
  print "    wsl --shutdown"
}
