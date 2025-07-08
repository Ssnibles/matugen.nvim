local M = {}

--- Applies LspSaga-specific highlight groups.
---@param set_hl function Helper to set highlight groups.
---@param set_hl_link function Helper to set highlight links.
---@param colors table The table of color values (hex strings).
---@param config table The plugin configuration.
function M.apply(set_hl, set_hl_link, colors, config)
  set_hl("LspSagaBorderTitle", colors.primary)
  set_hl("LspSagaBorder", colors.outline)
  set_hl("LspSagaError", colors.error)
  set_hl("LspSagaWarning", colors.primary)
  set_hl("LspSagaInfo", colors.secondary)
  set_hl("LspSagaHint", colors.tertiary)
  set_hl("LspSagaDef", colors.primary)
  set_hl("LspSagaTypeDefinition", colors.secondary)
  set_hl("LspSagaDiagSource", colors.outline_variant)
  set_hl("LspSagaCodeActionTitle", colors.primary)
  set_hl("LspSagaCodeActionSelected", colors.on_primary, colors.primary)
end

return M
