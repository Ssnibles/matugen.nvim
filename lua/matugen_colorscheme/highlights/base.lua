-- ~/projects/matugen.nvim/lua/matugen_colorscheme/highlights/base.lua
-- Base UI highlights driven by centralized colors; minimal per-group tweaks.

local M = {}

function M.apply(colors, cfg, set_hl)
  local C = require("matugen_colorscheme.colors").get()
  local U = require("matugen_colorscheme.utils")

  -- Core editor UI
  set_hl("Normal", { fg = C.fg, bg = C.bg })
  set_hl("NormalNC", { fg = C.fg_muted, bg = C.surface_low })

  -- Cursor and line numbers
  set_hl("CursorLine", { bg = C.surface_low })
  set_hl("CursorColumn", { bg = C.surface_low })
  set_hl("LineNr", { fg = C.fg_muted })
  set_hl("CursorLineNr", {
    fg = U.ensure_contrast(C.primary, C.bg, 5.5),
    style = { "bold" },
  })
  set_hl("SignColumn", { bg = C.bg })

  -- Floating windows
  local float_bg = C.doc_bg
  local float_border = C.doc_border
  local float_title = U.ensure_contrast(C.primary, float_bg, 5.0)
  set_hl("NormalFloat", { fg = U.ensure_contrast(C.fg, float_bg, 7.0), bg = float_bg })
  set_hl("FloatBorder", { fg = float_border, bg = float_bg })
  set_hl("FloatTitle", { fg = float_title, bg = float_bg, style = { "bold" } })

  -- Popup menus (completion etc.)
  set_hl("Pmenu", { fg = C.menu_fg, bg = C.menu_bg })
  set_hl("PmenuSel", { fg = C.selection_fg, bg = C.selection_bg, style = { "bold" } })
  set_hl("PmenuKind", { fg = U.ensure_contrast(C.primary, C.menu_bg, 5.0) })
  set_hl("PmenuKindSel", { fg = C.selection_fg, style = { "bold" } })
  set_hl("PmenuSbar", { bg = C.surface_default })
  set_hl("PmenuThumb", { bg = U.ensure_contrast(C.border, C.surface_default, 4.0) })

  -- Status lines and tabs
  set_hl("StatusLine", { fg = U.ensure_contrast(C.fg, C.surface_default, 7.0), bg = C.surface_default })
  set_hl("StatusLineNC", { fg = U.ensure_contrast(C.fg_muted, C.surface_low, 4.0), bg = C.surface_low })
  set_hl("TabLine", { fg = U.ensure_contrast(C.fg_muted, C.surface_low, 5.0), bg = C.surface_low })
  set_hl("TabLineSel", {
    fg = U.ensure_contrast(C.on_primary_container or C.fg, C.primary_container, 5.5),
    bg = C.primary_container,
    style = { "bold" },
  })
  set_hl("TabLineFill", { bg = C.bg })

  -- Window separators
  set_hl("VertSplit", { fg = U.ensure_contrast(C.border_muted, C.bg, 4.5) })
  set_hl("WinSeparator", { fg = U.ensure_contrast(C.border_muted, C.bg, 4.5) })

  -- Selection and search
  set_hl(
    "Visual",
    { bg = C.primary_container, fg = U.ensure_contrast(C.on_primary_container or C.fg, C.primary_container, 5.5) }
  )
  set_hl(
    "Search",
    { bg = C.secondary_container, fg = U.ensure_contrast(C.on_secondary_container or C.fg, C.secondary_container, 5.5) }
  )
  set_hl(
    "IncSearch",
    {
      bg = C.tertiary_container,
      fg = U.ensure_contrast(C.on_tertiary_container or C.fg, C.tertiary_container, 6.0),
      style = { "bold" },
    }
  )
  set_hl(
    "CurSearch",
    {
      bg = C.primary_container,
      fg = U.ensure_contrast(C.on_primary_container or C.fg, C.primary_container, 6.0),
      style = { "bold" },
    }
  )

  -- Titles and emphasis
  set_hl("Title", { fg = U.ensure_contrast(C.primary, C.bg, 5.5), style = { "bold" } })
  set_hl("Directory", { fg = U.ensure_contrast(C.primary, C.bg, 5.0) })

  -- Special characters and UI
  set_hl("NonText", { fg = C.fg_muted })
  set_hl("Conceal", { fg = C.fg_muted })
  set_hl("Whitespace", { fg = C.fg_muted })
  set_hl("SpecialKey", { fg = U.ensure_contrast(C.border_muted, C.bg, 4.5) })

  -- Messages and cmdline
  set_hl("MsgArea", { fg = C.fg, bg = C.bg })
  set_hl("MsgSeparator", { fg = U.ensure_contrast(C.border_muted, C.bg, 4.5), bg = C.bg })

  -- Error and warnings
  set_hl("ErrorMsg", { fg = U.ensure_contrast(C.error, C.bg, 5.5) })
  set_hl("WarningMsg", { fg = U.ensure_contrast(C.primary, C.bg, 5.5) })

  -- Folds
  set_hl("Folded", { fg = U.ensure_contrast(C.fg_muted, C.surface_low, 5.0), bg = C.surface_low })
  set_hl("FoldColumn", { fg = C.fg_muted, bg = C.bg })

  -- Matching/pairing
  set_hl("MatchParen", {
    fg = U.ensure_contrast(C.on_tertiary_container or C.fg, C.tertiary_container, 6.0),
    bg = C.tertiary_container,
    style = { "bold" },
  })

  -- Wild menu
  set_hl("WildMenu", {
    fg = U.ensure_contrast(C.on_primary_container or C.fg, C.primary_container, 5.5),
    bg = C.primary_container,
  })

  -- Prompts
  set_hl("Question", { fg = U.ensure_contrast(C.primary, C.bg, 5.5) })
  set_hl("MoreMsg", { fg = U.ensure_contrast(C.primary, C.bg, 5.5) })
  set_hl("ModeMsg", { fg = C.fg })
end

return M
