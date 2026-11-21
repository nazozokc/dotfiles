# nix/overlays/my-scripts.nix
# packages/ の Nu スクリプトを PATH 上のコマンドとして提供する。
#
# - スクリプト本体は store へコピーし、ラッパーから nu の実体を直接 exec する。
#   sudo 実行時に root の PATH へ nu が無くても動くようにするため。
# - wsl-setup だけはリポジトリの wsl/wsl.conf を必要とする。
#   conf を store へ焼き、DOTFILES_WSL_CONF で場所を渡す。
{ self }:
_final: prev:
let
  inherit (prev) lib;

  scripts = [
    "extract"
    "gh-new"
    "gh-pr"
    "mkcd"
    "port-check"
    "wsl-setup"
  ];

  commonInputs = with prev; [
    coreutils
    findutils
    gnugrep
    gnutar
    gzip
    bzip2
    xz
    zstd
    unzip
    unrar
    p7zip
    lzip
    ncompress
    cpio
    gh
    lsof
  ];

  linuxInputs = with prev; [
    dpkg
    rpm
    iproute2
  ];

  runtimeInputs = commonInputs ++ lib.optionals prev.stdenv.hostPlatform.isLinux linuxInputs;

  scriptDir = prev.runCommand "my-scripts-src" { } ''
    mkdir -p $out/share/my-scripts
    for script in ${lib.concatStringsSep " " scripts}; do
      install -m 755 ${self}/packages/$script.nu $out/share/my-scripts/$script.nu
    done
  '';

  wslConf = prev.runCommand "my-scripts-wsl-conf" { } ''
    mkdir -p $out/share/my-scripts
    install -m 644 ${self}/wsl/wsl.conf $out/share/my-scripts/wsl.conf
  '';

  wrap =
    name:
    prev.writeShellScriptBin name ''
      export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
      ${lib.optionalString (
        name == "wsl-setup"
      ) "export DOTFILES_WSL_CONF=${wslConf}/share/my-scripts/wsl.conf"}
      exec ${prev.nushell}/bin/nu --no-config-file ${scriptDir}/share/my-scripts/${name}.nu "$@"
    '';
in
{
  my-scripts = prev.symlinkJoin {
    name = "my-scripts";
    paths = map wrap scripts;
    meta = {
      description = "packages/ を PATH 上で使えるようにしたコマンド群";
      platforms = lib.platforms.unix;
      mainProgram = "extract";
    };
  };
}
