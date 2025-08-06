local M = {}

-- Style combinations for reuse
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  strikethrough = { "strikethrough" },
  bold_italic = { "bold", "italic" },
}

--- Apply GitSigns highlights
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Semantic color mapping for git operations
  local c = {
    -- Primary git colors
    add = colors.tertiary_fixed or colors.tertiary,
    change = colors.primary_fixed or colors.primary,
    delete = colors.error,

    -- Dimmed variants
    add_dim = colors.tertiary_fixed_dim or colors.tertiary_container,
    change_dim = colors.primary_fixed_dim or colors.primary_container,
    delete_dim = colors.error_container,

    -- UI colors
    surface = colors.surface_container_high or colors.surface,
    outline = colors.outline_variant or colors.outline,

    -- Container colors for previews
    add_container = colors.tertiary_container,
    change_container = colors.primary_container,
  }

  -- Base git sign highlights
  local base_signs = {
    { name = "Add", color = c.add },
    { name = "Change", color = c.change },
    { name = "Delete", color = c.delete },
  }

  local highlights = {}

  -- Generate core sign highlights
  for _, sign in ipairs(base_signs) do
    local name, color = sign.name, sign.color

    -- Basic signs
    highlights["GitSigns" .. name] = { fg = color }

    -- Number column signs (bold)
    highlights["GitSigns" .. name .. "Nr"] = { fg = color, style = STYLES.bold }

    -- Line highlights (subtle background)
    highlights["GitSigns" .. name .. "Ln"] = { bg = c.surface }

    -- Staged changes (bold)
    highlights["GitSignsStaged" .. name] = { fg = color, style = STYLES.bold }
  end

  -- Special git highlights
  local special_highlights = {
    -- Current line blame
    GitSignsCurrentLineBlame = { fg = c.outline, style = STYLES.italic },

    -- Deleted content styling
    GitSignsDeleteRemoved = { fg = c.delete, style = STYLES.strikethrough },

    -- Preview highlights
    GitSignsAddPreview = { fg = c.add, bg = c.add_container },
    GitSignsChangePreview = { fg = c.change, bg = c.change_container },

    -- Untracked files
    GitSignsUntracked = { fg = c.add, style = STYLES.italic },

    -- Combined change/delete
    GitSignsChangedelete = { fg = c.change, bg = c.change_container },

    -- Top delete indicator
    GitSignsTopdelete = { fg = c.delete, bg = c.delete_dim, style = STYLES.bold },

    -- Additional useful highlights
    GitSignsAddInline = { fg = c.add, bg = c.add_dim },
    GitSignsChangeInline = { fg = c.change, bg = c.change_dim },
    GitSignsDeleteInline = { fg = c.delete, bg = c.delete_dim },
  }

  -- Merge special highlights
  for group, opts in pairs(special_highlights) do
    highlights[group] = opts
  end

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
