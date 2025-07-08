local M = {}

--- Applies Gitsigns-specific highlight groups.
---@param set_hl function Helper to set highlight groups.
---@param set_hl_link function Helper to set highlight links.
---@param colors table The table of color values (hex strings).
---@param config table The plugin configuration.
function M.apply(set_hl, set_hl_link, colors, config)
  set_hl("GitSignsAdd", colors.tertiary, nil, "bold")
  set_hl("GitSignsChange", colors.primary, nil, "bold")
  set_hl("GitSignsDelete", colors.error, nil, "bold")
  set_hl("GitSignsChangeDelete", colors.error, nil, "bold")
end

return M
