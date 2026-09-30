-- Keybindings: nvim + wezterm style
-- https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- Design principles:
--   • $mainMod (= SUPER / Windows key) is the primary modifier,
--     akin to wezterm's Ctrl+Shift prefix.
--   • hjkl for window focus movement (vim/wezterm convention).
--   • Workspaces map to tabs (wezterm: Ctrl+Shift+[number/[/]]).
--   • $mainMod + q to close = wezterm's Ctrl+Shift+q.
--
-- Ambxst との役割分担:
--   Ambxst は既定で 20 個のキーを割り当てる。ここに同じキーを書いても
--   hyprland.lua 末尾で読み込む Ambxst 側が後勝ちして上書きするため無効。
--   そのため Ambxst のキーはここでは一切定義しない。
--
--     launcher   SUPER+Super_L      dashboard  SUPER+D
--     assistant  SUPER+A            clipboard  SUPER+V
--     emoji      SUPER+PERIOD       notes      SUPER+N
--     tmux       SUPER+T            wallpapers SUPER+COMMA
--     config     SUPER+SHIFT+C      lockscreen SUPER+L
--     overview   SUPER+TAB          powermenu  SUPER+ESCAPE
--     tools      SUPER+S            screenshot SUPER+SHIFT+S
--     screenrec  SUPER+SHIFT+R      lens       SUPER+SHIFT+A
--     bar        SUPER+SHIFT+B      reload     SUPER+ALT+B
--     quit       SUPER+CTRL+ALT+B   close win  SUPER+C
--
--   自分の体系 (hjkl / workspace / resize) は Ambxst と一切重複しない。

local mainMod = "SUPER"

-- ═══════════════════════════════════════════════════════════
-- NAVIGATION (vim hjkl → focus direction)
-- ═══════════════════════════════════════════════════════════
-- wezterm:  Ctrl+Shift + h/j/k/l → pane focus
-- Hyprland: $mainMod   + h/j/k/l → window focus

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))

-- ═══════════════════════════════════════════════════════════
-- WINDOW MANAGEMENT
-- ═══════════════════════════════════════════════════════════
-- wezterm:  Ctrl+Shift + q → close pane
-- Hyprland: $mainMod   + q → close window

hl.bind(mainMod .. " + Q", hl.dsp.window.close()) -- close window
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen()) -- toggle fullscreen
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" })) -- toggle float
-- pseudo tiling (like nvim :vsp)
-- 旧キーは SUPER+V だったが Ambxst の clipboard が割り当てているため
-- 未使用の SUPER+P に移設した。
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- toggle pseudo tiling
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- toggle split direction (dwindle)

-- Move window in direction (like wezterm's move_to_new_tab, but directional)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

-- Resize window (wezterm's Ctrl+Shift+Alt+hjkl equivalent)
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })

-- ═══════════════════════════════════════════════════════════
-- WORKSPACES (wezterm tabs)
-- ═══════════════════════════════════════════════════════════
-- wezterm:  Ctrl+Shift + number → switch tab
-- Hyprland: $mainMod   + number → switch workspace

for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Tab navigation: prev/next workspace
-- wezterm:  Ctrl+Shift + [ / ] → prev/next tab
hl.bind(mainMod .. " + bracketleft", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "m+1" }))

-- ═══════════════════════════════════════════════════════════
-- LAUNCH
-- ═══════════════════════════════════════════════════════════
-- $mainMod + Return  → terminal (wezterm: Ctrl+Shift+t = new tab, analog)
-- ランチャー (旧 SUPER+D / SUPER+SHIFT+D の rofi) は Ambxst が担当

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("wezterm"))

-- ═══════════════════════════════════════════════════════════
-- SYSTEM
-- ═══════════════════════════════════════════════════════════
-- lock (旧 SUPER+L) / logout menu (旧 SUPER+SHIFT+Escape) は
-- Ambxst の lockscreen / powermenu が担当
-- sleep は Ambxst に bind が無いので残す。
-- 旧キーは SUPER+SHIFT+L だったが、上の "move right" と重複していて
-- 後勝ちのこちらが (move を) 殺していたため SUPER+ALT+ESCAPE へ変更。
-- ESCAPE 系でまとめると Ambxst の powermenu (SUPER+ESCAPE) と紛らわしくない。
hl.bind(mainMod .. " + ALT + ESCAPE", hl.dsp.exec_cmd("systemctl suspend")) -- sleep
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl dispatch exit")) -- quit (nvim :q!)

-- ═══════════════════════════════════════════════════════════
-- MOUSE
-- ═══════════════════════════════════════════════════════════
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ═══════════════════════════════════════════════════════════
-- MEDIA / BRIGHTNESS KEYS
-- ═══════════════════════════════════════════════════════════
-- 旧: XF86Audio* → playerctl / wpctl, XF86MonBrightness* → brightnessctl
-- Ambxst が media control と OSD (音量・輝度) を持つため削除。
