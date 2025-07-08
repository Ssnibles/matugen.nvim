local M = {}

--- Applies Nvim-Cmp (and potential blink.cmp) specific highlight groups.
---@param set_hl function Helper to set highlight groups.
---@param set_hl_link function Helper to set highlight links.
---@param colors table The table of color values (hex strings).
---@param config table The plugin configuration.
function M.apply(set_hl, set_hl_link, colors, config)
  local bg_float = config.transparent_background and "NONE" or (colors.surface_container_low or colors.surface)
  local bg_pmenu = config.transparent_background and "NONE" or (colors.surface_container or colors.surface)

  -- Cmp (Completion)
  set_hl("CmpBorder", colors.outline_variant, bg_float)
  set_hl("CmpMenu", colors.on_surface, bg_float)
  set_hl("CmpItemKind", colors.outline) -- Default kind color
  set_hl("CmpItemKindText", colors.on_surface)
  set_hl("CmpItemKindMethod", colors.primary)
  set_hl("CmpItemKindFunction", colors.primary)
  set_hl("CmpItemKindConstructor", colors.primary)
  set_hl("CmpItemKindField", colors.primary_container)
  set_hl("CmpItemKindVariable", colors.on_background)
  set_hl("CmpItemKindClass", colors.secondary_fixed or colors.secondary)
  set_hl("CmpItemKindInterface", colors.secondary_fixed or colors.secondary)
  set_hl("CmpItemKindModule", colors.secondary)
  set_hl("CmpItemKindProperty", colors.primary_container)
  set_hl("CmpItemKindUnit", colors.tertiary)
  set_hl("CmpItemKindValue", colors.tertiary)
  set_hl("CmpItemKindEnum", colors.secondary_fixed or colors.secondary)
  set_hl("CmpItemKindKeyword", colors.primary)
  set_hl("CmpItemKindSnippet", colors.tertiary_container)
  set_hl("CmpItemKindColor", colors.tertiary)
  set_hl("CmpItemKindFile", colors.primary_container)
  set_hl("CmpItemKindReference", colors.primary)
  set_hl("CmpItemKindFolder", colors.secondary)
  set_hl("CmpItemKindEnumMember", colors.tertiary)
  set_hl("CmpItemKindConstant", colors.tertiary)
  set_hl("CmpItemKindStruct", colors.secondary_fixed or colors.secondary)
  set_hl("CmpItemKindEvent", colors.tertiary_fixed or colors.tertiary)
  set_hl("CmpItemKindOperator", colors.outline)
  set_hl("CmpItemKindTypeParameter", colors.secondary_fixed or colors.secondary)
  set_hl("CmpItemAbbr", colors.on_surface)
  set_hl("CmpItemAbbrDeprecated", colors.outline_variant, nil, "strikethrough")
  set_hl("CmpItemAbbrMatch", colors.primary, nil, "bold")
  set_hl("CmpItemAbbrMatchFuzzy", colors.primary, nil, "underline")
  set_hl("CmpItemMenu", colors.outline_variant)
  set_hl("CmpItemSel", colors.on_primary, colors.primary)
  set_hl("CmpDocBorder", colors.outline_variant, bg_pmenu)
  set_hl("CmpDoc", colors.on_surface, bg_pmenu)

  -- Specific blink.cmp highlights (if any, these are examples/placeholders)
  -- If blink.cmp introduces unique highlight groups for its "blinking" effect
  -- or other visual cues, you would define them here.
  -- Example:
  -- set_hl("BlinkCmpActive", colors.tertiary, nil, "reverse")
  -- set_hl("BlinkCmpCursor", colors.primary, nil, "underline")
end

return M
