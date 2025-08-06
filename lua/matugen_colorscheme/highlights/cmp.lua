local M = {}

-- Style combinations for reuse
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  strikethrough = { "strikethrough" },
  bold_italic = { "bold", "italic" },
}

--- Apply completion highlights for both nvim-cmp and blink.cmp
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Semantic color mapping
  local c = {
    -- Text colors
    text = colors.on_surface,
    muted = colors.outline_variant or colors.outline,

    -- Accent colors
    primary = colors.primary,
    secondary = colors.secondary,
    tertiary = colors.tertiary,

    -- Fixed colors with fallbacks
    primary_fixed = colors.primary_fixed or colors.primary,
    secondary_fixed = colors.secondary_fixed or colors.secondary,
    tertiary_fixed = colors.tertiary_fixed or colors.tertiary,

    -- Dimmed variants
    primary_dim = colors.primary_fixed_dim or colors.primary_container,
    secondary_dim = colors.secondary_fixed_dim or colors.secondary_container,
    tertiary_dim = colors.tertiary_fixed_dim or colors.tertiary_container,

    -- UI colors
    surface_high = colors.surface_container_highest or colors.surface,
    surface_mid = colors.surface_container_high or colors.surface,
    border = colors.outline,
    error = colors.error,
  }

  -- Completion item kinds with their colors
  local item_kinds = {
    { "Variable", c.primary },
    { "Function", c.secondary },
    { "Method", c.secondary },
    { "Field", c.primary_fixed },
    { "Property", c.primary_fixed },
    { "Enum", c.tertiary },
    { "Keyword", c.primary },
    { "Text", c.text },
    { "Class", c.tertiary_fixed },
    { "Interface", c.tertiary_dim },
    { "Module", c.tertiary },
    { "Struct", c.tertiary },
    { "Constant", c.primary_dim },
    { "Number", c.primary_fixed },
    { "Boolean", c.primary },
    { "String", c.tertiary_fixed },
    { "Snippet", c.secondary_fixed },
    { "Color", c.muted },
    { "File", c.secondary },
    { "Folder", c.secondary },
    { "Unit", c.tertiary_fixed },
    { "Value", c.primary_fixed },
    { "Event", c.secondary_fixed },
    { "Operator", c.tertiary },
    { "TypeParameter", c.tertiary },
  }

  -- Base completion highlights that work for both plugins
  local base_highlights = {
    -- Core UI
    text = c.text,
    muted = c.muted,
    selected_fg = colors.on_primary_container,
    selected_bg = colors.primary_container,
    match_fg = c.primary,
    match_bg = colors.primary_container,
    deprecated = c.muted,
    ghost_text = colors.on_surface_variant,

    -- Backgrounds
    menu_bg = c.surface_high,
    doc_bg = c.surface_mid,
    border_fg = c.border,
  }

  -- Generate highlights for both nvim-cmp and blink.cmp
  local all_highlights = {}

  -- Plugin prefixes to support both completion engines
  local plugins = {
    { prefix = "Cmp", name = "nvim-cmp" },
    { prefix = "BlinkCompletion", name = "blink.cmp" },
  }

  for _, plugin in ipairs(plugins) do
    local prefix = plugin.prefix

    -- Core completion window
    all_highlights[prefix .. (prefix == "Cmp" and "Pmenu" or "Window")] = {
      fg = base_highlights.text,
      bg = base_highlights.menu_bg,
    }

    -- Menu items
    if prefix == "Cmp" then
      all_highlights.CmpItemAbbrDefault = { fg = base_highlights.text }
      all_highlights.CmpItemKindDefault = { fg = base_highlights.muted }
      all_highlights.CmpItemMenuDefault = { fg = base_highlights.muted }
      all_highlights.CmpItemAbbrMatch = { fg = base_highlights.match_fg, style = STYLES.bold }
      all_highlights.CmpItemAbbrMatchFuzzy = { fg = c.primary_dim, style = STYLES.bold }
      all_highlights.CmpItemAbbrDeprecated = { fg = base_highlights.deprecated, style = STYLES.strikethrough }
    else
      all_highlights.BlinkCompletionItemNormal = { fg = base_highlights.text }
      all_highlights.BlinkCompletionItemKind = { fg = base_highlights.muted }
      all_highlights.BlinkCompletionItemMenu = { fg = base_highlights.muted }
      all_highlights.BlinkCompletionItemMatch = { fg = base_highlights.match_fg, style = STYLES.bold }
      all_highlights.BlinkCompletionItemMatchFuzzy = { fg = c.primary_dim, style = STYLES.bold }
      all_highlights.BlinkCompletionItemDeprecated = { fg = base_highlights.deprecated, style = STYLES.strikethrough }
    end

    -- Selected item
    local selected_group = prefix == "Cmp" and "CmpItemAbbrSelected" or "BlinkCompletionItemSelected"
    all_highlights[selected_group] = {
      fg = base_highlights.selected_fg,
      bg = base_highlights.selected_bg,
      style = STYLES.bold,
    }

    -- Documentation
    local doc_group = prefix == "Cmp" and "CmpDocumentation" or "BlinkCompletionDocumentation"
    local doc_border = prefix == "Cmp" and "CmpDocumentationBorder" or "BlinkCompletionDocumentationBorder"

    all_highlights[doc_group] = { bg = base_highlights.doc_bg }
    all_highlights[doc_border] = { fg = base_highlights.border_fg }

    -- Item kinds
    for _, kind in ipairs(item_kinds) do
      local kind_name, color = kind[1], kind[2]
      local group_name = prefix == "Cmp" and ("CmpItemKind" .. kind_name) or ("BlinkCompletionItemKind" .. kind_name)

      all_highlights[group_name] = { fg = color }
    end

    -- Additional blink.cmp specific highlights
    if prefix == "BlinkCompletion" then
      all_highlights.BlinkCompletionGhostText = { fg = base_highlights.ghost_text, style = STYLES.italic }
      all_highlights.BlinkCompletionBorder = { fg = base_highlights.border_fg }
      all_highlights.BlinkCompletionSearchMatch = {
        fg = base_highlights.match_fg,
        bg = base_highlights.match_bg,
        style = STYLES.bold,
      }

      -- Status indicators
      all_highlights.BlinkCompletionStatusNormal = { fg = base_highlights.muted }
      all_highlights.BlinkCompletionStatusSelected = { fg = base_highlights.selected_fg }
      all_highlights.BlinkCompletionStatusError = { fg = c.error }
    end
  end

  -- Additional nvim-cmp specific highlights
  all_highlights.CmpGhostText = { fg = base_highlights.ghost_text, style = STYLES.italic }
  all_highlights.CmpItemAbbr = { fg = base_highlights.text }
  all_highlights.CmpItemKind = { fg = base_highlights.muted }
  all_highlights.CmpItemMenu = { fg = base_highlights.muted }

  -- Apply all highlights
  for group, opts in pairs(all_highlights) do
    set_hl(group, opts)
  end
end

return M
