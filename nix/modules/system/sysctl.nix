# nix/modules/system/sysctl.nix
# カーネルパラメータ (sysctl) 設定
#
# 重要: system-manager が import する NixOS モジュールに config/sysctl.nix は
#       含まれない。boot オプションは lib.types.raw のスタブなので
#       `boot.kernel.sysctl` を書いても何も生成されない (silent no-op)。
#       そのため environment.etc で sysctl.d の drop-in を直接置く。
{
  lib,
  ...
}:

let
  # 変更するカーネルパラメータ。
  # キーは sysctl の正式名なので必ず引用符で囲むこと
  # (引用しないと net.ipv4.x が入れ子 attrset になり toString が失敗する)。
  settings = {
    # ---- 開発環境向け -----------------------------------------------
    # 低ポートを root 無しで bind できるようにする (dev server 向け)
    # 現状: 1024
    "net.ipv4.ip_unprivileged_port_start" = 0;

    # Wayland / Electron / Chromium が必要とする contiguous mmap 上限
    # NixOS デフォルトと同じ値。Arch 既定と明示的に揃えるための明示
    # 現状: 1048576
    "vm.max_map_count" = 1048576;

    # nvim / lazy.nvim / file watcher 用の inotify 監視数
    # 現状: 524288
    "fs.inotify.max_user_watches" = 524288;

    # SSD 環境で swap thrash を抑える
    # 現状: 60
    "vm.swappiness" = 10;

    # ---- セキュリティ強化 -------------------------------------------
    # dmesg を root 以外から読めないようにする
    # 現状: 0
    "kernel.dmesg_restrict" = 1;

    # /proc/kallsyms 経由のカーネルポインタアドレスを全面秘匿
    "kernel.kptr_restrict" = 2;

    # ptrace によるプロセス干渉を全面禁止する。
    # 注意: 既定で gdb / strace / bpftrace が他プロセスにアタッチできなくなる。
    #      デバッグが必要な場合は 3 -> 1 に戻すこと
    # 現状: 1
    "kernel.yama.ptrace_scope" = 3;
  };
in
{
  # systemd-sysctl は sysctl.d(5) のファイルを「ディレクトリに関係なく
  # ファイル名の辞書順」で読み、**辞書順で後ろのファイルが勝つ**。
  # (`/etc/sysctl.d` が優先、ではなく「60- が 50- より後」というルール)
  #
  # ディストリ側の既定 (Arch / Debian / Fedora の /usr/lib/sysctl.d/50-default.conf
  # など) より後で評価させるため 60- 接頭辞にする。sysctl.d(5) が推奨する
  # 60-90 帯 (/usr/ は 10-40) にそのまま従う。
  environment.etc."sysctl.d/60-nix.conf" = {
    text =
      lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} = ${toString v}") settings) + "\n";
    mode = "0644";
  };
}
