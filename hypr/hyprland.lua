-- Hyprland configuration entry point
-- https://wiki.hypr.land/Configuring/Start/
--
-- Sub-configs are loaded via require().
-- Each file is a separate Lua scope, so errors in one don't affect others.

require("env")
require("monitors")
require("input")
require("appearance")
require("windowrules")
require("keybinds")
require("exec")

-- Ambxst
--
-- ~/.local/share/ambxst/hyprland.lua は axctl デーモンがテーマ / gaps /
-- binds 変更のたびに再生成するランタイム生成物。したがって home-manager の
-- 管理下に置かない (/nix/store は read-only で、デーモンが書き戻せない)。
-- ここでは毎回読み込むだけにして、実体は Ambxst 側に持たせる。
--
-- 読み込み位置が最後 = Ambxst の設定 (hl.config / hl.bind / hl.window_rule /
-- hl.layer_rule) が、先に読んだ自分の設定を上書きする。
--
-- ガードは必須: loadfile はファイル不在時に nil を返すため、そのまま
-- 呼ぶと初回ログイン (まだ生成されていない) で Lua エラーになり
-- Hyprland の設定読込が丸ごと失敗する。
--
-- ただしガードだけでは bootstrap できない。生成物が無い = Ambxst が起動し
-- てない = 生成物も作られない、という循環になるため、無い側では自分で
-- ambxst を起動する。生成された時点で上の分岐に切り替わり、以降は
-- 生成物の [startup] exec-once = "ambxst" に起動を任せる (二重起動しない)。
--
-- 初回は生成物が読み込まれないため Ambxst の hl.bind 等は反映されず、
-- hyprctl reload か次回ログインで効く。
local ambxstConf = os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua"
local ambxstFd = io.open(ambxstConf, "r")
if ambxstFd then
	ambxstFd:close()
	loadfile(ambxstConf)()
else
	hl.on("hyprland.start", function()
		hl.exec_cmd("ambxst")
	end)
end
