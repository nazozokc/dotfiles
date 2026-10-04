# shellcheck shell=bash
# nix/lib/script/40-detect.sh — ホストの pm と OS の識別
#
# 責務は「どれを使うか」を決めることだけ。
# 照合や表示はこのファイルの責務ではない

# 使える pm を PM_ORDER の順に探して最初の 1 つを返す。
#
# 複数ある環境 (WSL + Windows 側の apt など) では最初の 1 つを採用する。
# 宣言はどの pm にも書けるので、誤検出を警告するより
# 「1 つに絞る」ほうが挙動として説明しやすい
detect_pm() {
  local pm
  for pm in "${PM_ORDER[@]}"; do
    if command -v "${PM_BINARY[$pm]}" >/dev/null 2>&1; then
      printf '%s\n' "$pm"
      return 0
    fi
  done
  return 1
}

# /etc/os-release の ID。読めなければ unknown
host_id() {
  local id=""
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091  # /etc/os-release は実行環境にしか無い
    id="$(. /etc/os-release 2>/dev/null && printf '%s' "${ID:-}")"
  fi
  printf '%s' "${id:-unknown}"
}
