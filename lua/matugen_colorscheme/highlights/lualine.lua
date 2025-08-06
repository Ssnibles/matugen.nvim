local M = {}

-- Style combinations for consistency
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  bold_italic = { "bold", "italic" },
}

--- Apply Lualine highlights with Material You design principles
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Clean semantic color mapping
  local c = {
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

    -- Surface system
    surface = colors.surface,
    on_surface = colors.on_surface,
    on_surface_variant = colors.on_surface_variant,
    surface_container = colors.surface_container,
    surface_container_high = colors.surface_container_high,
    surface_container_highest = colors.surface_container_highest,

    -- Outline system
    outline = colors.outline,
    outline_variant = colors.outline_variant,
  }

  -- Core lualine highlights
  local highlights = {}

  -- Mode-specific section A highlights (most prominent)
  local mode_configs = {
    normal = { fg = c.on_primary, bg = c.primary },
    insert = { fg = c.on_secondary, bg = c.secondary },
    visual = { fg = c.on_tertiary, bg = c.tertiary },
    replace = { fg = c.on_error_container, bg = c.error_container },
    command = { fg = c.on_primary_container, bg = c.primary_container },
    terminal = { fg = c.on_tertiary_container, bg = c.tertiary_container },
  }

  -- Generate section A highlights for each mode
  for mode, colors_config in pairs(mode_configs) do
    highlights["lualine_a_" .. mode] = {
      fg = colors_config.fg,
      bg = colors_config.bg,
      style = STYLES.bold,
    }
  end

  -- Section B highlights (medium prominence)
  for mode, _ in pairs(mode_configs) do
    highlights["lualine_b_" .. mode] = {
      fg = c.on_surface,
      bg = c.surface_container_high,
    }
  end

  -- Section C highlights (least prominence)
  for mode, _ in pairs(mode_configs) do
    highlights["lualine_c_" .. mode] = {
      fg = c.on_surface_variant,
      bg = c.surface_container,
    }
  end

  -- Inactive window highlights
  highlights.lualine_a_inactive = {
    fg = c.outline,
    bg = c.surface_container_highest,
  }
  highlights.lualine_b_inactive = {
    fg = c.outline_variant,
    bg = c.surface_container_high,
  }
  highlights.lualine_c_inactive = {
    fg = c.outline_variant,
    bg = c.surface_container,
  }

  -- Diagnostic highlights for lualine
  local diagnostic_configs = {
    error = c.error,
    warn = c.tertiary,
    info = c.secondary,
    hint = c.outline,
  }

  for diagnostic, color in pairs(diagnostic_configs) do
    highlights["lualine_diagnostics_" .. diagnostic .. "_normal"] = {
      fg = color,
      bg = c.surface_container_high,
    }
    highlights["lualine_diagnostics_" .. diagnostic .. "_inactive"] = {
      fg = color,
      bg = c.surface_container,
    }
  end

  -- Git diff highlights
  highlights.lualine_diff_added_normal = {
    fg = c.primary,
    bg = c.surface_container_high,
  }
  highlights.lualine_diff_modified_normal = {
    fg = c.tertiary,
    bg = c.surface_container_high,
  }
  highlights.lualine_diff_removed_normal = {
    fg = c.error,
    bg = c.surface_container_high,
  }

  -- Inactive diff highlights
  highlights.lualine_diff_added_inactive = {
    fg = c.outline,
    bg = c.surface_container,
  }
  highlights.lualine_diff_modified_inactive = {
    fg = c.outline,
    bg = c.surface_container,
  }
  highlights.lualine_diff_removed_inactive = {
    fg = c.outline,
    bg = c.surface_container,
  }

  -- Component-specific highlights
  highlights.lualine_filename_normal = {
    fg = c.on_surface,
    bg = c.surface_container,
  }
  highlights.lualine_filename_inactive = {
    fg = c.outline_variant,
    bg = c.surface_container,
  }

  highlights.lualine_branch_normal = {
    fg = c.primary,
    bg = c.surface_container_high,
    style = STYLES.bold,
  }
  highlights.lualine_branch_inactive = {
    fg = c.outline,
    bg = c.surface_container,
  }

  highlights.lualine_location_normal = {
    fg = c.on_primary,
    bg = c.primary,
    style = STYLES.bold,
  }
  highlights.lualine_progress_normal = {
    fg = c.on_primary_container,
    bg = c.primary_container,
  }

  highlights.lualine_filetype_normal = {
    fg = c.on_surface_variant,
    bg = c.surface_container_high,
  }
  highlights.lualine_encoding_normal = {
    fg = c.outline,
    bg = c.surface_container_high,
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
