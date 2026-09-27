# nix/modules/system/locale.nix
# ロケール設定
#
# 問題: これまで /etc/locale.gen が空で ja_JP.UTF-8 が生成されていなかった。
#       home-manager 側が LANG=ja_JP.UTF-8 を設定していたため、全コマンドが
#       `setlocale: LC_ALL: cannot change locale (ja_JP.UTF-8): No such file or directory`
#       を出し続けていた。ここでは OS 側で実際に locale を生成する。
#
# 注意: system-manager が import する NixOS モジュールに i18n.defaultLocale は
#       存在しない (stub は i18n.glibcLocales のみ) ため /etc を直接管理する。
{
  lib,
  pkgs,
  ...
}:

let
  # 生成するロケール (locale.gen の "<locale> <charmap>" 形式)。
  # 日本語を主ロケールとし、LC_MESSAGES 用の英語も用意する
  locales = [
    "ja_JP.UTF-8 UTF-8"
    "en_US.UTF-8 UTF-8"
  ];
in
{
  environment.etc = {
    # /etc/locale.gen は systemd-localed が locale-archive の再生成判定に使う。
    # Arch の glibc はコメントのみの既定ファイルなので置換する
    "locale.gen" = {
      text = lib.concatStringsSep "\n" locales + "\n";
      mode = "0644";
      replaceExisting = true;
    };

    # /etc/locale.conf は LANG のみ設定する。
    # LC_ALL は全カテゴリを固定し、LC_TIME / LC_MESSAGES などの個別設定を壊すため設定しない。
    "locale.conf" = {
      text = "LANG=ja_JP.UTF-8\n";
      mode = "0644";
      replaceExisting = true;
    };

    # コンソールのキーボード配置。ja_JP.UTF-8 と整合させる
    "vconsole.conf" = {
      text = "KEYMAP=jp\n";
      mode = "0644";
      replaceExisting = true;
    };
  };

  # nixpkgs の glibc.locale-gen は Nix store 宛に書き込むため使えない。
  # ホスト側 glibc (= Arch のパッケージ) の locale-gen を呼んで
  # /usr/lib/locale/locale-archive を更新させる必要がある。
  #
  # systemd-localed も locale.gen の mtime を見て再生成するが、activation は
  # sysinit-reactivation.target のみを觸発するため、明示的な oneshot を用意して 확실성을上げる。
  systemd.services.nix-locale-gen = {
    description = "Generate locales declared in /etc/locale.gen (managed by Nix)";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [
      pkgs.coreutils
    ];
    script = ''
      if [ ! -x /usr/bin/locale-gen ]; then
        echo "warning: /usr/bin/locale-gen not found, skipping locale generation" >&2
        exit 0
      fi

      # --keep-existing: ホスト側で個別に追加されたロケールを消さない
      /usr/bin/locale-gen --keep-existing
    '';
  };
}
