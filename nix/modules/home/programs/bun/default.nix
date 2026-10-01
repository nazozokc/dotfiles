# bun configuration
# pnpm (programs/pnpm) と同型。bun のグローバルインストール先を XDG 準拠の
# 場所に固定し、どのシェルからでも同じ解決順になるようにする。
#
# bun 本体は nix/modules/home/packages/dev/default.nix の home.packages で
# 入る。ここでは「bun add -g / bunx が書き込む先」だけを定義する。
#
# bunfig.toml ([install] globalDir / globalBinDir) は使わない。
# home-manager が ~/.bunfig.toml を生成すると手元の設定を上書きするうえ、
# bunfig.toml は global → project の順に解決されるので優先順位の事故が起きやすい。
# 環境変数はプロセス環境なので fish / bash / zsh いずれからでもそのまま効く。
{
  config,
  ...
}:

{
  dotfiles.programs.bun = {
    icon = "🥟";
    note = "BUN_INSTALL を XDG 準拠へ";
  };

  # BUN_INSTALL_GLOBAL_DIR : `bun add -g` がパッケージを落とす先
  # BUN_INSTALL_BIN        : グローバル包の bin のリンク先 (PATH へ追加する)
  # BUN_INSTALL_CACHE_DIR  : グローバルモジュールキャッシュ
  #
  # BUN_INSTALL も指定する。未設定のままだと
  # `${BUN_INSTALL:-$HOME/.bun}` で参照する外部ツールが
  # ~/.bun (作られないパス) を指すため。
  home.sessionVariables = {
    BUN_INSTALL = "${config.xdg.dataHome}/bun";
    BUN_INSTALL_GLOBAL_DIR = "${config.xdg.dataHome}/bun/install/global";
    BUN_INSTALL_BIN = "${config.xdg.dataHome}/bun/bin";
    BUN_INSTALL_CACHE_DIR = "${config.xdg.cacheHome}/bun/install/cache";
  };

  # `bun add -g` が入れた CLI を解決できるようにする
  home.sessionPath = [
    "${config.xdg.dataHome}/bun/bin"
  ];
}
