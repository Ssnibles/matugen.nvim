local M = {}

-- Predefined style combinations
local styles = {
  bold = { "bold" },
  italic = { "italic" },
  strikethrough = { "strikethrough" },
}

--- Applies GitSigns highlight groups
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Define semantic color aliases
  local s = {
    add = colors.tertiary_fixed,
    change = colors.primary_fixed,
    delete = colors.error,
    add_dim = colors.tertiary_fixed_dim,
    change_dim = colors.primary_fixed_dim,
    delete_dim = colors.error_container,
    surface = colors.surface_container_high,
    outline = colors.outline,
  }

  -- GitSigns highlight definitions
  local highlights = {
    -- Core Sign Highlights
    GitSignsAdd = { fg = s.add },
    GitSignsChange = { fg = s.change },
    GitSignsDelete = { fg = s.delete },

    -- Number Column Highlights
    GitSignsAddNr = { fg = s.add, style = styles.bold },
    GitSignsChangeNr = { fg = s.change, style = styles.bold },
    GitSignsDeleteNr = { fg = s.delete, style = styles.bold },

    -- Line Highlights
    GitSignsAddLn = { bg = s.surface },
    GitSignsChangeLn = { bg = s.surface },
    GitSignsDeleteLn = { bg = s.surface },

    -- Current Line Blame
    GitSignsCurrentLineBlame = { fg = s.outline, style = styles.italic },

    -- Deleted Line Highlights
    GitSignsDeleteRemoved = { fg = s.delete, style = styles.strikethrough },

    -- Preview Highlights
    GitSignsAddPreview = { fg = s.add, bg = colors.tertiary_container },
    GitSignsChangePreview = { fg = s.change, bg = colors.primary_container },

    -- Untracked Files
    GitSignsUntracked = { fg = s.add, style = styles.italic },

    -- Staged Changes
    GitSignsStagedAdd = { fg = s.add, style = styles.bold },
    GitSignsStagedChange = { fg = s.change, style = styles.bold },
    GitSignsStagedDelete = { fg = s.delete, style = styles.bold },

    -- Changedelete (Combination)
    GitSignsChangedelete = { fg = s.change, bg = colors.primary_container },

    -- Top of Screen Delete Indicator
    GitSignsTopdelete = { fg = s.delete, bg = s.delete_dim, style = styles.bold },
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
