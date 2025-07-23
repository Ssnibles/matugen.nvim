local utils = require("matugen_colorscheme.utils")
local brighten = utils.brighten_hex

local M = {}

--- Applies base Neovim highlight groups
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Helper to apply highlight groups in bulk
  local function apply_highlights(highlights)
    for group, opts in pairs(highlights) do
      set_hl(group, opts)
    end
  end

  -- Define semantic color aliases
  local semantic = {
    fg = colors.on_surface or "NONE",
    bg = colors.background or "NONE",
    accent = colors.primary or "NONE",
    sub_fg = colors.on_surface_variant or "NONE",
    sub_bg = colors.surface_container_high or "NONE",
    dim_fg = colors.outline_variant or "NONE",
    dim_bg = colors.surface_dim or "NONE",
    error_fg = colors.error or "NONE",
    error_bg = colors.error_container or "NONE",
    warn_fg = colors.primary_fixed_dim or "NONE",
    info_fg = colors.tertiary or "NONE",
    hint_fg = colors.outline or "NONE",
    float_bg = colors.surface_container_low or "NONE",
    surface_high = colors.surface_container_highest or "NONE",
    accent_bg = colors.primary_container or "NONE",
    brighten_bg = brighten(colors.background or "#000000", 20),
  }

  -- Define style presets
  local styles = {
    bold = { "bold" },
    italic = { "italic" },
    underline = { "underline" },
    bold_italic = { "bold", "italic" },
    bold_underline = { "bold", "underline" },
  }

  -- Base highlight definitions
  local highlights = {
    --------------------------------------------------------------------
    -- Core UI Elements
    --------------------------------------------------------------------
    Normal = { fg = semantic.fg, bg = semantic.bg },
    NormalNC = { fg = semantic.fg, bg = semantic.dim_bg },
    NormalFloat = { fg = semantic.fg, bg = semantic.float_bg },
    FloatBorder = { fg = semantic.dim_fg, bg = semantic.float_bg },
    Comment = { fg = semantic.dim_fg, style = styles.italic },
    Todo = {
      fg = colors.on_primary_container,
      bg = semantic.accent_bg,
      style = styles.bold,
    },

    --------------------------------------------------------------------
    -- Messages and Indicators
    --------------------------------------------------------------------
    ErrorMsg = {
      fg = colors.on_error_container,
      bg = semantic.error_bg,
      style = styles.bold,
    },
    WarningMsg = {
      fg = colors.on_primary_container,
      bg = semantic.accent_bg,
      style = styles.bold,
    },
    ModeMsg = { fg = colors.primary_fixed, style = styles.bold },
    NonText = { fg = semantic.dim_fg },
    SpecialKey = { fg = semantic.dim_fg },
    Conceal = { fg = semantic.dim_fg },

    --------------------------------------------------------------------
    -- Statusline & Tabs
    --------------------------------------------------------------------
    StatusLine = {
      fg = colors.on_primary_container,
      bg = semantic.brighten_bg,
    },
    StatusLineNC = {
      fg = semantic.sub_fg,
      bg = semantic.accent_bg,
    },
    TabLine = {
      fg = semantic.sub_fg,
      bg = semantic.surface_high,
    },
    TabLineFill = { bg = semantic.dim_bg },
    TabLineSel = {
      fg = colors.on_primary_container,
      bg = semantic.accent_bg,
      style = styles.bold,
    },

    --------------------------------------------------------------------
    -- Line Numbers & Cursor
    --------------------------------------------------------------------
    LineNr = { fg = semantic.dim_fg },
    CursorLine = { bg = semantic.sub_bg },
    CursorLineNr = {
      fg = colors.primary_fixed,
      style = styles.bold,
    },

    --------------------------------------------------------------------
    -- Visual Modes & Search
    --------------------------------------------------------------------
    Visual = { bg = colors.secondary_container },
    Search = {
      fg = colors.on_primary_container,
      bg = semantic.accent_bg,
      style = styles.bold,
    },
    IncSearch = {
      fg = colors.on_primary_container,
      bg = semantic.accent_bg,
      style = styles.bold_underline,
    },

    --------------------------------------------------------------------
    -- Folding & Signs
    --------------------------------------------------------------------
    Folded = {
      fg = semantic.sub_fg,
      bg = semantic.sub_bg,
      style = styles.italic,
    },
    SignColumn = { bg = "NONE" },

    --------------------------------------------------------------------
    -- Completion Menu
    --------------------------------------------------------------------
    Pmenu = {
      fg = semantic.fg,
      bg = semantic.surface_high,
    },
    PmenuSel = {
      fg = colors.on_primary_container,
      bg = semantic.accent_bg,
    },
    PmenuSbar = { bg = semantic.surface_high },
    PmenuThumb = { bg = semantic.accent },

    --------------------------------------------------------------------
    -- Diagnostics
    --------------------------------------------------------------------
    DiagnosticError = { fg = semantic.error_fg, style = styles.bold },
    DiagnosticWarn = { fg = semantic.warn_fg, style = styles.bold },
    DiagnosticInfo = { fg = semantic.info_fg },
    DiagnosticHint = { fg = semantic.hint_fg },

    DiagnosticUnderlineError = { style = styles.underline },
    DiagnosticUnderlineWarn = { style = styles.underline },
    DiagnosticUnderlineInfo = { style = styles.underline },
    DiagnosticUnderlineHint = { style = styles.underline },

    DiagnosticVirtualTextError = {
      fg = semantic.error_fg,
      style = styles.italic,
    },
    DiagnosticVirtualTextWarn = {
      fg = semantic.warn_fg,
      style = styles.italic,
    },
    DiagnosticVirtualTextInfo = {
      fg = semantic.info_fg,
      style = styles.italic,
    },
    DiagnosticVirtualTextHint = {
      fg = semantic.hint_fg,
      style = styles.italic,
    },

    DiagnosticSignError = { fg = semantic.error_fg },
    DiagnosticSignWarn = { fg = semantic.warn_fg },
    DiagnosticSignInfo = { fg = semantic.info_fg },
    DiagnosticSignHint = { fg = semantic.hint_fg },

    --------------------------------------------------------------------
    -- Version Control
    --------------------------------------------------------------------
    GitGutterAdd = { fg = colors.tertiary_fixed },
    GitGutterChange = { fg = colors.primary_fixed },
    GitGutterDelete = { fg = semantic.error_fg },
  }

  apply_highlights(highlights)
end

return M
