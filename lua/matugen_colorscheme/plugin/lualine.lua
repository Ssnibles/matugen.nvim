local M = {}

--- Applies Lualine-specific highlight groups.
---@param set_hl function Helper to set highlight groups.
---@param set_hl_link function Helper to set highlight links.
---@param colors table The table of color values (hex strings).
---@param config table The plugin configuration.
function M.apply(set_hl, set_hl_link, colors, config)
  -- Lualine sections
  set_hl("LualineA", colors.on_primary, colors.primary, "bold")
  set_hl("LualineB", colors.on_secondary_container, colors.secondary_container)
  set_hl("LualineC", colors.on_surface, colors.surface)
  set_hl("LualineX", colors.on_surface_variant, colors.surface_variant)
  set_hl("LualineY", colors.on_tertiary_container, colors.tertiary_container)
  set_hl("LualineZ", colors.on_primary, colors.primary, "bold")

  -- Lualine inactive sections
  set_hl("LualineInactiveA", colors.on_surface_variant, colors.surface_variant)
  set_hl("LualineInactiveB", colors.outline, colors.surface_container_low or colors.surface)
  set_hl("LualineInactiveC", colors.outline_variant, colors.background)
  set_hl("LualineInactiveX", colors.outline_variant, colors.background)
  set_hl("LualineInactiveY", colors.outline, colors.surface_container_low or colors.surface)
  set_hl("LualineInactiveZ", colors.on_surface_variant, colors.surface_variant)

  -- Lualine warnings/errors
  set_hl("LualineWarn", colors.on_primary_container, colors.primary_container)
  set_hl("LualineError", colors.on_error, colors.error_container)
  set_hl("LualineInfo", colors.on_secondary_container, colors.secondary_container)
end

return M
