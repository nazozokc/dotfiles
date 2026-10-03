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
#
# ディストリ差分:
#   /etc/locale.conf … systemd + glibc が読む。全ディストロ共通。ここは共通のまま。
#   /etc/locale.gen  … あるのは Debian / Ubuntu / Arch / Fedora / Gentoo。
#                     openSUSE には無い (生成済み locale を glibc-locales が持つ)。
#                     無い環境で書いても systemd は無視する。
#   locale-gen       … 置き場所はディストロで違う。Arch/Fedora は /usr/bin、
#                     Debian/Ubuntu は /usr/sbin。openSUSE には無い。
#   --keep-existing  … Debian 版 locale-gen のオプション。glibc 同梱版は
#                     引数を見ないため渡しても無害。
#   → oneshot は「locale-gen → 無ければ localedef → どちらも無ければ warning」で
#     どのディストロでも失敗しない形にしておく。
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
    #
    # Debian / Ubuntu は /etc/default/locale が ../locale.conf への symlink なので
    # こっちだけ直せば両方に効く (置換時に existing の symlink は退避される)。
    "locale.conf" = {
      text = "LANG=ja_JP.UTF-8\n";
      mode = "0644";
      replaceExisting = true;
    };

    # コンソールのキーボード配置。ja_JP.UTF-8 と整合させる。
    # systemd の vconsole 設定なのでディストロ非依存。
    # Debian / Ubuntu では /etc/default/keyboard への symlink になっているが、
    # replaceExisting で実ファイルに置換される (symlink 自体は退避される)。
    "vconsole.conf" = {
      text = "KEYMAP=jp\n";
      mode = "0644";
      replaceExisting = true;
    };
  };

  # nixpkgs の glibc.locale-gen は Nix store 宛に書き込むため使えない。
  # ホスト側 glibc (= ディストロの glibc パッケージ) の locale-gen / localedef を
  # 呼んで /usr/lib/locale/locale-archive を更新させる必要がある。
  #
  # systemd-localed も locale.gen の mtime を見て再生成するが、activation は
  # sysinit-reactivation.target のみを觸発するため、明示的な oneshot を用意して確実性を上げる。
  #
  # musl libc のディストリ (Alpine 等) には locale-gen も localedef も無い。
  # その場合は warning して正常終了する (system-switch を止めない)。
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
      # ---- ツールを探す -------------------------------------------------
      # sbin は PATH 解決に載らないため、絶対パスを順番に探す
      find_first() {
        local candidate
        for candidate in "$@"; do
          if [ -x "$candidate" ]; then
            echo "$candidate"
            return 0
          fi
        done
        return 0
      }

      locale_gen="$(find_first /usr/bin/locale-gen /usr/sbin/locale-gen)"
      localedef="$(find_first /usr/bin/localedef /usr/sbin/localedef)"

      # ---- locale-gen がある (Debian / Ubuntu / Arch / Fedora / Gentoo) --
      if [ -n "$locale_gen" ]; then
        echo "generating locales with $locale_gen"

        # --keep-existing は Debian 版だけ。glibc 同梱版は引数を見ないので
        # 渡しても無害するが、未対応で失敗する実装に備えて一度で諦める
        if "$locale_gen" --keep-existing; then
          exit 0
        fi

        echo "warning: \"$locale_gen --keep-existing\" failed; retrying without the option" >&2
        "$locale_gen"
        exit 0
      fi

      # ---- locale-gen が無い (openSUSE 等) → localedef を直接叩く -------
      if [ -z "$localedef" ]; then
        echo "warning: neither locale-gen nor localedef found in /usr/{s,}bin" >&2
        echo "         skipping locale generation (expected on musl libc distros)" >&2
        exit 0
      fi

      echo "generating locales with $localedef (locale-gen is absent)"

      # 引数は -i <locale> -f <charmap> <name>。
      # localedef は既定で /usr/lib/locale/locale-archive へ追記する。
      while read -r loc charmap; do
        [ -n "$loc" ] || continue
        echo "  $loc ($charmap)"
        if ! "$localedef" -i "$loc" -f "$charmap" "$loc"; then
          # archive に既存なら「既に生成済み」で失敗する。警告に留める
          echo "  warning: could not generate $loc (already present?)" >&2
        fi
      done <<'NIX_LOCALES'
      ${lib.concatStringsSep "\n" locales}
      NIX_LOCALES

      exit 0
    '';
  };
}
