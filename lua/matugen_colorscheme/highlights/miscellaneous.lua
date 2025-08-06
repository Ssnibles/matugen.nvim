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
    bg_bright = utils.brighten_hex(colors.background, 8),
    bg_brighter = utils.brighten_hex(colors.background, 15),
  }

  local highlights = {
    -- === TREESITTER CONTEXT ===
    TreesitterContext = { bg = c.bg_bright },
    TreesitterContextLineNumber = { fg = c.primary, bg = c.bg_bright, style = STYLES.bold },
    TreesitterContextSeparator = { fg = c.outline_variant },
    TreesitterContextBottom = { sp = c.outline_variant, style = STYLES.underline },

    -- === MINI.NVIM PLUGINS ===

    -- Mini.keyclue (unified styling)
    MiniClueTitle = { fg = c.primary, bg = c.surface_high, style = STYLES.bold },
    MiniClueDescGroup = { fg = c.secondary, bg = c.surface_high },
    MiniClueDescSingle = { fg = c.fg, bg = c.surface_high },
    MiniClueNextKey = { fg = c.tertiary, bg = c.surface_high, style = STYLES.bold },
    MiniClueNextKeyWithPostkeys = { fg = c.tertiary, bg = c.surface_high, style = STYLES.bold },
    MiniClueSeparator = { fg = c.outline_variant, bg = c.surface_high },
    MiniClueBackground = { bg = c.surface_high },

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

    -- Mini.files
    MiniFilesFile = { fg = c.fg },
    MiniFilesDirectory = { fg = c.primary, style = STYLES.bold },
    MiniFilesBorder = { fg = c.outline_variant, bg = c.surface_high },
    MiniFilesCursorLine = { bg = c.primary_container },
    MiniFilesNormal = { fg = c.fg, bg = c.surface_high },
    MiniFilesTitle = { fg = c.primary, bg = c.surface_high, style = STYLES.bold },

    -- Mini.completion
    MiniCompletionActiveParameter = { style = STYLES.underline },

    -- Mini.cursorword
    MiniCursorword = { bg = c.bg_bright },
    MiniCursorwordCurrent = { bg = c.bg_bright },

    -- Mini.indentscope
    MiniIndentscopeSymbol = { fg = c.outline_variant },
    MiniIndentscopePrefix = { style = { "nocombine" } },

    -- Mini.jump
    MiniJump = { fg = c.on_primary, bg = c.primary, style = STYLES.bold },

    -- Mini.map
    MiniMapNormal = { fg = c.fg, bg = c.surface_high },
    MiniMapSymbolCount = { fg = c.secondary },
    MiniMapSymbolLine = { fg = c.primary },
    MiniMapSymbolView = { fg = c.tertiary },

    -- Mini.notify
    MiniNotifyBorder = { fg = c.outline_variant, bg = c.surface_high },
    MiniNotifyNormal = { fg = c.fg, bg = c.surface_high },
    MiniNotifyTitle = { fg = c.primary, bg = c.surface_high, style = STYLES.bold },

    -- Mini.starter
    MiniStarterCurrent = { style = { "nocombine" } },
    MiniStarterFooter = { fg = c.on_surface_variant, style = STYLES.italic },
    MiniStarterHeader = { fg = c.primary, style = STYLES.bold },
    MiniStarterInactive = { fg = c.outline_variant },
    MiniStarterItem = { fg = c.fg },
    MiniStarterItemBullet = { fg = c.secondary },
    MiniStarterItemPrefix = { fg = c.tertiary },
    MiniStarterSection = { fg = c.primary, style = STYLES.bold },
    MiniStarterQuery = { fg = c.secondary },

    -- Mini.surround
    MiniSurround = { fg = c.on_primary, bg = c.primary },

    -- Mini.tabline
    MiniTablineCurrent = { fg = c.on_primary_container, bg = c.primary_container, style = STYLES.bold },
    MiniTablineFill = { bg = c.surface },
    MiniTablineHidden = { fg = c.on_surface_variant, bg = c.surface },
    MiniTablineModifiedCurrent = { fg = c.tertiary, bg = c.primary_container, style = STYLES.bold },
    MiniTablineModifiedHidden = { fg = c.tertiary, bg = c.surface },
    MiniTablineModifiedVisible = { fg = c.tertiary, bg = c.surface_high },
    MiniTablineTabpagesection = { fg = c.on_secondary_container, bg = c.secondary_container },
    MiniTablineVisible = { fg = c.fg, bg = c.surface_high },

    -- Mini.test
    MiniTestEmphasis = { style = STYLES.bold },
    MiniTestFail = { fg = c.error, style = STYLES.bold },
    MiniTestPass = { fg = c.primary, style = STYLES.bold },

    -- Mini.trailspace
    MiniTrailspace = { bg = c.error },

    -- === ENHANCED FLOATING WINDOWS ===
    FloatBorder = { fg = c.outline_variant, bg = c.surface_high },
    FloatTitle = { fg = c.primary, bg = c.surface_high, style = STYLES.bold },
    FloatFooter = { fg = c.on_surface_variant, bg = c.surface_high },

    -- === NVIM-NOTIFY (if using) ===
    NotifyBackground = { bg = c.surface_high },
    NotifyERRORBorder = { fg = c.error },
    NotifyWARNBorder = { fg = c.tertiary },
    NotifyINFOBorder = { fg = c.secondary },
    NotifyDEBUGBorder = { fg = c.outline_variant },
    NotifyTRACEBorder = { fg = c.outline_variant },
    NotifyERRORIcon = { fg = c.error },
    NotifyWARNIcon = { fg = c.tertiary },
    NotifyINFOIcon = { fg = c.secondary },
    NotifyDEBUGIcon = { fg = c.outline_variant },
    NotifyTRACEIcon = { fg = c.outline_variant },
    NotifyERRORTitle = { fg = c.error, style = STYLES.bold },
    NotifyWARNTitle = { fg = c.tertiary, style = STYLES.bold },
    NotifyINFOTitle = { fg = c.secondary, style = STYLES.bold },
    NotifyDEBUGTitle = { fg = c.outline_variant, style = STYLES.bold },
    NotifyTRACETitle = { fg = c.outline_variant, style = STYLES.bold },

    -- === WHICH-KEY (if using) ===
    WhichKey = { fg = c.primary, style = STYLES.bold },
    WhichKeyDesc = { fg = c.fg },
    WhichKeyGroup = { fg = c.secondary, style = STYLES.bold },
    WhichKeySeperator = { fg = c.outline_variant },
    WhichKeyFloat = { bg = c.surface_high },
    WhichKeyBorder = { fg = c.outline_variant, bg = c.surface_high },
    WhichKeyValue = { fg = c.tertiary },
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
