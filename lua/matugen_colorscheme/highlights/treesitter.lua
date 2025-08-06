local M = {}

-- Style combinations for consistency
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  underline = { "underline" },
  bold_italic = { "bold", "italic" },
  underline_italic = { "underline", "italic" },
  none = {},
}

--- Apply Treesitter highlights with improved contrast and harmony
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Semantic color mapping inspired by Rose Pine's approach
  local c = {
    -- Base text colors (hierarchy from most to least prominent)
    text = colors.on_surface, -- Main text
    subtle = colors.on_surface_variant, -- Less important text
    muted = colors.outline_variant, -- Least important text

    -- Syntax categories with distinct roles
    rose = colors.primary_fixed_dim, -- Keywords, control flow
    pine = colors.tertiary, -- Functions, methods
    foam = colors.secondary_fixed_dim, -- Types, classes
    gold = colors.primary, -- Constants, numbers

    -- String and literal colors
    string = colors.tertiary_fixed, -- String literals
    escape = colors.secondary, -- Escape sequences

    -- Special syntax elements
    builtin = colors.on_primary_container, -- Built-in functions/types
    operator = colors.on_surface_variant, -- Operators
    punctuation = colors.outline, -- Brackets, delimiters

    -- Comments and documentation
    comment = colors.outline_variant, -- Comments
    doc = colors.outline, -- Documentation

    -- Markup and special text
    heading = colors.primary_fixed_dim, -- Headings
    link = colors.tertiary_fixed_dim, -- Links
    emphasis = colors.secondary_fixed_dim, -- Emphasis

    -- Error and diagnostic colors
    error = colors.error,
    warning = colors.primary,
    info = colors.tertiary,
    hint = colors.secondary,

    -- Background colors for special elements
    code_bg = colors.surface_container_low,
    highlight_bg = colors.primary_container,
    error_bg = colors.error_container,
    warning_bg = colors.surface_container_high,
  }

  -- Core language constructs
  local highlights = {
    -- === COMMENTS AND DOCUMENTATION ===
    ["@comment"] = { fg = c.comment, style = STYLES.italic },
    ["@comment.documentation"] = { fg = c.doc, style = STYLES.italic },
    ["@comment.todo"] = { fg = colors.on_primary_container, bg = c.highlight_bg, style = STYLES.bold },
    ["@comment.note"] = { fg = c.info, style = STYLES.bold_italic },
    ["@comment.warning"] = { fg = c.warning, style = STYLES.bold_italic },
    ["@comment.error"] = { fg = c.error, style = STYLES.bold_italic },

    -- === KEYWORDS (Rose - Primary accent color) ===
    ["@keyword"] = { fg = c.rose, style = STYLES.bold },
    ["@keyword.return"] = { fg = c.rose, style = STYLES.bold_italic },
    ["@keyword.function"] = { fg = c.rose, style = STYLES.bold },
    ["@keyword.operator"] = { fg = c.rose },
    ["@keyword.import"] = { fg = c.rose, style = STYLES.italic },
    ["@keyword.storage"] = { fg = c.rose },
    ["@keyword.repeat"] = { fg = c.rose, style = STYLES.bold },
    ["@keyword.conditional"] = { fg = c.rose, style = STYLES.bold },
    ["@keyword.exception"] = { fg = c.error, style = STYLES.bold },

    -- === FUNCTIONS (Pine - Secondary accent) ===
    ["@function"] = { fg = c.pine, style = STYLES.bold },
    ["@function.call"] = { fg = c.pine },
    ["@function.builtin"] = { fg = c.builtin, style = STYLES.bold_italic },
    ["@function.macro"] = { fg = c.pine, style = STYLES.italic },
    ["@method"] = { fg = c.pine, style = STYLES.bold },
    ["@method.call"] = { fg = c.pine },
    ["@constructor"] = { fg = c.foam, style = STYLES.bold },

    -- === TYPES AND CLASSES (Foam - Tertiary accent) ===
    ["@type"] = { fg = c.foam, style = STYLES.bold },
    ["@type.builtin"] = { fg = c.builtin, style = STYLES.bold },
    ["@type.definition"] = { fg = c.foam, style = STYLES.bold_italic },
    ["@class"] = { fg = c.foam, style = STYLES.bold },
    ["@interface"] = { fg = c.foam, style = STYLES.italic },
    ["@namespace"] = { fg = c.foam },
    ["@module"] = { fg = c.foam },

    -- === VARIABLES AND IDENTIFIERS ===
    ["@variable"] = { fg = c.text },
    ["@variable.builtin"] = { fg = c.builtin, style = STYLES.italic },
    ["@variable.parameter"] = { fg = c.subtle, style = STYLES.italic },
    ["@variable.member"] = { fg = c.text },
    ["@property"] = { fg = c.emphasis },
    ["@field"] = { fg = c.emphasis },
    ["@attribute"] = { fg = c.gold, style = STYLES.italic },

    -- === CONSTANTS AND LITERALS (Gold) ===
    ["@constant"] = { fg = c.gold, style = STYLES.bold },
    ["@constant.builtin"] = { fg = c.builtin, style = STYLES.bold_italic },
    ["@constant.macro"] = { fg = c.gold, style = STYLES.italic },
    ["@number"] = { fg = c.gold, style = STYLES.bold },
    ["@number.float"] = { fg = c.gold, style = STYLES.bold },
    ["@boolean"] = { fg = c.gold, style = STYLES.bold },

    -- === STRINGS AND TEXT ===
    ["@string"] = { fg = c.string },
    ["@string.documentation"] = { fg = c.string, style = STYLES.italic },
    ["@string.regex"] = { fg = c.escape, style = STYLES.bold },
    ["@string.escape"] = { fg = c.escape, style = STYLES.bold },
    ["@string.special"] = { fg = c.escape },
    ["@string.special.symbol"] = { fg = c.gold },
    ["@string.special.url"] = { fg = c.link, style = STYLES.underline },
    ["@character"] = { fg = c.string },
    ["@character.special"] = { fg = c.escape, style = STYLES.bold },

    -- === OPERATORS AND PUNCTUATION ===
    ["@operator"] = { fg = c.operator },
    ["@punctuation.delimiter"] = { fg = c.punctuation },
    ["@punctuation.bracket"] = { fg = c.punctuation },
    ["@punctuation.special"] = { fg = c.operator, style = STYLES.bold },

    -- === MARKUP (for markdown, etc.) ===
    ["@markup.heading"] = { fg = c.heading, style = STYLES.bold },
    ["@markup.heading.1"] = { fg = c.rose, style = STYLES.bold },
    ["@markup.heading.2"] = { fg = c.pine, style = STYLES.bold },
    ["@markup.heading.3"] = { fg = c.foam, style = STYLES.bold },
    ["@markup.heading.4"] = { fg = c.gold, style = STYLES.bold },
    ["@markup.heading.5"] = { fg = c.emphasis, style = STYLES.bold },
    ["@markup.heading.6"] = { fg = c.subtle, style = STYLES.bold },

    ["@markup.list"] = { fg = c.operator },
    ["@markup.list.checked"] = { fg = c.pine },
    ["@markup.list.unchecked"] = { fg = c.subtle },

    ["@markup.emphasis"] = { fg = c.emphasis, style = STYLES.italic },
    ["@markup.strong"] = { fg = c.text, style = STYLES.bold },
    ["@markup.strikethrough"] = { fg = c.subtle, style = { "strikethrough" } },

    ["@markup.code"] = { fg = c.string, bg = c.code_bg },
    ["@markup.code.block"] = { fg = c.text, bg = c.code_bg },

    ["@markup.link"] = { fg = c.link },
    ["@markup.link.label"] = { fg = c.link, style = STYLES.underline },
    ["@markup.link.url"] = { fg = c.link, style = STYLES.underline_italic },

    ["@markup.quote"] = { fg = c.subtle, style = STYLES.italic },
    ["@markup.math"] = { fg = c.gold },

    ["@markup.environment"] = { fg = c.foam },
    ["@markup.environment.name"] = { fg = c.pine },

    ["@markup.raw"] = { fg = c.string },
    ["@markup.raw.block"] = { fg = c.text, bg = c.code_bg },

    -- === TAGS (HTML/XML) ===
    ["@tag"] = { fg = c.rose, style = STYLES.bold },
    ["@tag.builtin"] = { fg = c.builtin, style = STYLES.bold },
    ["@tag.attribute"] = { fg = c.gold },
    ["@tag.delimiter"] = { fg = c.punctuation },

    -- === LANGUAGE-SPECIFIC ENHANCEMENTS ===
    -- CSS
    ["@property.css"] = { fg = c.emphasis },
    ["@string.css"] = { fg = c.string },
    ["@number.css"] = { fg = c.gold },

    -- JavaScript/TypeScript
    ["@constructor.javascript"] = { fg = c.foam, style = STYLES.bold },
    ["@constructor.typescript"] = { fg = c.foam, style = STYLES.bold },

    -- Python
    ["@function.builtin.python"] = { fg = c.builtin, style = STYLES.bold_italic },
    ["@constant.builtin.python"] = { fg = c.builtin, style = STYLES.bold_italic },

    -- Rust
    ["@type.rust"] = { fg = c.foam, style = STYLES.bold },
    ["@attribute.rust"] = { fg = c.gold, style = STYLES.italic },

    -- Go
    ["@function.builtin.go"] = { fg = c.builtin, style = STYLES.bold_italic },
    ["@type.builtin.go"] = { fg = c.builtin, style = STYLES.bold },

    -- === DIFF ===
    ["@diff.plus"] = { fg = colors.tertiary_fixed },
    ["@diff.minus"] = { fg = colors.error },
    ["@diff.delta"] = { fg = colors.primary },

    -- === SPECIAL ELEMENTS ===
    ["@none"] = {},
    ["@conceal"] = { fg = c.muted },
    ["@spell"] = { style = STYLES.underline },
    ["@nospell"] = {},
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end

  -- === LSP SEMANTIC TOKENS ===
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
