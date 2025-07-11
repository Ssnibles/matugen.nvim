-- lua/matugen_colorscheme/plugins/blink-cmp.lua
-- This file defines highlight groups specifically for blink.cmp

local M = {}

--- Setup function for Nvim-cmp highlights.
--- @param colors table The table of Matugen color values.
--- @param set_hl function Helper to set highlight groups.
--- @param set_hl_link function Helper to link highlight groups.
--- @param config table The main plugin configuration.
function M.setup(colors, set_hl, set_hl_link, config)
  local bg_float = config.transparent_background and "NONE" or (colors.surface_container_low or colors.surface)
  local bg_pmenu = config.transparent_background and "NONE" or (colors.surface_container or colors.surface)
  local ui_normal_fg = colors.outline or colors.on_surface_variant -- For subtle UI elements

  set_hl()
end

return M
