local M = {}
local utils = require("matugen_colorscheme.utils")

-- Style combinations for consistency
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  underline = { "underline" },
  undercurl = { "undercurl" },
  bold_italic = { "bold", "italic" },
}

--- Apply miscellaneous plugin highlights
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Create semantic color shortcuts
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
    on_secondary = colors.on_secondary,
    on_secondary_container = colors.on_secondary_container,

    -- Tertiary system
    tertiary = colors.tertiary,
    tertiary_container = colors.tertiary_container,
    on_tertiary = colors.on_tertiary,
    on_tertiary_container = colors.on_tertiary_container,

    -- Error system
    error = colors.error,
    error_container = colors.error_container,
    on_error_container = colors.on_error_container,

    -- Surface hierarchy
    surface = colors.surface,
    surface_high = colors.surface_container_high,

    -- Outline system
    outline_variant = colors.outline_variant,
    on_surface_variant = colors.on_surface_variant,

    -- Brightened backgrounds for context differentiation
    bg_bright = utils.brighten_hex(colors.background, 12), -- Increased brightness
    bg_brighter = utils.brighten_hex(colors.background, 20),
  }

  local highlights = {
    -- === TREESITTER CONTEXT (Multiple possible group names) ===
    TreesitterContext = { bg = c.bg_bright },
    TreesitterContextLineNumber = { fg = c.primary, bg = c.bg_bright, style = STYLES.bold },
    TreesitterContextSeparator = { fg = c.outline_variant },
    TreesitterContextBottom = { sp = c.outline_variant, style = STYLES.underline },

    -- Alternative names
    ["@context"] = { bg = c.bg_bright },
    ["@context.builtin"] = { bg = c.bg_bright },
    TSContext = { bg = c.bg_bright },
    TSContextLineNumber = { fg = c.primary, bg = c.bg_bright, style = STYLES.bold },

    -- Nvim-treesitter-context (the actual plugin)
    TreesitterContextLineNumberBottom = { fg = c.primary, bg = c.bg_bright },

    -- === WORD HIGHLIGHTING / HOVER PLUGINS ===

    -- LSP Document Highlight (when hovering over symbols)
    LspReferenceText = { bg = c.bg_bright },
    LspReferenceRead = { bg = c.bg_bright },
    LspReferenceWrite = { bg = c.bg_brighter },

    -- Illuminate plugin (word highlighting)
    IlluminatedWord = { bg = c.bg_bright },
    IlluminatedCurWord = { bg = c.bg_bright },
    IlluminatedWordText = { bg = c.bg_bright },
    IlluminatedWordRead = { bg = c.bg_bright },
    IlluminatedWordWrite = { bg = c.bg_brighter },

    -- vim-illuminate
    illuminatedWord = { bg = c.bg_bright },
    illuminatedCurWord = { bg = c.bg_bright },

    -- Cursorword plugins
    CursorWord = { bg = c.bg_bright },
    CursorWord0 = { bg = c.bg_bright },
    CursorWord1 = { bg = c.bg_bright },

    -- Searchlight or similar plugins
    SearchLight = { bg = c.bg_bright },

    -- Generic word under cursor
    WordUnderCursor = { bg = c.bg_bright },

    -- === MINI.NVIM PLUGINS ===

    -- Mini.keyclue (unified styling)
    MiniClueTitle = { fg = c.primary, bg = c.surface_high, style = STYLES.bold },
    MiniClueDescGroup = { fg = c.secondary, bg = c.surface_high },
    MiniClueDescSingle = { fg = c.fg, bg = c.surface_high },
    MiniClueNextKey = { fg = c.tertiary, bg = c.surface_high, style = STYLES.bold },
    MiniClueNextKeyWithPostkeys = { fg = c.tertiary, bg = c.surface_high, style = STYLES.bold },
    MiniClueSeparator = { fg = c.outline_variant, bg = c.surface_high },
    MiniClueBackground = { bg = c.surface_high },

    -- Mini.cursorword (this might be your word hover plugin)
    MiniCursorword = { bg = c.bg_bright },
    MiniCursorwordCurrent = { bg = c.bg_bright },

    -- Mini.picker
    MiniPickerBorder = { fg = c.outline_variant, bg = c.surface_high },
    MiniPickerPrompt = { fg = c.fg, bg = c.surface_high },
    MiniPickerMatchCurrent = { fg = c.on_primary_container, bg = c.primary_container },
    MiniPickerMatchMarked = { fg = c.on_secondary_container, bg = c.secondary_container },
    MiniPickerHeader = { fg = c.primary, bg = c.surface_high, style = STYLES.bold },

    -- Mini.statusline
    MiniStatuslineDevinfo = { fg = c.fg, bg = c.surface_high },
    MiniStatuslineFileinfo = { fg = c.fg, bg = c.surface_high },
    MiniStatuslineFilename = { fg = c.fg, bg = c.surface_high },
    MiniStatuslineInactive = { fg = c.on_surface_variant, bg = c.surface },
    MiniStatuslineModeCommand = { fg = c.on_primary, bg = c.primary, style = STYLES.bold },
    MiniStatuslineModeInsert = { fg = c.on_secondary, bg = c.secondary, style = STYLES.bold },
    MiniStatuslineModeNormal = { fg = c.on_primary_container, bg = c.primary_container, style = STYLES.bold },
    MiniStatuslineModeOther = { fg = c.on_tertiary_container, bg = c.tertiary_container, style = STYLES.bold },
    MiniStatuslineModeReplace = { fg = c.on_error_container, bg = c.error_container, style = STYLES.bold },
    MiniStatuslineModeVisual = { fg = c.on_tertiary, bg = c.tertiary, style = STYLES.bold },

    -- === ENHANCED FLOATING WINDOWS ===
    FloatBorder = { fg = c.outline_variant, bg = c.surface_high },
    FloatTitle = { fg = c.primary, bg = c.surface_high, style = STYLES.bold },
    FloatFooter = { fg = c.on_surface_variant, bg = c.surface_high },

    -- === OTHER COMMON WORD/REFERENCE HIGHLIGHTING ===
    -- Vim's built-in matchparen equivalent for words
    MatchWord = { bg = c.bg_bright },

    -- Some plugins use these
    CurrentWord = { bg = c.bg_bright },
    MatchedChar = { bg = c.bg_bright },
    MatchedWord = { bg = c.bg_bright },

    -- === DEBUGGING HIGHLIGHTS (to see what's being applied) ===
    -- Uncomment these temporarily to see if they work:
    -- DebugTest1 = { bg = "#FF0000" }, -- Bright red for testing
    -- DebugTest2 = { bg = "#00FF00" }, -- Bright green for testing
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
