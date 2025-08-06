local M = {}

-- Style combinations for consistency
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  underline = { "underline" },
  bold_italic = { "bold", "italic" },
  underline_italic = { "underline", "italic" },
  strikethrough = { "strikethrough" },
  none = {},
}

--- Apply Treesitter highlights with Material You design principles
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Clean semantic color mapping with proper Material You hierarchy
  local c = {
    -- Text hierarchy
    text = colors.on_surface,
    text_variant = colors.on_surface_variant,

    -- Primary syntax elements
    primary = colors.primary,
    primary_container = colors.on_primary_container,

    -- Secondary syntax elements
    secondary = colors.secondary,
    secondary_container = colors.on_secondary_container,

    -- Tertiary syntax elements
    tertiary = colors.tertiary,
    tertiary_container = colors.on_tertiary_container,

    -- Error system
    error = colors.error,
    error_container = colors.on_error_container,

    -- Outline system for subtle elements
    outline = colors.outline,
    outline_variant = colors.outline_variant,

    -- Background colors
    surface_low = colors.surface_container_low,
    surface_high = colors.surface_container_high,
  }

  local highlights = {
    -- === COMMENTS (Back to dimmer outline_variant) ===
    ["@comment"] = { fg = c.outline_variant, style = STYLES.italic },
    ["@comment.documentation"] = { fg = c.outline_variant, style = STYLES.italic },
    ["@comment.todo"] = { fg = c.primary_container, bg = colors.primary_container, style = STYLES.bold_italic },
    ["@comment.note"] = { fg = c.secondary, style = STYLES.bold_italic },
    ["@comment.warning"] = { fg = c.tertiary, style = STYLES.bold_italic },
    ["@comment.error"] = { fg = c.error, style = STYLES.bold_italic },

    -- === KEYWORDS ===
    ["@keyword"] = { fg = c.primary, style = STYLES.bold },
    ["@keyword.return"] = { fg = c.primary, style = STYLES.bold_italic },
    ["@keyword.function"] = { fg = c.primary, style = STYLES.bold },
    ["@keyword.operator"] = { fg = c.primary },
    ["@keyword.import"] = { fg = c.primary, style = STYLES.italic },
    ["@keyword.storage"] = { fg = c.primary },
    ["@keyword.repeat"] = { fg = c.primary, style = STYLES.bold },
    ["@keyword.conditional"] = { fg = c.primary, style = STYLES.bold },
    ["@keyword.exception"] = { fg = c.error, style = STYLES.bold },

    -- === FUNCTIONS ===
    ["@function"] = { fg = c.secondary, style = STYLES.bold },
    ["@function.call"] = { fg = c.secondary },
    ["@function.builtin"] = { fg = c.secondary_container, style = STYLES.bold_italic },
    ["@function.macro"] = { fg = c.secondary, style = STYLES.italic },
    ["@method"] = { fg = c.secondary, style = STYLES.bold },
    ["@method.call"] = { fg = c.secondary },
    ["@constructor"] = { fg = c.tertiary, style = STYLES.bold },

    -- === TYPES AND CLASSES ===
    ["@type"] = { fg = c.tertiary, style = STYLES.bold },
    ["@type.builtin"] = { fg = c.tertiary_container, style = STYLES.bold },
    ["@type.definition"] = { fg = c.tertiary, style = STYLES.bold_italic },
    ["@class"] = { fg = c.tertiary, style = STYLES.bold },
    ["@interface"] = { fg = c.tertiary, style = STYLES.italic },
    ["@namespace"] = { fg = c.tertiary },
    ["@module"] = { fg = c.tertiary },

    -- === VARIABLES ===
    ["@variable"] = { fg = c.text },
    ["@variable.builtin"] = { fg = c.primary_container, style = STYLES.italic },
    ["@variable.parameter"] = { fg = c.text_variant, style = STYLES.italic },
    ["@variable.member"] = { fg = c.text },
    ["@property"] = { fg = c.text },
    ["@field"] = { fg = c.text },
    ["@attribute"] = { fg = c.secondary, style = STYLES.italic },

    -- === CONSTANTS AND LITERALS ===
    ["@constant"] = { fg = c.primary, style = STYLES.bold },
    ["@constant.builtin"] = { fg = c.primary_container, style = STYLES.bold_italic },
    ["@constant.macro"] = { fg = c.primary, style = STYLES.italic },
    ["@number"] = { fg = c.primary, style = STYLES.bold },
    ["@number.float"] = { fg = c.primary, style = STYLES.bold },
    ["@boolean"] = { fg = c.primary, style = STYLES.bold },

    -- === STRINGS ===
    ["@string"] = { fg = c.tertiary },
    ["@string.documentation"] = { fg = c.tertiary, style = STYLES.italic },
    ["@string.regex"] = { fg = c.secondary, style = STYLES.bold },
    ["@string.escape"] = { fg = c.secondary, style = STYLES.bold },
    ["@string.special"] = { fg = c.secondary },
    ["@string.special.symbol"] = { fg = c.primary },
    ["@string.special.url"] = { fg = c.secondary, style = STYLES.underline },
    ["@character"] = { fg = c.tertiary },
    ["@character.special"] = { fg = c.secondary, style = STYLES.bold },

    -- === OPERATORS AND PUNCTUATION ===
    ["@operator"] = { fg = c.text_variant },
    ["@punctuation.delimiter"] = { fg = c.outline },
    ["@punctuation.bracket"] = { fg = c.outline },
    ["@punctuation.special"] = { fg = c.text_variant, style = STYLES.bold },

    -- === MARKUP ===
    ["@markup.heading"] = { fg = c.primary, style = STYLES.bold },
    ["@markup.heading.1"] = { fg = c.primary, style = STYLES.bold },
    ["@markup.heading.2"] = { fg = c.secondary, style = STYLES.bold },
    ["@markup.heading.3"] = { fg = c.tertiary, style = STYLES.bold },
    ["@markup.heading.4"] = { fg = c.primary, style = STYLES.bold },
    ["@markup.heading.5"] = { fg = c.secondary, style = STYLES.bold },
    ["@markup.heading.6"] = { fg = c.tertiary, style = STYLES.bold },

    ["@markup.list"] = { fg = c.text_variant },
    ["@markup.list.checked"] = { fg = c.secondary },
    ["@markup.list.unchecked"] = { fg = c.outline },

    ["@markup.emphasis"] = { fg = c.text, style = STYLES.italic },
    ["@markup.strong"] = { fg = c.text, style = STYLES.bold },
    ["@markup.strikethrough"] = { fg = c.outline, style = STYLES.strikethrough },

    ["@markup.code"] = { fg = c.tertiary, bg = c.surface_low },
    ["@markup.code.block"] = { fg = c.text, bg = c.surface_low },

    ["@markup.link"] = { fg = c.secondary },
    ["@markup.link.label"] = { fg = c.secondary, style = STYLES.underline },
    ["@markup.link.url"] = { fg = c.secondary, style = STYLES.underline_italic },

    ["@markup.quote"] = { fg = c.text_variant, style = STYLES.italic },
    ["@markup.math"] = { fg = c.primary },

    ["@markup.environment"] = { fg = c.tertiary },
    ["@markup.environment.name"] = { fg = c.secondary },

    ["@markup.raw"] = { fg = c.tertiary },
    ["@markup.raw.block"] = { fg = c.text, bg = c.surface_low },

    -- === TAGS ===
    ["@tag"] = { fg = c.primary, style = STYLES.bold },
    ["@tag.builtin"] = { fg = c.primary_container, style = STYLES.bold },
    ["@tag.attribute"] = { fg = c.secondary },
    ["@tag.delimiter"] = { fg = c.outline },

    -- === DIFF ===
    ["@diff.plus"] = { fg = c.secondary },
    ["@diff.minus"] = { fg = c.error },
    ["@diff.delta"] = { fg = c.primary },

    -- === SPECIAL ELEMENTS (Fixed spell handling) ===
    ["@none"] = {},
    ["@conceal"] = { fg = c.outline_variant },
    -- Remove problematic spell highlight that might cause underlines
    ["@spell"] = {},
    ["@nospell"] = {},
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end

  -- === LSP SEMANTIC TOKENS (using links for consistency) ===
  local lsp_semantic = {
    ["@lsp.type.class"] = { link = "@type" },
    ["@lsp.type.comment"] = { link = "@comment" },
    ["@lsp.type.decorator"] = { link = "@attribute" },
    ["@lsp.type.enum"] = { link = "@type" },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.type.function"] = { link = "@function" },
    ["@lsp.type.interface"] = { link = "@interface" },
    ["@lsp.type.keyword"] = { link = "@keyword" },
    ["@lsp.type.macro"] = { link = "@function.macro" },
    ["@lsp.type.method"] = { link = "@method" },
    ["@lsp.type.namespace"] = { link = "@namespace" },
    ["@lsp.type.parameter"] = { link = "@variable.parameter" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.string"] = { link = "@string" },
    ["@lsp.type.struct"] = { link = "@type" },
    ["@lsp.type.type"] = { link = "@type" },
    ["@lsp.type.typeParameter"] = { link = "@type" },
    ["@lsp.type.variable"] = { link = "@variable" },

    -- Modifiers
    ["@lsp.mod.deprecated"] = { style = STYLES.strikethrough },
    ["@lsp.mod.readonly"] = { style = STYLES.italic },
    ["@lsp.mod.static"] = { style = STYLES.bold },
  }

  -- Apply LSP semantic token links
  for group, opts in pairs(lsp_semantic) do
    set_hl(group, opts)
  end
end

return M
