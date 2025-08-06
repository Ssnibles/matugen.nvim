local M = {}

-- Predefined style combination
local bold = { "bold" }

--- Applies Lualine highlight groups
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Semantic color aliases
  local C = {
    primary = colors.primary,
    primary_container = colors.primary_container,
    on_primary_container = colors.on_primary_container,

    secondary = colors.secondary,
    secondary_container = colors.secondary_container,
    on_secondary_container = colors.on_secondary_container,

    tertiary = colors.tertiary,
    tertiary_container = colors.tertiary_container,
    on_tertiary_container = colors.on_tertiary_container,

    error = colors.error,
    error_container = colors.error_container,
    on_error_container = colors.on_error_container,

    surface = colors.surface,
    on_surface = colors.on_surface,
    surface_variant = colors.on_surface_variant,
    container_high = colors.surface_container_high,
    container_highest = colors.surface_container_highest,
    container_low = colors.surface_container_low,

    outline = colors.outline,
  }

  -- Highlight definitions
  local highlights = {
    -- Active mode
    lualine_a_normal = { fg = C.primary, bg = C.primary_container, style = bold },
    lualine_b_normal = { fg = C.on_primary_container, bg = C.container_high },
    lualine_c_normal = { fg = C.on_surface, bg = C.container_low },

    -- Inactive mode
    lualine_a_inactive = { fg = C.surface_variant, bg = C.container_highest },
    lualine_b_inactive = { fg = C.surface_variant, bg = C.container_high },
    lualine_c_inactive = { fg = C.outline, bg = C.container_low },

    -- Mode-specific
    lualine_a_insert = { fg = C.on_secondary_container, bg = C.secondary_container, style = bold },
    lualine_a_visual = { fg = C.on_tertiary_container, bg = C.tertiary_container, style = bold },
    lualine_a_replace = { fg = C.on_error_container, bg = C.error_container, style = bold },
    lualine_a_command = { fg = C.on_primary_container, bg = C.primary_container, style = bold },
    lualine_a_terminal = { fg = C.on_tertiary_container, bg = C.tertiary_container, style = bold },

    -- Diagnostics
    lualine_diagnostics_error_normal = { fg = C.error, bg = C.container_high },
    lualine_diagnostics_warn_normal = { fg = C.primary, bg = C.container_high },
    lualine_diagnostics_info_normal = { fg = C.tertiary, bg = C.container_high },
    lualine_diagnostics_hint_normal = { fg = C.outline, bg = C.container_high },

    -- Diff
    lualine_diff_added_normal = { fg = colors.tertiary_fixed, bg = C.container_high },
    lualine_diff_modified_normal = { fg = C.primary, bg = C.container_high },
    lualine_diff_removed_normal = { fg = C.error, bg = C.container_high },

    -- Misc
    lualine_filename_normal = { fg = C.on_surface, bg = C.container_low },
    lualine_location_normal = { fg = C.primary, bg = C.primary_container, style = bold },
    lualine_progress_normal = { fg = C.primary, bg = C.primary_container },
  }

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
