local M = {}

--- Applies Neovim Treesitter specific highlight groups with harmonious contrast
--- @param colors table The table of colors parsed from Matugen.
--- @param config table The plugin's configuration table.
--- @param set_hl function Helper function to set highlight groups.
function M.apply(colors, config, set_hl)
  -- Unified semantic color palette using the expressive dark theme
  local C = {
    -- Core text elements
    fg = colors.on_background or "#DBE4E7",
    muted = colors.on_surface_variant or "#B8C9CE",
    comment = colors.outline or "#839498",

    -- Semantic tokens
    keyword = colors.primary or "#F5BD62",
    type = colors.tertiary or "#8ED1DF",
    func = colors.secondary or "#C6C2EA",
    builtin = colors.primary_fixed_dim or "#F5BD62",
    constant = colors.primary_fixed or "#FFDDAE",

    -- Literals
    string = colors.tertiary_fixed or "#AAEDFC",
    number = colors.primary_fixed or "#FFDDAE",
    bool = colors.primary or "#F5BD62",
    escape = colors.tertiary_fixed or "#AAEDFC",

    -- Special elements
    tag = colors.primary or "#F5BD62",
    attribute = colors.on_primary_container or "#FFDDAE",
    regex = colors.secondary_fixed_dim or "#C6C2EA",
    annotation = colors.on_primary_container or "#FFDDAE",
    annotation_bg = colors.primary_container or "#604100",

    -- Markup/documentation
    heading = colors.primary or "#F5BD62",
    link = colors.secondary or "#C6C2EA",
    quote = colors.outline or "#839498",
    code_bg = colors.surface_container_high or "#232B2D",

    -- Diagnostics
    error = colors.error or "#FFB4AB",
    warn = colors.primary or "#F5BD62",
    info = colors.tertiary or "#8ED1DF",
    hint = colors.outline or "#839498",

    -- Backgrounds
    error_bg = colors.error_container or "#93000A",
    warn_bg = colors.primary_container or "#604100",
    info_bg = colors.tertiary_container or "#004E5A",
    hint_bg = colors.surface_container or "#182123",

    -- Additional colors from the palette
    secondary_container = colors.secondary_container or "#454364",
    tertiary_fixed_dim = colors.tertiary_fixed_dim or "#8ED1DF",
    inverse_surface = colors.inverse_surface or "#DBE4E7",
    surface_container_highest = colors.surface_container_highest or "#2D3638",
  }

  -- Define style presets
  local styles = {
    bold = { "bold" },
    italic = { "italic" },
    underline = { "underline" },
    bold_italic = { "bold", "italic" },
    bold_underline = { "bold", "underline" },
    underline_italic = { "underline", "italic" },
  }

  --- Helper to apply multiple highlight groups from a table
  local function apply_highlights(highlights)
    for group_name, opts in pairs(highlights) do
      set_hl(group_name, opts)
    end
  end

  -- Define all highlights
  local highlights = {
    --- Core Syntax Elements
    ["@comment"] = { fg = C.comment, style = styles.italic },
    ["@keyword"] = { fg = C.keyword, style = styles.bold },
    ["@keyword.return"] = { fg = C.keyword, style = styles.bold_italic },
    ["@keyword.operator"] = { fg = C.type, style = styles.bold },
    ["@operator"] = { fg = C.type, style = styles.bold },
    ["@punctuation.delimiter"] = { fg = C.comment },
    ["@punctuation.bracket"] = { fg = C.comment },
    ["@punctuation.special"] = { fg = C.type, style = styles.bold },

    --- Functions and Methods
    ["@function"] = { fg = C.func, style = styles.bold },
    ["@function.call"] = { fg = C.func },
    ["@function.builtin"] = { fg = C.builtin, style = styles.bold_italic },
    ["@function.macro"] = { fg = C.func, style = styles.bold },
    ["@method"] = { fg = C.func, style = styles.bold },
    ["@method.call"] = { fg = C.func },
    ["@constructor"] = { fg = C.type, style = styles.bold },
    ["@parameter"] = { fg = C.muted, style = styles.italic },

    --- Types and Structures
    ["@type"] = { fg = C.type, style = styles.bold },
    ["@type.builtin"] = { fg = C.builtin, style = styles.bold_italic },
    ["@type.definition"] = { fg = C.type, style = styles.bold },
    ["@namespace"] = { fg = C.keyword, style = styles.bold },
    ["@structure"] = { fg = C.type, style = styles.bold },
    ["@class"] = { fg = C.type, style = styles.bold },

    --- Variables and Identifiers
    ["@variable"] = { fg = C.fg },
    ["@variable.builtin"] = { fg = C.constant, style = styles.bold_italic },
    ["@property"] = { fg = C.attribute },
    ["@field"] = { fg = C.attribute },
    ["@label"] = { fg = C.muted },

    --- Literals
    ["@string"] = { fg = C.string },
    ["@string.documentation"] = { fg = C.string, style = styles.italic },
    ["@string.escape"] = { fg = C.escape, style = styles.bold },
    ["@string.regex"] = { fg = C.regex, style = styles.bold },
    ["@string.special"] = { fg = C.escape },
    ["@number"] = { fg = C.number, style = styles.bold },
    ["@float"] = { fg = C.number, style = styles.bold },
    ["@boolean"] = { fg = C.bool, style = styles.bold },
    ["@character"] = { fg = C.number },
    ["@character.special"] = { fg = C.escape },
    ["@constant"] = { fg = C.constant, style = styles.bold },
    ["@constant.builtin"] = { fg = C.constant, style = styles.bold_italic },
    ["@constant.macro"] = { fg = C.constant, style = styles.bold },

    --- Markdown/Documentation
    ["@text.title"] = { fg = C.heading, style = styles.bold },
    ["@text.title.1"] = { fg = C.heading, style = styles.bold },
    ["@text.title.2"] = { fg = C.heading, style = styles.bold },
    ["@text.title.3"] = { fg = C.heading, style = styles.bold },
    ["@text.title.4"] = { fg = C.heading, style = styles.bold },
    ["@text.literal"] = { fg = C.fg, bg = C.code_bg },
    ["@text.uri"] = { fg = C.link, style = styles.underline },
    ["@text.reference"] = { fg = C.link },
    ["@text.emphasis"] = { style = styles.italic },
    ["@text.strong"] = { style = styles.bold },
    ["@text.underline"] = { style = styles.underline },
    ["@text.strike"] = { style = "strikethrough" },
    ["@text.math"] = { fg = C.type },
    ["@text.environment"] = { fg = C.keyword },
    ["@text.environment.name"] = { fg = C.keyword },
    ["@text.diff.add"] = { link = "DiffAdd" },
    ["@text.diff.delete"] = { link = "DiffDelete" },
    ["@text.todo"] = { fg = C.annotation, bg = C.annotation_bg, style = styles.bold },
    ["@text.note"] = { fg = C.info, bg = C.info_bg },
    ["@text.warning"] = { fg = C.warn, bg = C.warn_bg },
    ["@text.danger"] = { fg = C.error, bg = C.error_bg },

    ["@markup.heading"] = { fg = C.heading, style = styles.bold },
    ["@markup.raw"] = { fg = C.fg, bg = C.code_bg },
    ["@markup.link"] = { fg = C.link, style = styles.underline },
    ["@markup.link.url"] = { fg = C.link },
    ["@markup.link.label"] = { fg = C.link, style = styles.bold },
    ["@markup.quote"] = { fg = C.quote, style = styles.italic },
    ["@markup.list"] = { fg = C.fg },
    ["@markup.list.checked"] = { fg = colors.tertiary_fixed_dim or "#8ED1DF" },
    ["@markup.list.unchecked"] = { fg = C.comment },

    --- HTML/XML
    ["@tag"] = { fg = C.tag, style = styles.bold },
    ["@tag.attribute"] = { fg = C.attribute },
    ["@tag.builtin"] = { fg = C.tag, style = styles.bold },
    ["@tag.delimiter"] = { fg = C.comment },

    --- Special Elements
    ["@attribute"] = { fg = C.annotation, bg = C.annotation_bg, style = styles.bold },
    ["@exception"] = { fg = C.error, style = styles.bold },
    ["@define"] = { fg = C.keyword, style = styles.bold },
    ["@include"] = { fg = C.keyword, style = styles.bold },
    ["@debug"] = { fg = C.error },
    ["@preproc"] = { fg = C.keyword },

    --- LSP Semantic Tokens
    ["@lsp.type.class"] = { fg = C.type, style = styles.bold },
    ["@lsp.type.comment"] = { fg = C.comment, style = styles.italic },
    ["@lsp.type.decorator"] = { fg = C.annotation, bg = C.annotation_bg, style = styles.bold },
    ["@lsp.type.enum"] = { fg = C.type },
    ["@lsp.type.enumMember"] = { fg = C.constant },
    ["@lsp.type.function"] = { fg = C.func, style = styles.bold },
    ["@lsp.type.interface"] = { fg = C.type },
    ["@lsp.type.keyword"] = { fg = C.keyword, style = styles.bold },
    ["@lsp.type.macro"] = { fg = C.constant, style = styles.bold },
    ["@lsp.type.method"] = { fg = C.func, style = styles.bold },
    ["@lsp.type.namespace"] = { fg = C.keyword, style = styles.bold },
    ["@lsp.type.number"] = { fg = C.number, style = styles.bold },
    ["@lsp.type.operator"] = { fg = C.type, style = styles.bold },
    ["@lsp.type.parameter"] = { fg = C.muted, style = styles.italic },
    ["@lsp.type.property"] = { fg = C.attribute },
    ["@lsp.type.string"] = { fg = C.string },
    ["@lsp.type.type"] = { fg = C.type, style = styles.bold },
    ["@lsp.type.typeParameter"] = { fg = C.type },
    ["@lsp.type.variable"] = { fg = C.fg },

    --- Diagnostics
    ["DiagnosticError"] = { fg = C.error, bg = C.error_bg, style = styles.bold },
    ["DiagnosticWarn"] = { fg = C.warn, bg = C.warn_bg, style = styles.bold },
    ["DiagnosticInfo"] = { fg = C.info, bg = C.info_bg },
    ["DiagnosticHint"] = { fg = C.hint, bg = C.hint_bg },

    ["DiagnosticUnderlineError"] = { sp = C.error, style = styles.underline },
    ["DiagnosticUnderlineWarn"] = { sp = C.warn, style = styles.underline },
    ["DiagnosticUnderlineInfo"] = { sp = C.info, style = styles.underline },
    ["DiagnosticUnderlineHint"] = { sp = C.hint, style = styles.underline },

    --- New diagnostic groups
    ["DiagnosticSignError"] = { fg = C.error },
    ["DiagnosticSignWarn"] = { fg = C.warn },
    ["DiagnosticSignInfo"] = { fg = C.info },
    ["DiagnosticSignHint"] = { fg = C.hint },

    --- Additional UI elements
    ["@diff.plus"] = { fg = colors.tertiary_fixed_dim or "#8ED1DF" },
    ["@diff.minus"] = { fg = colors.error or "#FFB4AB" },
    ["@diff.delta"] = { fg = C.warn },

    ["@conceal"] = { fg = C.comment },
    ["@nontext"] = { fg = C.comment },

    --- Code folding
    ["@fold"] = { fg = C.comment, bg = C.surface_container_highest, style = styles.italic },
  }

  -- Apply all highlights
  apply_highlights(highlights)

  --- Compatibility Links
  set_hl("@text.diff.add", { link = "DiffAdd" })
  set_hl("@text.diff.delete", { link = "DiffDelete" })
  set_hl("@text.diff.change", { link = "DiffChange" })

  --- Additional semantic links
  set_hl("@keyword.coroutine", { link = "@keyword" })
  set_hl("@keyword.import", { link = "@include" })
  set_hl("@keyword.storage", { link = "@keyword" })
  set_hl("@keyword.repeat", { link = "@repeat" })
  set_hl("@keyword.return", { link = "@keyword" })
  set_hl("@keyword.debug", { link = "@debug" })

  --- Special text decorations
  set_hl("@text.todo.unchecked", { fg = C.comment })
  set_hl("@text.todo.checked", { fg = colors.tertiary_fixed_dim or "#8ED1DF" })
end

return M
