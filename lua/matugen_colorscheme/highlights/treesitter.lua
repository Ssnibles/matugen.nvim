-- ~/projects/matugen.nvim/lua/matugen_colorscheme/highlights/treesitter.lua

local M = {}

--- Applies Neovim Treesitter specific highlight groups for maximum contrast.
--- @param colors table The table of colors parsed from Matugen.
--- @param config table The plugin's configuration table.
--- @param set_hl function Helper function to set highlight groups.
function M.apply(colors, config, set_hl)
  -- Unified semantic color palette
  local C = {
    -- Core text elements
    fg = colors.on_background, -- Primary text (DBE4E7) - Good contrast against dark background
    muted = colors.outline, -- Secondary text (839498) - Slightly less prominent than fg
    comment = colors.outline_variant, -- Comments (3A494D) - Significantly muted for comments

    -- Semantic tokens
    keyword = colors.primary_fixed, -- Control flow keywords (FFDDAE) - Brighter, stands out
    type = colors.tertiary_fixed, -- Type definitions (AAEDFC) - Distinct, bright aqua/cyan
    func = colors.secondary_fixed, -- Function definitions (E3DFFF) - Soft purple, good contrast
    builtin = colors.tertiary_fixed_dim, -- Built-in elements (8ED1DF) - Slightly muted tertiary
    constant = colors.primary_fixed_dim, -- Constants (F5BD62) - Warm yellow, clearly visible

    -- Literals
    string = colors.secondary_fixed_dim, -- String literals (C6C2EA) - Muted secondary for strings
    number = colors.tertiary_fixed_dim, -- Numeric literals (8ED1DF) - Same as builtin for consistency
    bool = colors.primary_fixed_dim, -- Boolean literals (F5BD62) - Same as constants
    escape = colors.tertiary_fixed, -- Escape sequences (AAEDFC) - Bright for special chars

    -- Special elements
    tag = colors.secondary_fixed, -- HTML/XML tags (E3DFFF) - Matches function, prominent
    attribute = colors.on_primary_container, -- HTML attributes (FFDDAE) - Bright, similar to primary_fixed
    regex = colors.primary_fixed_dim, -- Regular expressions (F5BD62) - Distinct from strings
    annotation = colors.on_primary_container, -- Decorators/annotations (FFDDAE) - Prominent for annotations
    annotation_bg = colors.primary_container, -- (604100) - Darker background for annotations

    -- Markup/documentation
    heading = colors.primary_fixed, -- Headers (FFDDAE) - Stands out as important
    link = colors.secondary_fixed, -- Hyperlinks (E3DFFF) - Easily clickable
    quote = colors.comment, -- Blockquotes (3A494D) - Muted, like comments
    code_bg = colors.surface_container_high, -- Code block background (232B2D) - Darker than background

    -- Diagnostics
    error = colors.error, -- (FFB4AB) - Bright red
    warn = colors.primary_fixed, -- (FFDDAE) - Bright yellow for warnings
    info = colors.tertiary_fixed, -- (AAEDFC) - Bright aqua for info
    hint = colors.outline, -- (839498) - Muted for hints

    -- Backgrounds (for diagnostics)
    error_bg = colors.error_container, -- (93000A)
    warn_bg = colors.primary_container, -- (604100)
    info_bg = colors.tertiary_container, -- (004E5A)
    hint_bg = colors.secondary_container, -- (454364)
  }

  --- Helper to apply multiple highlight groups from a table
  -- @param highlights table A table where keys are highlight group names and values are tables
  -- containing {fg, bg, style}
  local function apply_highlights(highlights)
    for group_name, params in pairs(highlights) do
      set_hl(group_name, params[1], params[2], params[3])
    end
  end

  --- Core Syntax Elements
  apply_highlights({
    ["@comment"] = { C.comment, nil, "italic" },
    ["@keyword"] = { C.keyword, nil, "bold" },
    ["@operator"] = { C.type, nil, "bold" }, -- Using type color for operators
    ["@punctuation.delimiter"] = { C.muted, nil }, -- More distinct than comment for delimiters
    ["@punctuation.bracket"] = { C.muted, nil }, -- More distinct than comment for brackets
    ["@punctuation.special"] = { C.type, nil, "bold" },
  })

  --- Functions and Methods
  apply_highlights({
    ["@function"] = { C.func, nil, "bold" },
    ["@function.call"] = { C.func, nil },
    ["@function.builtin"] = { C.builtin, nil, "italic,bold" },
    ["@method"] = { C.func, nil, "bold" },
    ["@method.call"] = { C.func, nil },
    ["@constructor"] = { C.type, nil, "bold" },
  })

  --- Types and Structures
  apply_highlights({
    ["@type"] = { C.type, nil, "bold" },
    ["@type.builtin"] = { C.builtin, nil, "italic,bold" },
    ["@namespace"] = { C.keyword, nil, "bold" }, -- Namespace aligns with keyword
    ["@structure"] = { C.type, nil, "bold" },
  })

  --- Variables and Identifiers
  apply_highlights({
    ["@variable"] = { C.fg, nil },
    ["@variable.builtin"] = { C.constant, nil, "italic,bold" },
    ["@parameter"] = { C.muted, nil, "italic" },
    ["@property"] = { C.attribute, nil },
    ["@field"] = { C.attribute, nil },
  })

  --- Literals
  apply_highlights({
    ["@string"] = { C.string, nil },
    ["@string.escape"] = { C.escape, nil },
    ["@string.regex"] = { C.regex, nil, "bold" },
    ["@number"] = { C.number, nil, "bold" },
    ["@float"] = { C.number, nil, "bold" },
    ["@boolean"] = { C.bool, nil, "bold" },
    ["@character"] = { C.number, nil },
    ["@constant"] = { C.constant, nil, "bold" },
    ["@constant.builtin"] = { C.constant, nil, "italic,bold" },
  })

  --- Markdown/Documentation
  apply_highlights({
    ["@text.title"] = { C.heading, nil, "bold" },
    ["@text.literal"] = { C.fg, nil },
    ["@text.uri"] = { C.link, nil, "underline" },
    ["@text.reference"] = { C.link, nil },
    ["@markup.heading"] = { C.heading, nil, "bold" },
    ["@markup.raw"] = { C.fg, C.code_bg },
    ["@markup.link"] = { C.link, nil, "underline" },
    ["@markup.quote"] = { C.quote, nil, "italic" },
    ["@markup.link.url"] = { C.link, nil },
    ["@markup.link.label"] = { C.link, nil, "bold" },
  })

  --- HTML/XML
  apply_highlights({
    ["@tag"] = { C.tag, nil, "bold" },
    ["@tag.attribute"] = { C.attribute, nil },
    ["@tag.builtin"] = { C.tag, nil, "bold" },
    ["@tag.delimiter"] = { C.muted, nil }, -- Using muted for tag delimiters
  })

  --- Special Elements
  apply_highlights({
    ["@attribute"] = { C.annotation, C.annotation_bg, "bold" },
    ["@exception"] = { C.error, nil, "bold" },
    ["@define"] = { C.keyword, nil, "bold" },
    ["@include"] = { C.keyword, nil, "bold" },
  })

  --- LSP Semantic Tokens
  apply_highlights({
    ["@lsp.type.class"] = { C.type, nil, "bold" },
    ["@lsp.type.comment"] = { C.comment, nil, "italic" },
    ["@lsp.type.decorator"] = { C.annotation, C.annotation_bg, "bold" },
    ["@lsp.type.enum"] = { C.type, nil },
    ["@lsp.type.enumMember"] = { C.constant, nil },
    ["@lsp.type.function"] = { C.func, nil, "bold" },
    ["@lsp.type.interface"] = { C.type, nil },
    ["@lsp.type.keyword"] = { C.keyword, nil, "bold" },
    ["@lsp.type.macro"] = { C.constant, nil, "bold" },
    ["@lsp.type.method"] = { C.func, nil, "bold" },
    ["@lsp.type.namespace"] = { C.keyword, nil, "bold" },
    ["@lsp.type.number"] = { C.number, nil, "bold" },
    ["@lsp.type.operator"] = { C.type, nil, "bold" },
    ["@lsp.type.parameter"] = { C.muted, nil, "italic" },
    ["@lsp.type.property"] = { C.attribute, nil },
    ["@lsp.type.string"] = { C.string, nil },
    ["@lsp.type.type"] = { C.type, nil, "bold" },
    ["@lsp.type.typeParameter"] = { C.type, nil },
    ["@lsp.type.variable"] = { C.fg, nil },
  })

  --- Diagnostics
  apply_highlights({
    ["DiagnosticError"] = { C.error, C.error_bg, "bold" },
    ["DiagnosticWarn"] = { C.warn, C.warn_bg, "bold" },
    ["DiagnosticInfo"] = { C.info, C.info_bg },
    ["DiagnosticHint"] = { C.hint, C.hint_bg },
  })

  apply_highlights({
    ["DiagnosticUnderlineError"] = { C.error, nil, "underline" },
    ["DiagnosticUnderlineWarn"] = { C.warn, nil, "underline" },
    ["DiagnosticUnderlineInfo"] = { C.info, nil, "underline" },
    ["DiagnosticUnderlineHint"] = { C.hint, nil, "underline" },
  })

  --- Compatibility Links
  set_hl_link("@text.diff.add", "DiffAdd")
  set_hl_link("@text.diff.delete", "DiffDelete")
  set_hl_link("@text.diff.change", "DiffChange")
end

return M
