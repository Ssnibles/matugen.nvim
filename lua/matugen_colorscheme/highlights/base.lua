local M = {}

-- Style combinations for reuse
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  underline = { "underline" },
  bold_italic = { "bold", "italic" },
}

--- Apply base highlights
--- @param colors table
--- @param config table
--- @param set_hl function
function M.apply(colors, config, set_hl)
  -- Create semantic color shortcuts
  local c = {
    fg = colors.on_surface,
    bg = colors.background,
    primary = colors.primary,
    secondary = colors.secondary,
    tertiary = colors.tertiary,
    error = colors.error,
    warning = colors.tertiary,
    info = colors.secondary,
    hint = colors.on_tertiary_container,

    -- Surfaces
    surface = colors.surface,
    surface_dim = colors.surface_dim,
    surface_low = colors.surface_container_low,
    surface_high = colors.surface_container_high,

    -- Variants
    fg_variant = colors.on_surface_variant,
    outline = colors.outline_variant,
  }

  -- Core highlights table
  local highlights = {
    -- Base
    Normal = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.surface_low },
    NormalNC = { fg = c.fg_variant, bg = c.surface_dim },

    -- Comments and special
    Comment = { fg = c.outline, style = STYLES.italic },
    NonText = { fg = c.outline },
    SpecialKey = { fg = c.outline },

    -- UI Elements
    StatusLine = { fg = c.fg, bg = c.surface },
    StatusLineNC = { fg = c.fg_variant, bg = c.surface },
    TabLine = { fg = c.fg_variant, bg = c.surface },
    TabLineFill = { bg = c.surface_dim },
    TabLineSel = { fg = c.primary, bg = c.surface_high, style = STYLES.bold },

    -- Line numbers
    LineNr = { fg = c.outline },
    CursorLineNr = { fg = c.primary, style = STYLES.bold },
    CursorLine = { bg = c.surface },

    -- Visual and search
    Visual = { bg = colors.secondary_container },
    Search = { fg = colors.on_primary_container, bg = colors.primary_container },
    IncSearch = { fg = colors.on_primary_container, bg = colors.primary_container, style = STYLES.bold },

    -- Popup menu
    Pmenu = { fg = c.fg, bg = c.surface_low },
    PmenuSel = { fg = colors.on_primary_container, bg = colors.primary_container },
    PmenuSbar = { bg = c.surface_low },
    PmenuThumb = { bg = c.primary },

    -- Messages
    ErrorMsg = { fg = colors.on_error_container, bg = colors.error_container },
    WarningMsg = { fg = colors.on_tertiary_container, bg = colors.tertiary_container },
    ModeMsg = { fg = c.primary, style = STYLES.bold },

    -- Folding
    Folded = { fg = c.fg_variant, bg = c.surface, style = STYLES.italic },
    FoldColumn = { fg = c.outline },
    SignColumn = { bg = "NONE" },
  }

  -- Diagnostics
  local diagnostic_groups = {
    { "Error", c.error },
    { "Warn", c.warning },
    { "Info", c.info },
    { "Hint", c.hint },
  }

  for _, diag in ipairs(diagnostic_groups) do
    local name, color = diag[1], diag[2]
    highlights["Diagnostic" .. name] = { fg = color }
    highlights["DiagnosticSign" .. name] = { fg = color }
    highlights["DiagnosticVirtualText" .. name] = { fg = color, style = STYLES.italic }
    highlights["DiagnosticUnderline" .. name] = { sp = color, style = STYLES.underline }
  end

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
