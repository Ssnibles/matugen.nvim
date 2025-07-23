-- ~/projects/matugen.nvim/lua/matugen_colorscheme/highlights/cmp.lua

local M = {}

--- Applies nvim-cmp specific highlight groups.
--- @param colors table The table of colors parsed from Matugen.
--- @param config table The plugin's configuration table.
--- @param set_hl function Helper function to set highlight groups.
function M.apply(colors, config, set_hl)
  set_hl("CmpItemAbbr", colors.on_surface, nil)
  set_hl("CmpItemKind", colors.outline, nil)
  set_hl("CmpItemMenu", colors.outline_variant, nil)

  set_hl("CmpItemAbbrDeprecated", colors.outline_variant, nil, "strikethrough")
  set_hl("CmpItemAbbrMatch", colors.primary, nil, "bold")
  set_hl("CmpItemAbbrMatchFuzzy", colors.primary, nil, "bold")

  set_hl("CmpItemKindVariable", colors.primary, nil)
  set_hl("CmpItemKindFunction", colors.secondary, nil)
  set_hl("CmpItemKindMethod", colors.secondary, nil)
  set_hl("CmpItemKindField", colors.primary_fixed, nil)
  set_hl("CmpItemKindEnum", colors.tertiary, nil)
  set_hl("CmpItemKindKeyword", colors.primary, nil)
  set_hl("CmpItemKindText", colors.on_surface, nil)
  set_hl("CmpItemKindClass", colors.tertiary_fixed, nil)
  set_hl("CmpItemKindModule", colors.tertiary, nil)
  set_hl("CmpItemKindInterface", colors.tertiary, nil)
  set_hl("CmpItemKindStruct", colors.tertiary, nil)
  set_hl("CmpItemKindConstant", colors.primary_fixed_dim, nil)
  set_hl("CmpItemKindNumber", colors.tertiary_fixed_dim, nil)
  set_hl("CmpItemKindBoolean", colors.primary_fixed_dim, nil)
  set_hl("CmpItemKindString", colors.secondary_fixed, nil)
  set_hl("CmpItemKindSnippet", colors.on_primary, nil)
  set_hl("CmpItemKindColor", colors.outline_variant, nil)
  set_hl("CmpItemKindFile", colors.secondary, nil)
  set_hl("CmpItemKindFolder", colors.secondary, nil)
end

return M
