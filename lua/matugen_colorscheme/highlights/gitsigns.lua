local utils = require("matugen_colorscheme.utils")
local brighten = utils.brighten_hex

local M = {}

--- Applies GitSigns highlight groups
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
    add = colors.tertiary_fixed or "NONE",
    change = colors.primary_fixed or "NONE",
    delete = colors.error or "NONE",
    add_dim = colors.tertiary_fixed_dim or "NONE",
    change_dim = colors.primary_fixed_dim or "NONE",
    delete_dim = colors.error_container or "NONE",
    surface = colors.surface_container_high or "NONE",
    outline = colors.outline or "NONE",
  }

  -- Define style presets
  local styles = {
    bold = { "bold" },
    italic = { "italic" },
    strikethrough = { "strikethrough" },
  }

  -- GitSigns highlight definitions
  local highlights = {
    --------------------------------------------------------------------
    -- Core Sign Highlights
    --------------------------------------------------------------------
    GitSignsAdd = { fg = semantic.add },
    GitSignsChange = { fg = semantic.change },
    GitSignsDelete = { fg = semantic.delete },

    --------------------------------------------------------------------
    -- Number Column Highlights
    --------------------------------------------------------------------
    GitSignsAddNr = {
      fg = semantic.add,
      style = styles.bold,
    },
    GitSignsChangeNr = {
      fg = semantic.change,
      style = styles.bold,
    },
    GitSignsDeleteNr = {
      fg = semantic.delete,
      style = styles.bold,
    },

    --------------------------------------------------------------------
    -- Line Highlights
    --------------------------------------------------------------------
    GitSignsAddLn = { bg = semantic.surface },
    GitSignsChangeLn = { bg = semantic.surface },
    GitSignsDeleteLn = { bg = semantic.surface },

    --------------------------------------------------------------------
    -- Current Line Blame
    --------------------------------------------------------------------
    GitSignsCurrentLineBlame = {
      fg = semantic.outline,
      style = styles.italic,
    },

    --------------------------------------------------------------------
    -- Deleted Line Highlights
    --------------------------------------------------------------------
    GitSignsDeleteRemoved = {
      fg = semantic.delete,
      style = styles.strikethrough,
    },

    --------------------------------------------------------------------
    -- Preview Highlights
    --------------------------------------------------------------------
    GitSignsAddPreview = {
      fg = semantic.add,
      bg = colors.tertiary_container or "NONE",
    },
    GitSignsChangePreview = {
      fg = semantic.change,
      bg = colors.primary_container or "NONE",
    },

    --------------------------------------------------------------------
    -- Untracked Files
    --------------------------------------------------------------------
    GitSignsUntracked = {
      fg = semantic.add,
      style = styles.italic,
    },

    --------------------------------------------------------------------
    -- Staged Changes
    --------------------------------------------------------------------
    GitSignsStagedAdd = {
      fg = semantic.add,
      style = styles.bold,
    },
    GitSignsStagedChange = {
      fg = semantic.change,
      style = styles.bold,
    },
    GitSignsStagedDelete = {
      fg = semantic.delete,
      style = styles.bold,
    },

    --------------------------------------------------------------------
    -- Changedelete (Combination)
    --------------------------------------------------------------------
    GitSignsChangedelete = {
      fg = semantic.change,
      bg = colors.primary_container or "NONE",
    },

    --------------------------------------------------------------------
    -- Top of Screen Delete Indicator
    --------------------------------------------------------------------
    GitSignsTopdelete = {
      fg = semantic.delete,
      bg = semantic.delete_dim,
      style = styles.bold,
    },
  }

  apply_highlights(highlights)
end

return M
