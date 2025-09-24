-- ~/projects/matugen.nvim/lua/matugen_colorscheme/init.lua
-- Lean core with robust JSONC support, safe apply, optional fs watch, and clear APIs.

local M = {}

local uv = vim.uv or vim.loop -- libuv bindings exposed by Neovim [>=0.8], documented as vim.uv [web:20]
local api, fn, opt = vim.api, vim.fn, vim.opt

-- Defaults
local DEFAULT = {
  file = fn.stdpath("cache") .. "/matugen/colors.jsonc",
  plugins = {
    base = true,
    treesitter = true,
    cmp = false,
    gitsigns = false,
    miscellaneous = true,
  },
  ignore_groups = {},
  custom_highlights = nil, -- function(colors, cfg, set_hl) | table {Group=Spec}
  debug = false,
  auto_apply = true,
  watch = false, -- poll the file for changes (portable via libuv fs_poll)
  watch_interval_ms = 500, -- fs poll interval; clamped to sane minimum
  background = nil, -- "dark" | "light" | nil (no change)
}

-- State
local cfg = vim.deepcopy(DEFAULT)
local colors_cache, colors_mtime = nil, nil
local commands_created = false
local poll_handle = nil
local modules_cache = {} -- cache successfully required highlight modules

-- Debug logger
local function log(msg, level)
  if not cfg.debug then
    return
  end
  vim.notify("[matugen] " .. tostring(msg), level or vim.log.levels.INFO) -- idiomatic notify [web:14]
end

-- Robust JSONC stripper: removes // and /* */ outside of strings; preserves escapes.
-- This avoids breaking JSON content that contains comment-like sequences in string literals.
local function strip_jsonc(s)
  local out = {}
  local i, len = 1, #s
  local in_str, esc = false, false
  local in_line, in_block = false, false
  while i <= len do
    local c = s:sub(i, i)
    local n = s:sub(i + 1, i + 1)

    if in_line then
      if c == "\n" then
        in_line = false
        table.insert(out, c)
      end
      i = i + 1
    elseif in_block then
      if c == "*" and n == "/" then
        in_block = false
        i = i + 2
      else
        i = i + 1
      end
    elseif in_str then
      table.insert(out, c)
      if esc then
        esc = false
      elseif c == "\\" then
        esc = true
      elseif c == '"' then
        in_str = false
      end
      i = i + 1
    else
      if c == '"' then
        in_str = true
        table.insert(out, c)
        i = i + 1
      elseif c == "/" and n == "/" then
        in_line = true
        i = i + 2
      elseif c == "/" and n == "*" then
        in_block = true
        i = i + 2
      else
        table.insert(out, c)
        i = i + 1
      end
    end
  end
  return table.concat(out)
end

-- Read full file (fast path: libuv)
local function read_all(path)
  if uv and uv.fs_open then
    local fd, err = uv.fs_open(path, "r", 438)
    if not fd then
      return nil, err
    end
    local stat, serr = uv.fs_fstat(fd)
    if not stat then
      uv.fs_close(fd)
      return nil, serr
    end
    local data, rerr = uv.fs_read(fd, stat.size, 0)
    uv.fs_close(fd)
    if not data then
      return nil, rerr
    end
    return data
  end
  local f = io.open(path, "rb")
  if not f then
    return nil, "open failed"
  end
  local data = f:read("*a")
  f:close()
  return data
end

-- File mtime in seconds (libuv fs_stat), may be table {sec,nsec} or number.
local function file_mtime(path)
  if not (uv and uv.fs_stat) then
    return nil
  end
  local st = uv.fs_stat(path)
  if not st then
    return nil
  end
  local mt = st.mtime
  if type(mt) == "table" and mt.sec then
    return mt.sec
  end
  if type(mt) == "number" then
    return mt
  end
  return nil
end

-- JSONC -> Lua table using Neovim's built-in JSON decoder.
local function decode_jsonc(data)
  local ok, decoded = pcall(vim.json.decode, strip_jsonc(data)) -- JSON decoder is vim.json.decode [web:28]
  if not ok or type(decoded) ~= "table" then
    return nil, decoded
  end
  return decoded, nil
end

