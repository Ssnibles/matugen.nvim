local M = {}

-- Style combinations for reuse
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  underline = { "underline" },
  undercurl = { "undercurl" },
  bold_italic = { "bold", "italic" },
}

--- Apply base highlights
--- @param colors table
--- @param config table
--- @param set_hl function
function M.apply(colors, config, set_hl)
  -- Create semantic color shortcuts with proper Material You integration
  local c = {
    -- Base colors
    fg = colors.on_surface,
    bg = colors.background,

    -- Primary system
    primary = colors.primary,
    primary_container = colors.primary_container,
    on_primary = colors.on_primary,
    on_primary_container = colors.on_primary_container,

    -- Secondary system
    secondary = colors.secondary,
    secondary_container = colors.secondary_container,
    on_secondary_container = colors.on_secondary_container,

    -- Tertiary system
    tertiary = colors.tertiary,
    tertiary_container = colors.tertiary_container,
    on_tertiary_container = colors.on_tertiary_container,

    -- Error system
    error = colors.error,
    error_container = colors.error_container,
    on_error_container = colors.on_error_container,

    -- Surface hierarchy
    surface = colors.surface,
    surface_dim = colors.surface_dim,
    surface_bright = colors.surface_bright,
    surface_low = colors.surface_container_low,
    surface_high = colors.surface_container_high,
    surface_highest = colors.surface_container_highest,

    -- Outline system
    outline = colors.outline,
    outline_variant = colors.outline_variant,
    on_surface_variant = colors.on_surface_variant,
  }

  -- Core base highlights only
  local highlights = {
    -- Fundamental base
    Normal = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.surface_high },
    NormalNC = { fg = c.on_surface_variant, bg = c.surface_dim },

    -- Cursor and current line
    Cursor = { fg = c.on_primary, bg = c.primary },
    CursorIM = { fg = c.on_secondary_container, bg = c.secondary_container },
    CursorLine = { bg = c.surface },
    CursorColumn = { bg = c.surface },
    ColorColumn = { bg = c.surface_dim },

    -- Line numbers
    LineNr = { fg = c.outline_variant },
    CursorLineNr = { fg = c.primary, style = STYLES.bold },

    -- Comments and non-text
    Comment = { fg = c.outline_variant, style = STYLES.italic },
    NonText = { fg = c.outline_variant },
    SpecialKey = { fg = c.outline_variant },
    Whitespace = { fg = c.outline_variant },

    -- Visual selection
    Visual = { bg = c.secondary_container },
    VisualNOS = { bg = c.secondary_container },

    -- Search
    Search = { fg = c.on_tertiary_container, bg = c.tertiary_container },
    IncSearch = { fg = c.on_primary, bg = c.primary, style = STYLES.bold },
    CurSearch = { fg = c.on_primary, bg = c.primary, style = STYLES.bold },
    Substitute = { fg = c.on_error_container, bg = c.error_container },

    -- Status line
    StatusLine = { fg = c.on_surface, bg = c.surface_high },
    StatusLineNC = { fg = c.on_surface_variant, bg = c.surface },

    -- Window separators
    WinSeparator = { fg = c.outline_variant },
    VertSplit = { fg = c.outline_variant },

    -- Tabs
    TabLine = { fg = c.on_surface_variant, bg = c.surface },
    TabLineFill = { bg = c.surface_dim },
    TabLineSel = { fg = c.on_primary_container, bg = c.primary_container, style = STYLES.bold },

    -- Popup menu
    Pmenu = { fg = c.on_surface, bg = c.surface_high },
    PmenuSel = { fg = c.on_primary_container, bg = c.primary_container },
    PmenuSbar = { bg = c.surface_low },
    PmenuThumb = { bg = c.primary },

    -- Messages
    ErrorMsg = { fg = c.on_error_container, bg = c.error_container },
    WarningMsg = { fg = c.on_tertiary_container, bg = c.tertiary_container },
    ModeMsg = { fg = c.primary, style = STYLES.bold },
    MoreMsg = { fg = c.secondary },
    Question = { fg = c.tertiary, style = STYLES.bold },

    -- Folding
    Folded = { fg = c.on_surface_variant, bg = c.surface, style = STYLES.italic },
    FoldColumn = { fg = c.outline },
    SignColumn = { bg = "NONE" },

    -- Matching
    MatchParen = { fg = c.on_primary, bg = c.primary, style = STYLES.bold },

    -- Spelling
    SpellBad = { sp = c.error, style = STYLES.undercurl },
    SpellCap = { sp = c.tertiary, style = STYLES.undercurl },
    SpellLocal = { sp = c.secondary, style = STYLES.undercurl },
    SpellRare = { sp = c.outline, style = STYLES.undercurl },

    -- Wild menu
    WildMenu = { fg = c.on_primary_container, bg = c.primary_container },

    -- Diff
    DiffAdd = { fg = c.on_primary_container, bg = c.primary_container },
    DiffChange = { fg = c.on_secondary_container, bg = c.secondary_container },
    DiffDelete = { fg = c.on_error_container, bg = c.error_container },
    DiffText = { fg = c.on_tertiary_container, bg = c.tertiary_container, style = STYLES.bold },

    -- Directory
    Directory = { fg = c.primary, style = STYLES.bold },

    -- Title
    Title = { fg = c.primary, style = STYLES.bold },

    -- Conceal
    Conceal = { fg = c.outline_variant },
  }

  -- Basic diagnostics (core vim diagnostics, not LSP-specific)
  local diagnostic_groups = {
    { "Error", c.error, c.error_container, c.on_error_container },
    { "Warn", c.tertiary, c.tertiary_container, c.on_tertiary_container },
    { "Info", c.secondary, c.secondary_container, c.on_secondary_container },
    { "Hint", c.outline, c.surface_high, c.on_surface_variant },
  }

  for _, diag in ipairs(diagnostic_groups) do
    local name, color, bg_color, fg_color = diag[1], diag[2], diag[3], diag[4]

    highlights["Diagnostic" .. name] = { fg = color }
    highlights["DiagnosticSign" .. name] = { fg = color, bg = "NONE" }
    highlights["DiagnosticVirtualText" .. name] = {
      fg = color,
      bg = bg_color,
      style = STYLES.italic,
    }
    highlights["DiagnosticUnderline" .. name] = {
      sp = color,
      style = STYLES.undercurl,
    }
    highlights["DiagnosticFloating" .. name] = { fg = fg_color, bg = bg_color }
  end

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
