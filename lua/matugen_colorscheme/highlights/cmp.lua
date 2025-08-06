local M = {}

-- Predefined style combinations
local styles = {
  bold = { "bold" },
  strikethrough = { "strikethrough" },
  italic = { "italic" },
}

--- Applies cmp highlight groups
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Semantic color aliases
  local C = {
    text = colors.on_surface,
    muted = colors.outline,
    highlight = colors.primary,
    secondary = colors.secondary,
    tertiary = colors.tertiary,
    accent = colors.primary_fixed,
    error = colors.error,
    success = colors.tertiary_fixed,
    border = colors.outline,
  }

  -- Highlight definitions
  local highlights = {
    -- Core completion items
    BlinkCompletionWindow = { bg = colors.surface_container_highest },
    BlinkCompletionItemNormal = { fg = C.text },
    BlinkCompletionItemKind = { fg = C.muted },
    BlinkCompletionItemMenu = { fg = colors.outline_variant },

    -- Matching and selection
    BlinkCompletionItemMatch = { fg = C.highlight, style = styles.bold },
    BlinkCompletionItemMatchFuzzy = { fg = colors.primary_fixed_dim, style = styles.bold },
    BlinkCompletionItemDeprecated = { fg = colors.outline_variant, style = styles.strikethrough },
    BlinkCompletionItemSelected = {
      fg = colors.on_primary_container,
      bg = colors.primary_container,
      style = styles.bold,
    },

    -- Documentation window
    BlinkCompletionDocumentation = { bg = colors.surface_container_high },
    BlinkCompletionDocumentationBorder = { fg = C.border },

    -- Item kinds
    BlinkCompletionItemKindVariable = { fg = C.highlight },
    BlinkCompletionItemKindFunction = { fg = C.secondary },
    BlinkCompletionItemKindMethod = { fg = C.secondary },
    BlinkCompletionItemKindField = { fg = C.accent },
    BlinkCompletionItemKindEnum = { fg = C.tertiary },
    BlinkCompletionItemKindKeyword = { fg = C.highlight },
    BlinkCompletionItemKindText = { fg = C.text },
    BlinkCompletionItemKindClass = { fg = colors.tertiary_fixed },
    BlinkCompletionItemKindModule = { fg = C.tertiary },
    BlinkCompletionItemKindInterface = { fg = colors.tertiary_fixed_dim },
    BlinkCompletionItemKindStruct = { fg = C.tertiary },
    BlinkCompletionItemKindConstant = { fg = colors.primary_fixed_dim },
    BlinkCompletionItemKindNumber = { fg = C.accent },
    BlinkCompletionItemKindBoolean = { fg = C.highlight },
    BlinkCompletionItemKindString = { fg = C.success },
    BlinkCompletionItemKindSnippet = { fg = colors.secondary_fixed },
    BlinkCompletionItemKindColor = { fg = colors.outline_variant },
    BlinkCompletionItemKindFile = { fg = C.secondary },
    BlinkCompletionItemKindFolder = { fg = C.secondary },
    BlinkCompletionItemKindProperty = { fg = C.accent },
    BlinkCompletionItemKindUnit = { fg = colors.tertiary_fixed },
    BlinkCompletionItemKindValue = { fg = C.accent },
    BlinkCompletionItemKindEvent = { fg = colors.secondary_fixed },
    BlinkCompletionItemKindOperator = { fg = C.tertiary },
    BlinkCompletionItemKindTypeParameter = { fg = C.tertiary },

    -- Status indicators
    BlinkCompletionStatusNormal = { fg = C.muted },
    BlinkCompletionStatusSelected = { fg = colors.on_primary_container },
    BlinkCompletionStatusError = { fg = C.error },

    -- Ghost text
    BlinkCompletionGhostText = { fg = colors.on_surface_variant, style = styles.italic },

    -- Borders
    BlinkCompletionBorder = { fg = C.border },

    -- Search highlights
    BlinkCompletionSearchMatch = {
      fg = C.highlight,
      bg = colors.primary_container,
      style = styles.bold,
    },
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
