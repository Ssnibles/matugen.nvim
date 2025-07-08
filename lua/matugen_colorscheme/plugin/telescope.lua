local M = {}

--- Applies Telescope-specific highlight groups.
---@param set_hl function Helper to set highlight groups.
---@param set_hl_link function Helper to set highlight links.
---@param colors table The table of color values (hex strings).
---@param config table The plugin configuration.
function M.apply(set_hl, set_hl_link, colors, config)
  local bg_float = config.transparent_background and "NONE" or (colors.surface_container_low or colors.surface)
  local bg_statusline = config.transparent_background and "NONE" or (colors.surface_container_high or colors.surface)

  set_hl("TelescopeNormal", colors.on_surface, bg_float)
  set_hl("TelescopeBorder", colors.outline, bg_float)
  set_hl("TelescopePromptNormal", colors.on_surface, bg_statusline)
  set_hl("TelescopePromptBorder", colors.primary, bg_statusline)
  set_hl("TelescopePromptPrefix", colors.primary, bg_statusline, "bold")
  set_hl("TelescopeMatching", colors.primary, nil, "bold")
  set_hl("TelescopeSelection", colors.on_primary_container, colors.primary_container)
  set_hl_link("TelescopeResultsNormal", "NormalFloat")
  set_hl_link("TelescopeResultsSelection", "TelescopeSelection")
end

return M
