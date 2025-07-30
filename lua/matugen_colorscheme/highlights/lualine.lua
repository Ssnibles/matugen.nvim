local M = {}

function M.apply(colors, config, set_hl)
  local bold = { "bold" }

  local C = {
    primary = colors.primary or "#F5BD62",
    primary_container = colors.primary_container or "#604100",
    on_primary_container = colors.on_primary_container or "#FFDDAE",

    secondary = colors.secondary or "#C6C2EA",
    secondary_container = colors.secondary_container or "#454364",
    on_secondary_container = colors.on_secondary_container or "#E3DFFF",

    tertiary = colors.tertiary or "#8ED1DF",
    tertiary_container = colors.tertiary_container or "#004E5A",
    on_tertiary_container = colors.on_tertiary_container or "#AAEDFC",

    error = colors.error or "#FFB4AB",
    error_container = colors.error_container or "#93000A",
    on_error_container = colors.on_error_container or "#FFDAD6",

    surface = colors.surface or "#0C1517",
    on_surface = colors.on_surface or "#DBE4E7",
    surface_variant = colors.on_surface_variant or "#B8C9CE",
    container_high = colors.surface_container_high or "#232B2D",
    container_highest = colors.surface_container_highest or "#2D3638",
    container_low = colors.surface_container_low or "#141D1F",

    outline = colors.outline or "#839498",
  }

  -- Active
  set_hl("lualine_a_normal", { fg = C.primary, bg = C.primary_container, style = bold })
  set_hl("lualine_b_normal", { fg = C.on_primary_container, bg = C.container_high })
  set_hl("lualine_c_normal", { fg = C.on_surface, bg = C.container_low })

  -- Inactive
  set_hl("lualine_a_inactive", { fg = C.surface_variant, bg = C.container_highest })
  set_hl("lualine_b_inactive", { fg = C.surface_variant, bg = C.container_high })
  set_hl("lualine_c_inactive", { fg = C.outline, bg = C.container_low })

  -- Insert
  set_hl("lualine_a_insert", { fg = C.on_secondary_container, bg = C.secondary_container, style = bold })

  -- Visual
  set_hl("lualine_a_visual", { fg = C.on_tertiary_container, bg = C.tertiary_container, style = bold })

  -- Replace
  set_hl("lualine_a_replace", { fg = C.on_error_container, bg = C.error_container, style = bold })

  -- Command
  set_hl("lualine_a_command", { fg = C.on_primary_container, bg = C.primary_container, style = bold })

  -- Terminal
  set_hl("lualine_a_terminal", { fg = C.on_tertiary_container, bg = C.tertiary_container, style = bold })

  -- Diagnostics
  set_hl("lualine_diagnostics_error_normal", { fg = C.error, bg = C.container_high })
  set_hl("lualine_diagnostics_warn_normal", { fg = C.primary, bg = C.container_high })
  set_hl("lualine_diagnostics_info_normal", { fg = C.tertiary, bg = C.container_high })
  set_hl("lualine_diagnostics_hint_normal", { fg = C.outline, bg = C.container_high })

  -- Diff
  set_hl("lualine_diff_added_normal", { fg = colors.tertiary_fixed or "#AAEDFC", bg = C.container_high })
  set_hl("lualine_diff_modified_normal", { fg = C.primary, bg = C.container_high })
  set_hl("lualine_diff_removed_normal", { fg = C.error, bg = C.container_high })

  -- Misc
  set_hl("lualine_filename_normal", { fg = C.on_surface, bg = C.container_low })
  set_hl("lualine_location_normal", { fg = C.primary, bg = C.primary_container, style = bold })
  set_hl("lualine_progress_normal", { fg = C.primary, bg = C.primary_container })
end

return M
