local M = {}

--- Applies Neovim Treesitter highlights with enhanced harmony and contrast
--- @param colors table The color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setting helper
function M.apply(colors, config, set_hl)
  local C = {
    -- Core text elements (enhanced contrast)
    fg = colors.on_background,
    muted = colors.on_surface_variant,
    comment = colors.outline,

    -- Semantic tokens (higher contrast)
    keyword = colors.primary,
    type = colors.tertiary,
    func = colors.secondary,
    builtin = colors.on_secondary_container, -- Improved visibility
    constant = colors.on_primary_container, -- Better contrast

    -- Literals (more distinct)
    string = colors.tertiary_fixed_dim, -- Higher contrast
    number = colors.primary, -- Brighter than before
    bool = colors.primary,
    escape = colors.secondary,

    -- Special elements
    tag = colors.primary,
    attribute = colors.tertiary_fixed_dim, -- More distinct from tags
    regex = colors.primary, -- Higher contrast
    annotation = colors.on_primary_container,
    annotation_bg = colors.primary_container,

    -- Markup/documentation
    heading = colors.primary,
    link = colors.secondary,
    quote = colors.outline,
    code_bg = colors.surface_container_high,

    -- Diagnostics (better contrast ratios)
    error = colors.error,
    warn = colors.primary, -- More visible
    info = colors.tertiary, -- Brighter
    hint = colors.on_surface_variant, -- Better visibility
    error_bg = colors.error_container,
    warn_bg = colors.surface_container_high, -- Improved contrast
    info_bg = colors.tertiary_container,
    hint_bg = colors.surface_container,

    -- Additional colors
    secondary_container = colors.secondary_container,
    tertiary_fixed_dim = colors.tertiary_fixed_dim,
    inverse_surface = colors.inverse_surface,
    surface_container_highest = colors.surface_container_highest,
  }

  local styles = {
    bold = { "bold" },
    italic = { "italic" },
    underline = { "underline" },
    bold_italic = { "bold", "italic" },
    underline_italic = { "underline", "italic" },
    none = {},
  }

  local function apply_highlights(highlights)
    for group, opts in pairs(highlights) do
      set_hl(group, opts)
    end
  end

  local highlights = {
    -- Core Syntax - Enhanced contrast
    ["@comment"] = { fg = C.comment, style = styles.italic },
    ["@keyword"] = { fg = C.keyword, style = styles.bold },
    ["@keyword.return"] = { fg = C.keyword, style = styles.bold_italic },
    ["@keyword.operator"] = { fg = C.type, style = styles.bold },
    ["@operator"] = { fg = C.type, style = styles.bold },
    ["@punctuation.delimiter"] = { fg = C.muted },
    ["@punctuation.bracket"] = { fg = C.muted },
    ["@punctuation.special"] = { fg = C.type, style = styles.bold },

    -- Functions - Clearer distinction
    ["@function"] = { fg = C.func, style = styles.bold },
    ["@function.call"] = { fg = C.func, style = styles.none },
    ["@function.builtin"] = { fg = C.builtin, style = styles.bold_italic },
    ["@method"] = { fg = C.func, style = styles.bold },
    ["@constructor"] = { fg = C.type, style = styles.bold },
    ["@parameter"] = { fg = C.muted, style = styles.italic },

    -- Types - Improved separation from builtins
    ["@type"] = { fg = C.type, style = styles.bold },
    ["@type.builtin"] = { fg = C.builtin, style = styles.bold },
    ["@namespace"] = { fg = C.keyword, style = styles.bold },
    ["@class"] = { fg = C.type, style = styles.bold },

    -- Variables - Consistent styling
    ["@variable"] = { fg = C.fg },
    ["@variable.builtin"] = { fg = C.constant, style = styles.italic },
    ["@property"] = { fg = C.attribute },
    ["@field"] = { fg = C.attribute },

    -- Literals - Harmonized with better differentiation
    ["@string"] = { fg = C.string },
    ["@string.escape"] = { fg = C.escape, style = styles.bold },
    ["@string.regex"] = { fg = C.regex, style = styles.bold },
    ["@number"] = { fg = C.number, style = styles.bold },
    ["@boolean"] = { fg = C.bool, style = styles.bold },
    ["@constant"] = { fg = C.constant, style = styles.bold },
    ["@constant.builtin"] = { fg = C.constant, style = styles.bold_italic },

    -- Markdown - Enhanced header contrast
    ["@text.title"] = { fg = C.heading, style = styles.bold },
    ["@text.literal"] = { fg = C.fg, bg = C.code_bg },
    ["@text.uri"] = { fg = C.link, style = styles.underline },
    ["@text.emphasis"] = { style = styles.italic },
    ["@text.strong"] = { style = styles.bold },
    ["@text.todo"] = { fg = C.annotation, bg = C.annotation_bg, style = styles.bold },
    ["@text.note"] = { fg = C.info, bg = C.info_bg },
    ["@text.warning"] = { fg = C.warn, bg = C.warn_bg },
    ["@text.danger"] = { fg = C.error, bg = C.error_bg },

    -- HTML/XML - Higher tag/attribute contrast
    ["@tag"] = { fg = C.tag, style = styles.bold },
    ["@tag.attribute"] = { fg = C.attribute }, -- Now teal instead of gold
    ["@tag.delimiter"] = { fg = C.comment },

    -- Special Elements
    ["@attribute"] = { fg = C.annotation, bg = C.annotation_bg, style = styles.bold },
    ["@exception"] = { fg = C.error, style = styles.bold },

    -- Diagnostics - Better visibility
    ["DiagnosticError"] = { fg = C.error, bg = C.error_bg, style = styles.bold },
    ["DiagnosticWarn"] = { fg = C.warn, bg = C.warn_bg, style = styles.bold },
    ["DiagnosticInfo"] = { fg = C.info, bg = C.info_bg },
    ["DiagnosticHint"] = { fg = C.hint, bg = C.hint_bg },
    ["DiagnosticUnderlineError"] = { sp = C.error, style = styles.underline },

    -- Diff - Clearer differentiation
    ["@diff.plus"] = { fg = C.tertiary_fixed_dim },
    ["@diff.minus"] = { fg = colors.error },
  }

  apply_highlights(highlights)

  -- Semantic links
  local links = {
    ["@keyword.import"] = "@include",
    ["@keyword.storage"] = "@keyword",
    ["@keyword.repeat"] = "@repeat",
    ["@text.diff.add"] = "DiffAdd",
    ["@text.diff.delete"] = "DiffDelete",
    ["@text.diff.change"] = "DiffChange",
    ["@lsp.type.class"] = "@type",
    ["@lsp.type.comment"] = "@comment",
    ["@lsp.type.function"] = "@function",
    ["@lsp.type.keyword"] = "@keyword",
    ["@lsp.type.string"] = "@string",
    ["@lsp.type.variable"] = "@variable",
  }

  for new, target in pairs(links) do
    set_hl(new, { link = target })
  end
end

return M
