-- ~/projects/matugen.nvim/lua/matugen_colorscheme/highlights/treesitter.lua
-- Tree-sitter syntax using centralized palette with WCAG-aware contrast.

local M = {}

function M.apply(colors, cfg, set_hl)
  local C = require("matugen_colorscheme.colors").get()
  local U = require("matugen_colorscheme.utils")

  local bg = C.bg

  -- Contrast targets per role
  local T = {
    text = 7.0,
    accent = 5.5,
    punct = 4.5,
    comm = 3.8,
    doc = 4.2,
  }

  -- Derive syntax tones against the main background
  local S = {
    text_primary = U.ensure_contrast(U.brighten_hex(C.fg, -8), bg, T.text),
    text_secondary = U.ensure_contrast(C.fg_muted, bg, T.text),
    comment = U.ensure_contrast(U.brighten_hex(C.fg_muted, -25), bg, T.comm),
    comment_doc = U.ensure_contrast(U.brighten_hex(C.fg_muted, -15), bg, T.doc),
    keyword = U.ensure_contrast(U.brighten_hex(C.primary, 8), bg, T.accent),
    fn = U.ensure_contrast(U.brighten_hex(C.tertiary, 12), bg, T.accent),
    type_name = U.ensure_contrast(U.brighten_hex(C.secondary, 10), bg, T.accent),
    constant = U.ensure_contrast(U.brighten_hex(C.primary, -6), bg, T.accent),
    string = U.ensure_contrast(C.tertiary, bg, T.accent),
    number = U.ensure_contrast(U.brighten_hex(C.secondary, 15), bg, T.accent),
    punct = U.ensure_contrast(U.brighten_hex(C.border_muted, 20), bg, T.punct),
    escape = U.ensure_contrast(U.brighten_hex(C.primary, 15), bg, T.accent),
    builtin = U.ensure_contrast(U.brighten_hex(C.primary, 5), bg, T.accent),
  }

  -- Comments
  set_hl("@comment", { fg = S.comment, style = { "italic" } })
  set_hl("@comment.documentation", { fg = S.comment_doc, style = { "italic" } })
  set_hl("@comment.todo", { fg = S.keyword, style = { "bold" } })
  set_hl("@comment.warning", { fg = S.number, style = { "bold" } })
  set_hl("@comment.error", { fg = S.escape, style = { "bold" } })
  set_hl("@comment.note", { fg = S.fn, style = { "bold" } })

  -- Punctuation and operators
  for _, grp in ipairs({
    "@punctuation",
    "@punctuation.delimiter",
    "@punctuation.bracket",
    "@punctuation.special",
    "@operator",
  }) do
    set_hl(grp, { fg = S.punct })
  end

  -- Variables & identifiers
  set_hl("@variable", { fg = S.text_primary })
  set_hl("@variable.member", { link = "@variable" })
  set_hl("@variable.parameter", { fg = S.text_secondary })
  set_hl("@variable.builtin", { fg = S.builtin, style = { "italic" } })
  set_hl("@symbol", { fg = S.text_primary })

  -- Properties & fields
  set_hl("@property", { fg = S.type_name })
  set_hl("@field", { fg = S.type_name })

  -- Functions & constructors
  for _, spec in ipairs({
    { "@function", { fg = S.fn, style = { "bold" } } },
    { "@function.method", { fg = S.fn, style = { "bold" } } },
    { "@function.call", { fg = S.fn } },
    { "@function.method.call", { fg = S.fn } },
    { "@function.builtin", { fg = S.fn, style = { "bold" } } },
    { "@function.macro", { fg = S.fn, style = { "bold" } } },
    { "@constructor", { fg = S.keyword, style = { "bold" } } },
  }) do
    set_hl(spec[1], spec[2])
  end

  -- Keywords & control flow
  for _, spec in ipairs({
    { "@keyword", { fg = S.keyword, style = { "bold" } } },
    { "@keyword.function", { fg = S.keyword, style = { "bold" } } },
    { "@keyword.operator", { fg = S.keyword } },
    { "@keyword.return", { fg = S.keyword, style = { "bold" } } },
    { "@keyword.conditional", { fg = S.keyword, style = { "bold" } } },
    { "@keyword.repeat", { fg = S.keyword, style = { "bold" } } },
    { "@keyword.import", { fg = S.keyword } },
    { "@keyword.type", { fg = S.keyword } },
    { "@keyword.modifier", { fg = S.keyword } },
  }) do
    set_hl(spec[1], spec[2])
  end

  -- Literals & constants
  for _, spec in ipairs({
    { "@string", { fg = S.string } },
    { "@string.escape", { fg = S.escape, style = { "bold" } } },
    { "@string.regex", { fg = S.type_name } },
    { "@string.special", { fg = S.string, style = { "bold" } } },
    { "@character", { fg = S.string } },
    { "@number", { fg = S.number, style = { "bold" } } },
    { "@float", { fg = S.number, style = { "bold" } } },
    { "@boolean", { fg = S.number, style = { "bold" } } },
    { "@constant", { fg = S.constant, style = { "bold" } } },
    { "@constant.builtin", { fg = S.builtin, style = { "bold" } } },
  }) do
    set_hl(spec[1], spec[2])
  end

  -- Types & namespaces
  for _, spec in ipairs({
    { "@type", { fg = S.type_name, style = { "bold" } } },
    { "@type.builtin", { fg = S.type_name, style = { "bold" } } },
    { "@type.definition", { fg = S.type_name } },
    { "@namespace", { fg = S.type_name } },
    { "@module", { fg = S.type_name } },
    { "@package", { fg = S.type_name } },
    { "@attribute", { fg = S.type_name } },
    { "@annotation", { fg = S.type_name } },
  }) do
    set_hl(spec[1], spec[2])
  end

  -- Markup & docs
  for _, spec in ipairs({
    { "@markup.heading", { fg = S.keyword, style = { "bold" } } },
    { "@markup.strong", { fg = S.text_primary, style = { "bold" } } },
    { "@markup.italic", { fg = S.text_primary, style = { "italic" } } },
    { "@markup.strikethrough", { fg = S.text_secondary, style = { "strikethrough" } } },
    { "@markup.underline", { fg = S.text_primary, style = { "underline" } } },
    { "@markup.link", { fg = S.fn, style = { "underline" } } },
    { "@markup.link.url", { fg = S.fn, style = { "underline" } } },
    { "@markup.raw", { fg = S.type_name } },
    { "@markup.quote", { fg = S.comment_doc, style = { "italic" } } },
    { "@markup.list", { fg = S.punct } },
  }) do
    set_hl(spec[1], spec[2])
  end

  -- Tags
  set_hl("@tag", { fg = S.keyword })
  set_hl("@tag.attribute", { fg = S.type_name })
  set_hl("@tag.delimiter", { fg = S.punct })

  -- Diff
  set_hl("@diff.plus", { fg = S.string })
  set_hl("@diff.minus", { fg = S.escape })
  set_hl("@diff.delta", { fg = S.number })

  -- Legacy links to keep classic groups in sync
  set_hl("Comment", { link = "@comment" })
  set_hl("Identifier", { link = "@variable" })
  set_hl("Function", { link = "@function" })
  set_hl("Statement", { link = "@keyword" })
  set_hl("Type", { link = "@type" })
  set_hl("Constant", { link = "@constant" })
  set_hl("String", { link = "@string" })
  set_hl("Number", { link = "@number" })
  set_hl("Special", { fg = S.escape })
  set_hl("Delimiter", { link = "@punctuation" })
end

return M
