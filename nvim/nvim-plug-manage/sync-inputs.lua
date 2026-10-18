-- nvim/nvim-plug-manage/sync-inputs.lua
--
-- nvim/lua/plugins/*.lua のプラグイン宣言を読み、flake.nix の inputs を同期する。
--
--   - 追加だけする。既存 input の url は一切触らない
--     (fork / codeberg 等の URL 例外は flake.nix 手編集が正)
--   - 削除はしない。Lua から消えた input は orphan として報告するだけ
--   - 入力名は lazy.nvim の plugin.name (= farm のリンク名)
--   - GitHub 以外も Lua 側の url 文字列 ("https://..." / "owner/repo") から導出する
--
-- 使い方 (cwd = nvim/nvim-plug-manage):
--   nvim -l sync-inputs.lua
--
-- 経路: nix run .#nvim-install が呼ぶ。手動実行も可。

-- nix/modules/home/programs/nvim/plugins/default.nix の fromNixpkgs に相当する3件。
-- root の nixpkgs input 由来 (patch / ビルド手順付き) なので flake.nix には入れない。
local EXCLUDE = {
	["lazy.nvim"] = true,
	["denops.vim"] = true,
	["telescope-fzf-native.nvim"] = true,
}

local HEADER = [[# nvim/nvim-plug-manage/flake.nix
#
# Neovim プラグインの「実体とバージョン」を flake input で持つ。
# 正本はこのディレクトリの flake.lock (rev と narHash)。
#
#   追加  : nvim/lua/plugins/*.lua に宣言して nix run .#nvim-install
#           (sync-inputs.lua が宣言から inputs へ自動追加してから lock する)
#   更新  : nix run .#nvim-update
#   適用  : nix run .#switch
#
# 入力名は必ず lazy.nvim の plugin.name と一致させること
# (nvim/lua/plugins/*.lua の名前。farm がそのままリンク名にする)。
#
# inputs ブロックは sync-inputs.lua が再生成する。
#   - 既存 input の url は優先される (fork / codeberg 等の例外は手編集で足してOK)
#   - Lua から消したプラグインの input は削除されない (orphan として報告のみ)
#   - 新規は Lua 宣言から自動追加。GitHub 以外は Lua 側の url 文字列で指定する
#
# flake = false : プラグインはただのソース木なので flake としては扱わない。
# ビルドは nix/modules/home/programs/nvim/plugins/default.nix が行い、
# flake.lock の narHash をそのまま fetchFromGitHub/fetchgit のハッシュに使う。
{
  description = "Neovim plugin sources (single source of truth = flake.lock)";
]]

local FOOTER = [[
  # プラグインは flake ではないので outputs は空。
  # 使われるのは flake.lock のみ。
  outputs = _: { };
}
]]

local function fail(msg)
	io.stderr:write("sync-inputs: " .. msg .. "\n")
	os.exit(1)
end

-- "owner/repo" か url 文字列から lazy.nvim の plugin.name と nix input url を作る。
-- overrideName は spec.name (plugin.name の明示オーバーライド)。
local function ref_to_name_url(ref, overrideName)
	if ref:match("^git%+") then
		ref = (ref:gsub("^git%+", ""))
	end
	if ref:match("^https?://") then
		local path = (ref:gsub("/$", ""))
		local name = path:match("([^/]+)$")
		local gh = path:match("^https://github%.com/([%w_.-]+/[%w_.-]+)$")
		local url = gh and ("github:" .. gh) or ("git+" .. ref)
		return overrideName or name, url
	elseif ref:match("^[%w_.-]+/[%w_.-]+$") then
		return overrideName or ref:match("/([^/]+)$"), "github:" .. ref
	end
	return nil
end

local decls = {} -- name -> { url, from }

local function consider(name, url, from)
	if EXCLUDE[name] then
		return
	end
	local prev = decls[name]
	if prev then
		if prev.url ~= url then
			fail(
				("%s と %s が plugin.name %q で競合している (url: %s vs %s)"):format(
					prev.from,
					from,
					name,
					prev.url,
					url
				)
			)
		end
		return
	end
	decls[name] = { url = url, from = from }
end

local function consider_ref(ref, overrideName, from)
	local name, url = ref_to_name_url(ref, overrideName)
	if name then
		consider(name, url, from)
	end
end

-- lazy.nvim のスペックを走査する。
-- プラグイン名になるのは [1] / url (+ name 上書き) と dependencies 配列だけ。
local function walk_spec(spec, from)
	if type(spec) == "string" then
		consider_ref(spec, nil, from)
		return
	end
	if type(spec) ~= "table" then
		return
	end
	if spec.dir ~= nil or spec.dev ~= nil then
		return -- ローカル参照プラグインは input 化しない
	end
	if type(spec.url) == "string" then
		consider_ref(spec.url, spec.name, from)
	elseif type(spec[1]) == "string" then
		consider_ref(spec[1], spec.name, from)
	end
	local deps = spec.dependencies
	if type(deps) == "string" then
		consider_ref(deps, nil, from)
	elseif type(deps) == "table" then
		for _, d in ipairs(deps) do
			walk_spec(d, from)
		end
	end
end

-- ----------------------------------------------------------
-- 1. Lua 宣言の収集
-- ----------------------------------------------------------
if vim.fn.filereadable("flake.nix") ~= 1 then
	fail("flake.nix が見つからない。nvim/nvim-plug-manage で実行すること")
end

local files = vim.fn.glob("../lua/plugins/*.lua", false, true)
table.sort(files)
local rootSpec = "../lua/plugins.lua"
if vim.fn.filereadable(rootSpec) == 1 then
	table.insert(files, rootSpec)
end
if #files == 0 then
	fail("nvim/lua/plugins/*.lua が見つからない")
end

for _, f in ipairs(files) do
	local chunk, err = loadfile(f)
	if not chunk then
		fail(f .. ": " .. tostring(err))
	end
	local ok, specs = pcall(chunk)
	if not ok then
		fail(f .. ": 評価に失敗した: " .. tostring(specs))
	end
	if type(specs) == "table" then
		-- [1] が string か url 欄があれば単一スペック、無ければスペックのリスト
		if type(specs[1]) == "string" or specs.url ~= nil then
			walk_spec(specs, f)
		else
			for _, spec in ipairs(specs) do
				walk_spec(spec, f)
			end
		end
	elseif specs ~= nil then
		fail(f .. ": スペックがテーブルでない")
	end
end

-- ----------------------------------------------------------
-- 2. 既存 flake.nix の inputs 解析
-- ----------------------------------------------------------
local fh = assert(io.open("flake.nix", "r"))
local text = fh:read("a")
fh:close()

local existing = {}
local parsed = 0
for name, url in text:gmatch('"([^"]+)" =%s*{%s*url = "([^"]+)";%s*flake = false;%s*}') do
	existing[name] = url
	parsed = parsed + 1
end
local blocks = 0
for _ in text:gmatch('"[^"]+" =%s*{') do
	blocks = blocks + 1
end
if blocks ~= parsed then
	fail(("flake.nix inputs が想定外のフォーマット (block %d / parsed %d)"):format(blocks, parsed))
end

-- ----------------------------------------------------------
-- 3. マージ (既存 url 優先 / 新規だけ追加) と再生成
-- ----------------------------------------------------------
local merged = {}
for n, u in pairs(existing) do
	merged[n] = u
end
local added = {}
for name, d in pairs(decls) do
	if not merged[name] then
		merged[name] = d.url
		table.insert(added, { name = name, url = d.url })
	end
end
table.sort(added, function(a, b)
	return a.name < b.name
end)

local orphans = {}
for name in pairs(existing) do
	if not decls[name] then
		table.insert(orphans, name)
	end
end
table.sort(orphans)

local names = {}
for n in pairs(merged) do
	table.insert(names, n)
end
table.sort(names)

local out = { HEADER, "\n  inputs = {\n" }
for _, n in ipairs(names) do
	table.insert(out, ('    "%s" = {\n      url = "%s";\n      flake = false;\n    };\n'):format(n, merged[n]))
end
-- FOOTER は long string 開頭の改行が Lua に読み飛ばされるため空行を明示で足す
table.insert(out, "  };\n\n")
table.insert(out, FOOTER)
local generated = table.concat(out)

if generated == text then
	print(("sync-inputs: 変更なし (inputs %d / lua 宣言 %d)"):format(#names, vim.tbl_count(decls)))
else
	local wh = assert(io.open("flake.nix", "w"))
	wh:write(generated)
	wh:close()
	for _, a in ipairs(added) do
		print(("sync-inputs: + %s  (%s)"):format(a.name, a.url))
	end
	print(("sync-inputs: flake.nix を更新した (inputs %d -> %d)"):format(#names - #added, #names))
end

for _, o in ipairs(orphans) do
	print(("sync-inputs: orphan (lua 宣言なし・保持): %s"):format(o))
end
