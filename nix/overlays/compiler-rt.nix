# nix/overlays/compiler-rt.nix
# ---------------------------------------------------------------------------
# compiler-rt 18 (Darwin) ビルド修正
# ---------------------------------------------------------------------------
# bitwarden-desktop は Darwin 上で llvmPackages_18.stdenv を強制する
# (argon2 npm 依存が clang 19+ でビルドできないため)。しかし Apple SDK 26.4
# 同梱の libc++ 21 は __builtin_ctzg/clzg (clang 19 で追加) を使うため、
# clang 18 では compiler-rt の C++ コンポーネント (libFuzzer 等) がビルドできない。
#
# 上流修正 PR が未マージのため overlay で先取りする。
# https://github.com/NixOS/nixpkgs/pull/523142
# 影響は Intel Mac (x86_64-darwin) のみ。Apple Silicon 側 (26.11) は clang 21 のため対象外。
final: prev:
prev.lib.optionalAttrs
  (prev.stdenv.hostPlatform.isDarwin && prev.stdenv.hostPlatform.system == "x86_64-darwin")
  {
    llvmPackages_18 = prev.llvmPackages_18.overrideScope (
      llFinal: llPrev: {
        compiler-rt = llPrev.compiler-rt.overrideAttrs (old: {
          cmakeFlags = old.cmakeFlags ++ [
            (final.lib.cmakeBool "COMPILER_RT_BUILD_XRAY" false)
            (final.lib.cmakeBool "COMPILER_RT_BUILD_LIBFUZZER" false)
            (final.lib.cmakeBool "COMPILER_RT_BUILD_MEMPROF" false)
            (final.lib.cmakeBool "COMPILER_RT_BUILD_ORC" false)
          ];
        });
      }
    );
  }
