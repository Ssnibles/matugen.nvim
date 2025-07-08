local M = {}

--- Applies Bufferline/Barbar-specific highlight groups.
---@param set_hl function Helper to set highlight groups.
---@param set_hl_link function Helper to set highlight links.
---@param colors table The table of color values (hex strings).
---@param config table The plugin configuration.
function M.apply(set_hl, set_hl_link, colors, config)
  local bg_tabline = config.transparent_background and "NONE" or (colors.surface_container_lowest or colors.surface)
  local bg_float = config.transparent_background and "NONE" or (colors.surface_container_low or colors.surface)
  local bg_pmenu = config.transparent_background and "NONE" or (colors.surface_container or colors.surface)

  set_hl("BufferLineFill", bg_tabline)
  set_hl(
    "BufferLineBuffer",
    colors.on_surface_variant or colors.on_surface,
    bg_float -- Use float background for inactive buffers
  )
  set_hl("BufferLineBufferSelected", colors.on_primary, colors.primary, "bold")
  set_hl("BufferLineTabSeparator", colors.background, bg_tabline)
  set_hl("BufferLineBufferVisible", colors.on_surface, bg_pmenu) -- Use pmenu background for visible but not selected
end

return M
