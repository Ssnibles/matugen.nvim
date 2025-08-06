local M = {}
local utils = require("matugen_colorscheme.utils")

-- Predefined style combinations
local styles = {
  bold = { "bold" },
  italic = { "italic" },
  underline = { "underline" },
  bold_italic = { "bold", "italic" },
  bold_underline = { "bold", "underline" },
}

--- Applies base Neovim highlight groups
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Create semantic color mappings
  local s = {
    fg = colors.on_surface,
    bg = colors.background,
    accent = colors.primary,
    sub_fg = colors.on_surface_variant,
    sub_bg = colors.surface_container_high,
    dim_fg = colors.outline_variant,
    dim_bg = colors.surface_dim,
    error_fg = colors.error,
    error_bg = colors.error_container,
    warn_fg = colors.tertiary,
    info_fg = colors.secondary,
    hint_fg = colors.on_tertiary_container,
    float_bg = colors.surface_container_low,
    surface_high = colors.surface_container_highest,
    accent_bg = colors.primary_container,
    bg_light_20 = utils.brighten_hex(colors.background, 20),
    bg_light_50 = utils.brighten_hex(colors.background, 50),
  }

  -- Core highlight definitions
  local highlights = {
    -- Core UI Elements
    NormalNC = { fg = s.sub_fg, bg = s.dim_bg },
    NormalFloat = { fg = s.fg, bg = s.float_bg },
    FloatBorder = { fg = s.sub_fg, bg = s.float_bg },
    Comment = { fg = s.dim_fg, style = styles.italic },
    Todo = { fg = colors.on_primary_container, bg = s.accent_bg, style = styles.bold },

    -- Messages and Indicators
    ErrorMsg = { fg = colors.on_error_container, bg = s.error_bg, style = styles.bold },
    WarningMsg = { fg = colors.on_tertiary_container, bg = colors.tertiary_container, style = styles.bold },
    ModeMsg = { fg = s.accent, style = styles.bold },
    NonText = { fg = s.dim_fg },
    SpecialKey = { fg = s.dim_fg },
    Conceal = { fg = s.dim_fg },

    -- Statusline & Tabs
    StatusLine = { fg = s.fg, bg = s.bg_light_20 },
    StatusLineNC = { fg = s.sub_fg, bg = s.bg_light_20 },
    TabLine = { fg = s.sub_fg, bg = s.bg_light_20 },
    TabLineFill = { bg = s.dim_bg },
    TabLineSel = { fg = s.accent, bg = s.sub_bg, style = styles.bold },

    -- Line Numbers & Cursor
    LineNr = { fg = s.dim_fg },
    CursorLine = { bg = s.bg_light_50 },
    CursorLineNr = { fg = s.accent, style = styles.bold },

    -- Visual Modes & Search
    Visual = { bg = colors.secondary_container },
    Search = { fg = colors.on_primary_container, bg = s.accent_bg, style = styles.bold },
    IncSearch = {
      fg = colors.on_primary_container,
      bg = utils.brighten_hex(s.accent_bg, 10),
      style = styles.bold_underline,
    },

    -- Folding & Signs
    Folded = { fg = s.sub_fg, bg = s.sub_bg, style = styles.italic },
    SignColumn = { bg = "NONE" },

    -- Completion Menu
    Pmenu = { fg = s.fg, bg = s.float_bg },
    PmenuSel = { fg = colors.on_primary_container, bg = s.accent_bg },
    PmenuSbar = { bg = s.float_bg },
    PmenuThumb = { bg = s.accent },

    -- Diagnostics
    DiagnosticError = { fg = s.error_fg },
    DiagnosticWarn = { fg = s.warn_fg },
    DiagnosticInfo = { fg = s.info_fg },
    DiagnosticHint = { fg = s.hint_fg },

    DiagnosticUnderlineError = { sp = s.error_fg, style = styles.underline },
    DiagnosticUnderlineWarn = { sp = s.warn_fg, style = styles.underline },
    DiagnosticUnderlineInfo = { sp = s.info_fg, style = styles.underline },
    DiagnosticUnderlineHint = { sp = s.hint_fg, style = styles.underline },

    DiagnosticVirtualTextError = { fg = s.error_fg, style = styles.italic },
    DiagnosticVirtualTextWarn = { fg = s.warn_fg, style = styles.italic },
    DiagnosticVirtualTextInfo = { fg = s.info_fg, style = styles.italic },
    DiagnosticVirtualTextHint = { fg = s.hint_fg, style = styles.italic },

    DiagnosticSignError = { fg = s.error_fg },
    DiagnosticSignWarn = { fg = s.warn_fg },
    DiagnosticSignInfo = { fg = s.info_fg },
    DiagnosticSignHint = { fg = s.hint_fg },

    -- Version Control
    GitGutterAdd = { fg = colors.tertiary },
    GitGutterChange = { fg = s.warn_fg },
    GitGutterDelete = { fg = s.error_fg },
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
