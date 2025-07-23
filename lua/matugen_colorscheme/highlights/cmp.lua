local M = {}

--- Applies blink.cmp specific highlight groups
--- @param colors table The table of colors parsed from Matugen.
--- @param config table The plugin's configuration table.
--- @param set_hl function Helper function to set highlight groups.
function M.apply(colors, config, set_hl)
  -- Define style presets
  local styles = {
    bold = { "bold" },
    strikethrough = { "strikethrough" },
    italic = { "italic" },
  }

  -- Semantic color aliases
  local C = {
    text = colors.on_surface or "#DBE4E7",
    muted = colors.outline or "#839498",
    highlight = colors.primary or "#F5BD62",
    secondary = colors.secondary or "#C6C2EA",
    tertiary = colors.tertiary or "#8ED1DF",
    accent = colors.primary_fixed or "#FFDDAE",
    error = colors.error or "#FFB4AB",
    success = colors.tertiary_fixed or "#AAEDFC",
    border = colors.outline or "#839498",
  }

  -- Core completion items
  set_hl("BlinkCompletionWindow", { bg = colors.surface_container_highest or "#2D3638" })
  set_hl("BlinkCompletionItemNormal", { fg = C.text })
  set_hl("BlinkCompletionItemKind", { fg = C.muted })
  set_hl("BlinkCompletionItemMenu", { fg = colors.outline_variant or "#3A494D" })

  -- Matching and selection
  set_hl("BlinkCompletionItemMatch", {
    fg = C.highlight,
    style = styles.bold,
  })

  set_hl("BlinkCompletionItemMatchFuzzy", {
    fg = colors.primary_fixed_dim or "#F5BD62",
    style = styles.bold,
  })

  set_hl("BlinkCompletionItemDeprecated", {
    fg = colors.outline_variant or "#3A494D",
    style = styles.strikethrough,
  })

  set_hl("BlinkCompletionItemSelected", {
    fg = colors.on_primary_container or "#FFDDAE",
    bg = colors.primary_container or "#604100",
    style = styles.bold,
  })

  -- Documentation window
  set_hl("BlinkCompletionDocumentation", {
    bg = colors.surface_container_high or "#232B2D",
  })

  set_hl("BlinkCompletionDocumentationBorder", {
    fg = C.border,
  })

  -- Item kinds
  set_hl("BlinkCompletionItemKindVariable", { fg = C.highlight })
  set_hl("BlinkCompletionItemKindFunction", { fg = C.secondary })
  set_hl("BlinkCompletionItemKindMethod", { fg = C.secondary })
  set_hl("BlinkCompletionItemKindField", { fg = C.accent })
  set_hl("BlinkCompletionItemKindEnum", { fg = C.tertiary })
  set_hl("BlinkCompletionItemKindKeyword", { fg = C.highlight })
  set_hl("BlinkCompletionItemKindText", { fg = C.text })
  set_hl("BlinkCompletionItemKindClass", { fg = colors.tertiary_fixed or "#AAEDFC" })
  set_hl("BlinkCompletionItemKindModule", { fg = C.tertiary })
  set_hl("BlinkCompletionItemKindInterface", { fg = colors.tertiary_fixed_dim or "#8ED1DF" })
  set_hl("BlinkCompletionItemKindStruct", { fg = C.tertiary })
  set_hl("BlinkCompletionItemKindConstant", { fg = colors.primary_fixed_dim or "#F5BD62" })
  set_hl("BlinkCompletionItemKindNumber", { fg = C.accent })
  set_hl("BlinkCompletionItemKindBoolean", { fg = C.highlight })
  set_hl("BlinkCompletionItemKindString", { fg = C.success })
  set_hl("BlinkCompletionItemKindSnippet", { fg = colors.secondary_fixed or "#E3DFFF" })
  set_hl("BlinkCompletionItemKindColor", { fg = colors.outline_variant or "#3A494D" })
  set_hl("BlinkCompletionItemKindFile", { fg = C.secondary })
  set_hl("BlinkCompletionItemKindFolder", { fg = C.secondary })

  -- Additional blink.cmp items
  set_hl("BlinkCompletionItemKindProperty", { fg = C.accent })
  set_hl("BlinkCompletionItemKindUnit", { fg = colors.tertiary_fixed or "#AAEDFC" })
  set_hl("BlinkCompletionItemKindValue", { fg = C.accent })
  set_hl("BlinkCompletionItemKindEvent", { fg = colors.secondary_fixed or "#E3DFFF" })
  set_hl("BlinkCompletionItemKindOperator", { fg = C.tertiary })
  set_hl("BlinkCompletionItemKindTypeParameter", { fg = C.tertiary })

  -- Status indicators
  set_hl("BlinkCompletionStatusNormal", { fg = C.muted })
  set_hl("BlinkCompletionStatusSelected", { fg = colors.on_primary_container or "#FFDDAE" })
  set_hl("BlinkCompletionStatusError", { fg = C.error })

  -- Ghost text
  set_hl("BlinkCompletionGhostText", {
    fg = colors.on_surface_variant or "#B8C9CE",
    style = styles.italic,
  })

  -- Borders
  set_hl("BlinkCompletionBorder", { fg = C.border })

  -- Search highlights
  set_hl("BlinkCompletionSearchMatch", {
    fg = C.highlight,
    bg = colors.primary_container or "#604100",
    style = styles.bold,
  })
end

return M
