local M = {}

--- Applies NvimTree-specific highlight groups.
---@param set_hl function Helper to set highlight groups.
---@param set_hl_link function Helper to set highlight links.
---@param colors table The table of color values (hex strings).
---@param config table The plugin configuration.
function M.apply(set_hl, set_hl_link, colors, config)
  set_hl("NvimTreeRoot", colors.primary, nil, "bold")
  set_hl("NvimTreeFolderIcon", colors.secondary)
  set_hl("NvimTreeGitDirty", colors.primary_container)
  set_hl("NvimTreeGitNew", colors.tertiary_container)
  set_hl("NvimTreeIndentMarker", colors.outline_variant)
  set_hl("NvimTreeSymlink", colors.tertiary)
end

return M
