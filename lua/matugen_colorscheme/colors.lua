-- ~/projects/matugen.nvim/lua/matugen_colorscheme/colors.lua
-- Central palette loader: normalizes Matugen keys, derives usable variants, and auto-refreshes.

local M = {}

local api = vim.api
local U = require("matugen_colorscheme.utils")
local core = require("matugen_colorscheme") -- provides get_colors()

-- Caches
local raw_cache ---@type table|nil
local std_cache ---@type table|nil

-- Fallbacks (dark-leaning defaults if Matugen missing)
local FALLBACK = {
  background = "#0F1419",
  surface = "#0F1419",
  on_surface = "#E6EDF0",
  on_surface_variant = "#BDC7CC",
  outline = "#87949A",
  outline_variant = "#3F4B50",
  primary = "#FFB84D",
  secondary = "#D4BBFF",
  tertiary = "#5FB8C9",
  error = "#FFB4AB",
  primary_container = "#5D3C00",
  on_primary_container = "#FFDEAB",
  secondary_container = "#4A4766",
  on_secondary_container = "#E4E0FF",
  tertiary_container = "#00525F",
  on_tertiary_container = "#B0F0FF",
  surface_container_low = "#161B20",
  surface_container = "#1D2328",
  surface_container_high = "#242A30",
  surface_container_highest = "#2B3238",
}

-- Resolve first present key or fallback
local function pick(t, keys, fb)
  for _, k in ipairs(keys) do
    local v = t[k]
    if type(v) == "string" and v ~= "" then
      return v
    end
  end
  return fb
end

-- Normalize Matugen (and friends) into a stable schema
local function normalize(raw)
  local c = setmetatable({}, { __index = FALLBACK })

  -- Base and surfaces
  c.bg = pick(raw, { "background", "surface" }, FALLBACK.background)
  c.fg = pick(raw, { "on_surface" }, FALLBACK.on_surface)
  c.fg_muted = pick(raw, { "on_surface_variant", "outline" }, FALLBACK.on_surface_variant)

  c.surface_base = pick(raw, { "surface", "background" }, FALLBACK.surface)
  c.surface_low = pick(raw, { "surface_container_low", "surface_dim" }, FALLBACK.surface_container_low)
  c.surface_default = pick(raw, { "surface_container" }, FALLBACK.surface_container)
  c.surface_high = pick(raw, { "surface_container_high" }, FALLBACK.surface_container_high)
  c.surface_highest = pick(raw, { "surface_container_highest" }, FALLBACK.surface_container_highest)

  -- Outline/borders
  c.border = pick(raw, { "outline" }, FALLBACK.outline)
  c.border_muted = pick(raw, { "outline_variant", "on_surface_variant" }, FALLBACK.outline_variant)

  -- Palettes
  c.primary = pick(raw, { "primary" }, FALLBACK.primary)
  c.secondary = pick(raw, { "secondary" }, FALLBACK.secondary)
  c.tertiary = pick(raw, { "tertiary" }, FALLBACK.tertiary)
  c.error = pick(raw, { "error" }, FALLBACK.error)

  -- Containers
  c.primary_container = pick(raw, { "primary_container" }, FALLBACK.primary_container)
  c.on_primary_container = pick(raw, { "on_primary_container" }, FALLBACK.on_primary_container)
  c.secondary_container = pick(raw, { "secondary_container" }, FALLBACK.secondary_container)
  c.on_secondary_container = pick(raw, { "on_secondary_container" }, FALLBACK.on_secondary_container)
  c.tertiary_container = pick(raw, { "tertiary_container" }, FALLBACK.tertiary_container)
  c.on_tertiary_container = pick(raw, { "on_tertiary_container" }, FALLBACK.on_tertiary_container)

  -- Derived UI variants (consistent across modules)
  local bg_lum = U.get_luminance(c.bg)
  c.selection_bg = (bg_lum < 0.5) and U.brighten_hex(c.bg, 10) or U.brighten_hex(c.bg, -10)
  c.selection_fg = U.ensure_contrast(pick(raw, { "on_primary_container", "on_surface" }, c.fg), c.selection_bg, 5.5)

  c.menu_bg = c.surface_high
  c.menu_fg = U.ensure_contrast(c.fg, c.menu_bg, 7.0)
  c.menu_muted = U.ensure_contrast(c.fg_muted, c.menu_bg, 4.5)

  c.doc_bg = c.surface_highest
  c.doc_border = U.ensure_contrast(U.brighten_hex(c.border, 16), c.doc_bg, 4.5)

  -- Accents for matches/status
  c.match_fg = U.ensure_contrast(c.primary, c.menu_bg, 5.0)
  c.key_fg = U.ensure_contrast(c.tertiary, c.menu_bg, 5.0)
  c.count_fg = U.ensure_contrast(c.error, c.menu_bg, 5.0)

  return c
end

local function refresh()
  raw_cache = core.get_colors() or raw_cache or {}
  std_cache = normalize(raw_cache)
  return std_cache
end

--- Setup auto-refresh on ColorScheme and return the current palette.
--- Call once from the main plugin, or lazy-require and call when needed.
function M.setup()
  if not std_cache then
    refresh()
  end
  local group = api.nvim_create_augroup("MatugenColorsCentral", { clear = true })
  api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      refresh()
    end,
    desc = "Refresh centralized Matugen colors on colorscheme change",
  })
  return vim.deepcopy(std_cache)
end

--- Get the current standardized palette (deepcopy to avoid mutation).
function M.get()
  if not std_cache then
    refresh()
  end
  return vim.deepcopy(std_cache)
end

--- Pick a single named color (nil if unknown).
---@param name string
function M.pick(name)
  if not std_cache then
    refresh()
  end
  return std_cache and std_cache[name] or nil
end

--- Force a refresh (e.g., after external palette writes).
function M.reload()
  return refresh()
end

return M
