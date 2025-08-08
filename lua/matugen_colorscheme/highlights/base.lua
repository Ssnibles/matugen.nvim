local M = {}
local utils = require("matugen_colorscheme.utils")

-- Style combinations for reuse - converted to proper format
local STYLES = {
  bold = { bold = true },
  italic = { italic = true },
  underline = { underline = true },
  undercurl = { undercurl = true },
  bold_italic = { bold = true, italic = true },
}

--- Safely get color with fallback
--- @param colors table
--- @param key string
--- @param fallback string
--- @return string
local function safe_color(colors, key, fallback)
  return colors[key] or fallback or "#ffffff"
end

--- Merge style tables
--- @param base_style table|nil
--- @param additional_style table|nil
--- @return table
local function merge_styles(base_style, additional_style)
  local result = {}

  if base_style then
    for k, v in pairs(base_style) do
      result[k] = v
    end
  end

  if additional_style then
    for k, v in pairs(additional_style) do
      result[k] = v
    end
  end

  return result
end

--- Create highlight definition with proper style handling
--- @param fg string|nil
--- @param bg string|nil
--- @param style table|nil
--- @param sp string|nil
--- @return table
local function create_hl(fg, bg, style, sp)
  local hl = {}

  if fg then
    hl.fg = fg
  end
  if bg then
    hl.bg = bg
  end
  if sp then
    hl.sp = sp
  end

  -- Merge style properties directly into the highlight table
  if style then
    hl = merge_styles(hl, style)
  end

  return hl
end