-- Load colors with mtime cache; only clear/apply when a valid palette is present.
local function load_colors(force)
  local path = cfg.file
  local mtime = file_mtime(path)
  if not force and colors_cache and colors_mtime and mtime and mtime == colors_mtime then
    log("colors.jsonc unchanged; using cache")
    return colors_cache
  end
  local data, err = read_all(path)
  if not data or data == "" then
    vim.notify("Matugen: cannot read color file: " .. path, vim.log.levels.ERROR)
    log("read error: " .. tostring(err), vim.log.levels.ERROR)
    return nil
  end
  local decoded, derr = decode_jsonc(data)
  if not decoded then
    vim.notify("Matugen: invalid JSON/JSONC in color file: " .. path, vim.log.levels.ERROR)
    log("json decode failed: " .. tostring(derr), vim.log.levels.ERROR)
    return nil
  end
  colors_cache = decoded
  colors_mtime = mtime or os.time()
  return colors_cache
end

-- Normalize highlight spec for nvim_set_hl; empty table clears a group; link passes through a link-only change.
local valid_style = {
  bold = true,
  italic = true,
  underline = true,
  undercurl = true,
  reverse = true,
  strikethrough = true,
  nocombine = true,
}

local function normalize_spec(spec)
  if spec.link then
    return { link = spec.link } -- link is a special case in nvim_set_hl [web:14]
  end
  local out = {}
  if spec.fg then
    out.fg = spec.fg
  end
  if spec.bg then
    out.bg = spec.bg
  end
  if spec.sp then
    out.sp = spec.sp
  end
  if spec.ctermfg then
    out.ctermfg = spec.ctermfg
  end
  if spec.ctermbg then
    out.ctermbg = spec.ctermbg
  end
  if spec.blend then
    out.blend = spec.blend
  end
  local style = spec.style
  if type(style) == "string" then
    style = { style }
  end
  if type(style) == "table" then
    for _, s in ipairs(style) do
      if valid_style[s] then
        out[s] = true
      end
    end
  end
  return out
end

local function set_hl(group, spec)
  if type(group) ~= "string" or type(spec) ~= "table" then
    return
  end
  local ok, err = pcall(api.nvim_set_hl, 0, group, normalize_spec(spec)) -- global namespace 0 is standard for colorschemes [web:14]
  if not ok then
    log("set_hl failed for " .. group .. ": " .. tostring(err), vim.log.levels.WARN)
  end
end

local function set_many(tbl)
  for group, spec in pairs(tbl or {}) do
    set_hl(group, spec)
  end
end

