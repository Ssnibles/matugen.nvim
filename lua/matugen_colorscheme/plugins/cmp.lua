-- lua/matugen_colorscheme/plugins/cmp.lua
-- This file defines highlight groups specifically for Nvim-cmp.

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

  -- Cmp (Completion) - aiming for consistency in kind colors
  set_hl("CmpBorder", colors.outline_variant, bg_float)
  set_hl("CmpMenu", colors.on_surface, bg_float)
  set_hl("CmpItemKind", ui_normal_fg) -- Default kind color
  set_hl("CmpItemKindText", colors.on_surface)
  set_hl("CmpItemKindMethod", colors.primary_fixed)
  set_hl("CmpItemKindFunction", colors.primary_fixed)
  set_hl("CmpItemKindConstructor", colors.primary_fixed)
  set_hl("CmpItemKindField", colors.tertiary_fixed)
  set_hl("CmpItemKindVariable", colors.on_surface)
  set_hl("CmpItemKindClass", colors.secondary_fixed)
  set_hl("CmpItemKindInterface", colors.secondary_fixed)
  set_hl("CmpItemKindModule", colors.secondary)
  set_hl("CmpItemKindProperty", colors.tertiary_fixed)
  set_hl("CmpItemKindUnit", colors.tertiary_fixed_dim)
  set_hl("CmpItemKindValue", colors.tertiary_fixed_dim)
  set_hl("CmpItemKindEnum", colors.secondary_fixed)
  set_hl("CmpItemKindKeyword", colors.primary)
  set_hl("CmpItemKindSnippet", colors.tertiary_container)
  set_hl("CmpItemKindColor", colors.tertiary)
  set_hl("CmpItemKindFile", colors.primary_container)
  set_hl("CmpItemKindReference", colors.primary)
  set_hl("CmpItemKindFolder", colors.secondary)
  set_hl("CmpItemKindEnumMember", colors.tertiary_fixed_dim)
  set_hl("CmpItemKindConstant", colors.tertiary_fixed_dim)
  set_hl("CmpItemKindStruct", colors.secondary_fixed)
  set_hl("CmpItemKindEvent", colors.tertiary_fixed_dim)
  set_hl("CmpItemKindOperator", colors.outline)
  set_hl("CmpItemKindTypeParameter", colors.secondary_fixed)
  set_hl("CmpItemAbbr", colors.on_surface)
  set_hl("CmpItemAbbrDeprecated", colors.outline_variant, nil, "strikethrough")
  set_hl("CmpItemAbbrMatch", colors.primary, nil, "bold")
  set_hl("CmpItemAbbrMatchFuzzy", colors.primary, nil, "underline")
  set_hl("CmpItemMenu", colors.outline_variant)
  set_hl("CmpItemSel", colors.on_primary, colors.primary)
  set_hl("CmpDocBorder", colors.outline_variant, bg_pmenu)
  set_hl("CmpDoc", colors.on_surface, bg_pmenu)
end

return M