--- Apply base highlights
--- @param colors table
--- @param config table
--- @param set_hl function
function M.apply(colors, config, set_hl)
  -- Validate colors table
  if not colors then
    vim.notify("Colors table is nil in base.apply", vim.log.levels.ERROR)
    return
  end

  -- Create semantic color shortcuts with safe fallbacks
  local c = {
    -- Base colors
    fg = safe_color(colors, "on_surface", "#e6e1e5"),
    bg = safe_color(colors, "background", "#141218"),

    -- Primary system
    primary = safe_color(colors, "primary", "#d0bcff"),
    primary_container = safe_color(colors, "primary_container", "#4f378b"),
    on_primary = safe_color(colors, "on_primary", "#371e73"),
    on_primary_container = safe_color(colors, "on_primary_container", "#eaddff"),

    -- Secondary system
    secondary = safe_color(colors, "secondary", "#ccc2dc"),
    secondary_container = safe_color(colors, "secondary_container", "#4a4458"),
    on_secondary_container = safe_color(colors, "on_secondary_container", "#e8def8"),

    -- Tertiary system
    tertiary = safe_color(colors, "tertiary", "#efb8c8"),
    tertiary_container = safe_color(colors, "tertiary_container", "#633b48"),
    on_tertiary_container = safe_color(colors, "on_tertiary_container", "#ffd8e4"),

    -- Error system
    error = safe_color(colors, "error", "#f2b8b5"),
    error_container = safe_color(colors, "error_container", "#8c1d18"),
    on_error_container = safe_color(colors, "on_error_container", "#f9dedc"),

    -- Surface hierarchy
    surface = safe_color(colors, "surface", "#1d1b20"),
    surface_dim = safe_color(colors, "surface_dim", "#141218"),
    surface_bright = safe_color(colors, "surface_bright", "#3b383e"),
    surface_low = safe_color(colors, "surface_container_low", "#1d1b20"),
    surface_high = safe_color(colors, "surface_container_high", "#2b2930"),
    surface_highest = safe_color(colors, "surface_container_highest", "#36343b"),

    -- Outline system
    outline = safe_color(colors, "outline", "#938f99"),
    outline_variant = safe_color(colors, "outline_variant", "#49454f"),
    on_surface_variant = safe_color(colors, "on_surface_variant", "#cac4d0"),

    -- Brigtened colors
    bg_bright = utils.brighten_hex(colors.background, 20),
  }

  -- Core base highlights with proper style handling
  local highlights = {
    -- Fundamental base
    Normal = create_hl(c.fg, c.bg),
    NormalFloat = create_hl(c.fg, c.surface_high),
    NormalNC = create_hl(c.on_surface_variant, c.surface_dim),

    -- Cursor and current line
    Cursor = create_hl(c.on_primary, c.primary),
    CursorIM = create_hl(c.on_secondary_container, c.secondary_container),
    CursorLine = create_hl(nil, c.surface),
    CursorColumn = create_hl(nil, c.surface),
    ColorColumn = create_hl(nil, c.surface_dim),

    -- Line numbers
    LineNr = create_hl(c.outline_variant),
    CursorLineNr = create_hl(c.primary, nil, STYLES.bold),

    -- Comments and non-text
    Comment = create_hl(c.outline_variant, nil, STYLES.italic),
    NonText = create_hl(c.outline_variant),
    SpecialKey = create_hl(c.outline_variant),
    Whitespace = create_hl(c.outline_variant),

    -- Visual selection
    Visual = create_hl(nil, c.secondary_container),
    VisualNOS = create_hl(nil, c.secondary_container),

    -- Search
    Search = create_hl(c.on_tertiary_container, c.tertiary_container),
    IncSearch = create_hl(c.on_primary, c.primary, STYLES.bold),
    CurSearch = create_hl(c.on_primary, c.primary, STYLES.bold),
    Substitute = create_hl(c.on_error_container, c.error_container),

    -- Status line
    StatusLine = create_hl(c.on_surface, c.bg_bright),
    StatusLineNC = create_hl(c.on_surface_variant, c.surface),

    -- Window separators
    WinSeparator = create_hl(c.outline_variant),
    VertSplit = create_hl(c.outline_variant),

    -- Tabs
    TabLine = create_hl(c.on_surface_variant, c.surface),
    TabLineFill = create_hl(nil, c.surface_dim),
    TabLineSel = create_hl(c.on_primary_container, c.primary_container, STYLES.bold),

    -- Popup menu
    Pmenu = create_hl(c.on_surface, c.surface_high),
    PmenuSel = create_hl(c.on_primary_container, c.primary_container),
    PmenuSbar = create_hl(nil, c.surface_low),
    PmenuThumb = create_hl(nil, c.primary),

    -- Messages
    ErrorMsg = create_hl(c.on_error_container, c.error_container),
    WarningMsg = create_hl(c.on_tertiary_container, c.tertiary_container),
    ModeMsg = create_hl(c.primary, nil, STYLES.bold),
    MoreMsg = create_hl(c.secondary),
    Question = create_hl(c.tertiary, nil, STYLES.bold),

    -- Folding
    Folded = create_hl(c.on_surface_variant, c.surface, STYLES.italic),
    FoldColumn = create_hl(c.outline),
    SignColumn = create_hl(nil, "NONE"),

    -- Matching
    MatchParen = create_hl(c.on_primary, c.primary, STYLES.bold),

    -- Spelling
    SpellBad = create_hl(nil, nil, STYLES.undercurl, c.error),
    SpellCap = create_hl(nil, nil, STYLES.undercurl, c.tertiary),
    SpellLocal = create_hl(nil, nil, STYLES.undercurl, c.secondary),
    SpellRare = create_hl(nil, nil, STYLES.undercurl, c.outline),

    -- Wild menu
    WildMenu = create_hl(c.on_primary_container, c.primary_container),

    -- Diff
    DiffAdd = create_hl(c.on_primary_container, c.primary_container),
    DiffChange = create_hl(c.on_secondary_container, c.secondary_container),
    DiffDelete = create_hl(c.on_error_container, c.error_container),
    DiffText = create_hl(c.on_tertiary_container, c.tertiary_container, STYLES.bold),

    -- Directory
    Directory = create_hl(c.primary, nil, STYLES.bold),

    -- Title
    Title = create_hl(c.primary, nil, STYLES.bold),

    -- Conceal
    Conceal = create_hl(c.outline_variant),
  }

  -- Basic diagnostics with proper error handling
  local diagnostic_groups = {
    { "Error", c.error, c.error_container, c.on_error_container },
    { "Warn", c.tertiary, c.tertiary_container, c.on_tertiary_container },
    { "Info", c.secondary, c.secondary_container, c.on_secondary_container },
    { "Hint", c.outline, c.surface_high, c.on_surface_variant },
  }

  for _, diag in ipairs(diagnostic_groups) do
    local name, color, bg_color, fg_color = diag[1], diag[2], diag[3], diag[4]

    highlights["Diagnostic" .. name] = create_hl(color)
    highlights["DiagnosticSign" .. name] = create_hl(color, "NONE")
    highlights["DiagnosticVirtualText" .. name] = create_hl(color, bg_color, STYLES.italic)
    highlights["DiagnosticUnderline" .. name] = create_hl(nil, nil, STYLES.undercurl, color)
    highlights["DiagnosticFloating" .. name] = create_hl(fg_color, bg_color)
  end

  -- Apply all highlights with error handling
  for group, opts in pairs(highlights) do
    local success, err = pcall(set_hl, group, opts)
    if not success then
      vim.notify(string.format("Failed to set highlight %s: %s", group, err), vim.log.levels.WARN)
    end
  end
end

return M
