-- ~/projects/matugen.nvim/lua/matugen_colorscheme/highlights/mini_clue.lua
-- Mini.clue styled on the main Normal background using centralized colors.

local M = {}

function M.apply(colors, cfg, set_hl)
  local U = require("matugen_colorscheme.utils")
  local C = require("matugen_colorscheme.colors").get()

  -- Use the main editor background so the panel integrates with Normal.
  local panel_bg = C.bg

  -- Readable tones against the panel background.
  local text = U.ensure_contrast(C.fg, panel_bg, 7.0)
  local muted = U.ensure_contrast(C.fg_muted, panel_bg, 4.5)
  local border = U.ensure_contrast(C.border, panel_bg, 4.5)
  local title = U.ensure_contrast(C.primary, panel_bg, 5.0)
  local key_fg = U.ensure_contrast(C.tertiary, panel_bg, 5.0)
  local count_fg = U.ensure_contrast(C.error, panel_bg, 5.0)
  local hint_fg = U.ensure_contrast(C.secondary, panel_bg, 5.0)

  -- Selection derived from centralized selection colors to stay consistent.
  local sel_bg = C.selection_bg
  local sel_fg = C.selection_fg

  -- Panel and chrome
  set_hl("MiniClueBackground", { fg = text, bg = panel_bg })
  set_hl("MiniClueBorder", { fg = border, bg = panel_bg })
  set_hl("MiniClueTitle", { fg = title, bg = panel_bg, style = { "bold" } })
  set_hl("MiniClueSeparator", { fg = border, bg = panel_bg })

  -- Content
  set_hl("MiniClueDescGroup", { fg = muted, bg = panel_bg })
  set_hl("MiniClueDescSingle", { fg = text, bg = panel_bg })
  set_hl("MiniClueNextKey", { fg = key_fg, bg = panel_bg, style = { "bold" } })
  set_hl("MiniClueNextKeyWithPostkeys", { fg = key_fg, bg = panel_bg, style = { "bold" } })
  set_hl("MiniClueHint", { fg = hint_fg, bg = panel_bg })
  set_hl("MiniClueCount", { fg = count_fg, bg = panel_bg, style = { "bold" } })

  -- Selection row
  set_hl("MiniClueSelection", { fg = sel_fg, bg = sel_bg, style = { "bold" } })
end

return M
