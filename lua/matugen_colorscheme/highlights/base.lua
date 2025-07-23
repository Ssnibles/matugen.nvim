local utils = require("matugen_colorscheme.utils")
local brighten = utils.brighten_hex

local M = {}

--- Applies base Neovim highlight groups.
--- @param colors table The table of colors parsed from Matugen.
--- @param config table The plugin's configuration table (optional).
--- @param set_hl function Helper function to set highlight groups (group, fg, bg, style).
function M.apply(colors, config, set_hl)
  --- Helper to apply multiple highlight groups from a table.
  --- @param highlights table A table where keys are highlight groups, and values are {fg, bg, style}.
  local function apply_highlights(highlights)
    for group, params in pairs(highlights) do
      set_hl(group, params[1], params[2], params[3])
    end
  end

  -- Declare semantic aliases for colors to improve readability and reduce repetition.
  local fg = colors.on_surface
  local bg = colors.background
  local brighten_bg = brighten(bg, 20) -- Brighten background by 20%.
  local accent = colors.primary
  local accent_bg = colors.primary_container
  local sub_fg = colors.on_surface_variant
  local sub_bg = colors.surface_container_high
  local dim_bg = colors.surface_dim
  local dim_fg = colors.outline_variant
  local error_fg = colors.error
  local error_bg = colors.error_container
  local warn_fg = colors.primary_fixed_dim
  local info_fg = colors.tertiary
  local hint_fg = colors.outline

  -- Define common styles.
  local bold = "bold"
  local italic = "italic"
  local underline = "underline"

  -- Apply base UI highlights.
  apply_highlights({
    --------------------------------------------------------------------
    -- Base UI Elements
    --------------------------------------------------------------------
    ["Normal"] = { fg, bg },
    ["NormalNC"] = { fg, dim_bg },
    ["NormalFloat"] = { fg, colors.surface_container_low },
    ["FloatBorder"] = { dim_fg, colors.surface_container_low },
    ["Comment"] = { dim_fg, nil, italic },
    ["Todo"] = { colors.on_primary_container, accent_bg, bold },
    ["ErrorMsg"] = { colors.on_error_container, error_bg, bold },
    ["WarningMsg"] = { colors.on_primary_container, accent_bg, bold },
    ["ModeMsg"] = { colors.primary_fixed, nil, bold },
    ["NonText"] = { dim_fg, nil },
    ["SpecialKey"] = { dim_fg, nil },
    ["Conceal"] = { dim_fg, nil },

    --------------------------------------------------------------------
    -- Statusline & Tabs
    --------------------------------------------------------------------
    ["StatusLine"] = { colors.on_primary_container, brighten_bg },
    ["StatusLineNC"] = { sub_fg, accent_bg },
    ["TabLine"] = { sub_fg, colors.surface_container_highest },
    ["TabLineFill"] = { dim_bg, nil },
    ["TabLineSel"] = { colors.on_primary_container, accent_bg, bold },

    --------------------------------------------------------------------
    -- Line Numbers & Cursor Line
    --------------------------------------------------------------------
    ["LineNr"] = { dim_fg, "NONE" },
    ["CursorLine"] = { nil, sub_fg },
    ["CursorLineNr"] = { colors.primary_fixed, "NONE", bold },

    --------------------------------------------------------------------
    -- Visual Modes & Search
    --------------------------------------------------------------------
    ["Visual"] = { nil, colors.secondary_container },
    ["Search"] = { colors.on_primary_container, accent_bg, bold },
    ["IncSearch"] = { colors.on_primary_container, accent_bg, bold .. "," .. underline },

    --------------------------------------------------------------------
    -- Folded & Sign Column
    --------------------------------------------------------------------
    ["Folded"] = { sub_fg, sub_bg, italic },
    ["SignColumn"] = { nil, "NONE" },

    --------------------------------------------------------------------
    -- Popup Menu (Completion)
    --------------------------------------------------------------------
    ["Pmenu"] = { fg, colors.surface_container_highest },
    ["PmenuSel"] = { colors.on_primary_container, accent_bg },
    ["PmenuSbar"] = { nil, colors.surface_container_highest },
    ["PmenuThumb"] = { nil, accent },

    --------------------------------------------------------------------
    -- Diagnostics
    --------------------------------------------------------------------
    ["DiagnosticError"] = { error_fg, nil, bold },
    ["DiagnosticWarn"] = { warn_fg, nil, bold },
    ["DiagnosticInfo"] = { info_fg, nil }, -- You already have this
    ["DiagnosticHint"] = { hint_fg, nil },

    ["DiagnosticUnderlineError"] = { nil, nil, underline },
    ["DiagnosticUnderlineWarn"] = { nil, nil, underline },
    ["DiagnosticUnderlineInfo"] = { nil, nil, underline }, -- You already have this
    ["DiagnosticUnderlineHint"] = { nil, nil, underline },

    -- Add these for virtual text and signs
    ["DiagnosticVirtualTextInfo"] = { info_fg, nil, italic }, -- Or just { info_fg }
    ["DiagnosticVirtualTextWarn"] = { warn_fg, nil, italic },
    ["DiagnosticVirtualTextError"] = { error_fg, nil, italic },
    ["DiagnosticVirtualTextHint"] = { hint_fg, nil, italic },

    ["DiagnosticSignInfo"] = { info_fg, nil },
    ["DiagnosticSignWarn"] = { warn_fg, nil },
    ["DiagnosticSignError"] = { error_fg, nil },
    ["DiagnosticSignHint"] = { hint_fg, nil },
    --------------------------------------------------------------------
    -- Git Gutter / Sign Column
    --------------------------------------------------------------------
    ["GitGutterAdd"] = { colors.tertiary_fixed, nil },
    ["GitGutterChange"] = { colors.primary_fixed, nil },
    ["GitGutterDelete"] = { error_fg, nil },

    --------------------------------------------------------------------
    -- Common Syntax Groups
    --------------------------------------------------------------------
    -- Keywords and Statements
    ["Keyword"] = { colors.primary_fixed, nil, bold },
    ["Statement"] = { colors.primary_fixed, nil, bold },
    ["Conditional"] = { colors.primary_fixed, nil, bold },
    ["Repeat"] = { colors.primary_fixed, nil, bold },
    ["Label"] = { colors.tertiary_fixed, nil, bold },
    ["Operator"] = { colors.tertiary_fixed, nil, bold },
    ["PreProc"] = { colors.tertiary_fixed, nil },
    ["Include"] = { colors.primary_fixed, nil, bold },
    ["Define"] = { colors.primary_fixed, nil, bold },
    ["Exception"] = { error_fg, nil, bold },
    ["PreCondit"] = { colors.primary_fixed, nil },
    ["StorageClass"] = { colors.tertiary_fixed, nil, bold },
    ["Structure"] = { colors.tertiary_fixed, nil, bold },
    ["Typedef"] = { colors.tertiary_fixed, nil, bold },
    ["Macro"] = { colors.tertiary_fixed, nil, bold },

    -- Identifiers, Functions, Types
    ["Identifier"] = { fg, nil },
    ["Function"] = { colors.secondary_fixed, nil, bold },
    ["Type"] = { colors.tertiary_fixed, nil, bold },

    -- Literals (Strings, Numbers, Booleans, etc.)
    ["Character"] = { colors.tertiary_fixed_dim, nil },
    ["String"] = { colors.secondary_fixed_dim, nil },
    ["Number"] = { colors.tertiary_fixed_dim, nil, bold },
    ["Boolean"] = { colors.primary_fixed_dim, nil, bold },
    ["Float"] = { colors.tertiary_fixed_dim, nil, bold },
    ["Constant"] = { colors.primary_fixed_dim, nil, bold },

    -- Miscellaneous
    ["Delimiter"] = { dim_fg, nil },
    ["Title"] = { colors.primary_fixed, nil, bold },
    ["Underlined"] = { colors.primary_fixed, nil, underline },
    ["Error"] = { error_fg, nil, bold },
    ["Debug"] = { colors.tertiary_fixed, nil },
    ["Special"] = { colors.secondary_fixed, nil, bold },
    ["SpecialChar"] = { colors.tertiary_fixed, nil },
    ["Tag"] = { colors.secondary_fixed, nil, bold },
  })
end

return M