-- Apply highlight submodule (cached require)
local function apply_module(name, colors)
  if not cfg.plugins[name] then
    return
  end
  local mod = modules_cache[name]
  if mod == nil then
    local ok_req, loaded = pcall(require, "matugen_colorscheme.highlights." .. name)
    if ok_req and type(loaded) == "table" and type(loaded.apply) == "function" then
      modules_cache[name] = loaded
      mod = loaded
    else
      modules_cache[name] = false
      log("skip module " .. name .. " (missing apply)", vim.log.levels.WARN)
      return
    end
  elseif mod == false then
    return
  end
  local ok_apply, err = pcall(mod.apply, colors, cfg, set_hl)
  if not ok_apply then
    log("module " .. name .. " error: " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- Public: apply colorscheme
function M.apply()
  local colors = load_colors(false)
  if not colors then
    return false
  end

  -- Clear/reset only when a valid palette is available.
  api.nvim_command("highlight clear") -- equivalent to :hi clear [web:14]
  if fn.exists("syntax_on") == 1 then
    api.nvim_command("syntax reset") -- aligns with typical colorscheme lifecycle [web:14]
  end
  if cfg.background == "dark" or cfg.background == "light" then
    vim.o.background = cfg.background -- set before colors to let defaults adapt [web:21]
  end
  vim.g.colors_name = "matugen" -- advertise theme name per convention [web:14]
  opt.termguicolors = true -- ensure GUI colors for hex highlights [web:21]

  -- Foundation
  set_hl("Normal", {
    fg = colors.on_surface or "#ffffff",
    bg = colors.background or "#000000",
  })

  -- Modules
  for name, enabled in pairs(cfg.plugins) do
    if enabled then
      apply_module(name, colors)
    end
  end

  -- Custom highlights
  if type(cfg.custom_highlights) == "function" then
    pcall(cfg.custom_highlights, colors, cfg, set_hl)
  elseif type(cfg.custom_highlights) == "table" then
    set_many(cfg.custom_highlights)
  end

  -- Clear ignored groups (empty table clears per API)
  for _, group in ipairs(cfg.ignore_groups or {}) do
    pcall(api.nvim_set_hl, 0, group, {}) -- clearing via {} is supported [web:16]
  end

  -- Fire ColorScheme autocommands for better ecosystem compatibility.
  pcall(api.nvim_exec_autocmds, "ColorScheme", { pattern = "matugen" }) -- trigger lifecycle hooks [web:14]

  return true
end

-- Public: force reload
function M.reload()
  colors_cache, colors_mtime = nil, nil
  return M.apply()
end

-- File watch (fs poll)
local function stop_watch()
  if poll_handle and not poll_handle:is_closing() then
    poll_handle:stop()
    poll_handle:close()
  end
  poll_handle = nil
end

local function start_watch()
  stop_watch()
  if not (uv and uv.new_fs_poll) or not cfg.watch then
    return
  end
  local path = cfg.file
  local handle = uv.new_fs_poll()
  if not handle then
    return
  end
  poll_handle = handle
  handle:start(path, math.max(100, tonumber(cfg.watch_interval_ms) or 500), function(err, prev, curr)
    if err then
      log("fs_poll error: " .. tostring(err), vim.log.levels.WARN)
      return
    end
    local prev_m = prev and (prev.mtime and (prev.mtime.sec or prev.mtime) or nil) or nil
    local curr_m = curr and (curr.mtime and (curr.mtime.sec or curr.mtime) or nil) or nil
    if curr_m and curr_m ~= colors_mtime then
      vim.schedule(function()
        log("palette changed on disk; reloading")
        M.reload()
      end)
    end
  end)
end

-- Define user commands once
local function ensure_commands()
  if commands_created then
    return
  end
  commands_created = true

  api.nvim_create_user_command("MatugenApply", function()
    if M.apply() then
      vim.notify("Matugen: applied", vim.log.levels.INFO)
    end
  end, { desc = "Apply Matugen colorscheme" }) -- user command API is stable [web:18]

  api.nvim_create_user_command("MatugenReload", function()
    if M.reload() then
      vim.notify("Matugen: reloaded", vim.log.levels.INFO)
    end
  end, { desc = "Reload Matugen colorscheme" })

  api.nvim_create_user_command("MatugenDebug", function()
    cfg.debug = not cfg.debug
    vim.notify("Matugen: debug " .. (cfg.debug and "on" or "off"), vim.log.levels.INFO)
  end, { desc = "Toggle Matugen debug mode" })

  api.nvim_create_user_command("MatugenStatus", function()
    local path = cfg.file
    local st = uv and uv.fs_stat and uv.fs_stat(path) or nil
    print("Matugen Status:")
    print("  Color file: " .. path)
    print("  Exists: " .. tostring(st ~= nil or fn.filereadable(path) == 1))
    print("  Cached: " .. tostring(colors_cache ~= nil))
    print("  mtime: " .. tostring(colors_mtime))
    print("  Debug: " .. tostring(cfg.debug))
    print("  Watch: " .. tostring(cfg.watch))
    print("  Enabled modules:")
    for k, v in pairs(cfg.plugins) do
      if v then
        print("    - " .. k)
      end
    end
  end, { desc = "Show Matugen status" })

  api.nvim_create_user_command("MatugenWatchToggle", function()
    cfg.watch = not cfg.watch
    if cfg.watch then
      start_watch()
    else
      stop_watch()
    end
    vim.notify("Matugen: watch " .. (cfg.watch and "on" or "off"), vim.log.levels.INFO)
  end, { desc = "Toggle Matugen file watcher" })
end

-- Public: setup
function M.setup(opts)
  -- Shallow validation to catch common mistakes early.
  opts = opts or {}
  if type(opts.watch_interval_ms) == "number" and opts.watch_interval_ms < 10 then
    opts.watch_interval_ms = 100
  end
  local merged = vim.tbl_deep_extend("force", DEFAULT, opts)
  merged.file = fn.expand(merged.file)
  cfg = merged

  colors_cache, colors_mtime = nil, nil
  ensure_commands()

  if cfg.watch then
    start_watch()
  end
  if cfg.auto_apply then
    return M.apply()
  end
  return true
end

-- Utilities
function M.clear_cache()
  colors_cache, colors_mtime = nil, nil
  log("cache cleared")
end

function M.get_config()
  return vim.deepcopy(cfg)
end

function M.get_colors()
  return colors_cache and vim.deepcopy(colors_cache) or nil
end

function M.teardown()
  stop_watch()
  -- Note: user commands are intentionally kept until session ends.
end

return M
