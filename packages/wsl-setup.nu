#!/usr/bin/env nu
# wsl-setup.nu - Apply WSL system config (requires root)
#  1. Deploy wsl/wsl.conf to /etc/wsl.conf
#  2. Generate ja_JP.UTF-8 locale (Arch)
# Usage (fish):  sudo -E (which wsl-setup)
# Usage (bash):  sudo -E $(which wsl-setup)
#   Nix のラッパーが nu の実体を直接 exec するので root の PATH に nu は不要

def main [] {
  if ((^id -u | str trim) != "0") {
    print -e "Error: run with sudo (root required)"
    exit 1
  }

  # Nix パッケージ経由では DOTFILES_WSL_CONF に store 上の wsl.conf が入る
  let wsl_conf_src = if "DOTFILES_WSL_CONF" in $env {
    $env.DOTFILES_WSL_CONF
  } else {
    # リポジトリから直接実行した場合 (symlink 経由でも直パスでも対応)
    let script_dir = (^realpath $env.FILE_PWD | str trim)
    let repo_root = ($script_dir | path dirname)
    $"($repo_root)/wsl/wsl.conf"
  }

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
