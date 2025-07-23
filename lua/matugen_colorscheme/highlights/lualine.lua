local M = {}

--- Applies Lualine specific highlight groups with enhanced styling
--- @param colors table The table of colors parsed from Matugen.
--- @param config table The plugin's configuration table.
--- @param set_hl function Helper function to set highlight groups.
function M.apply(colors, config, set_hl)
  -- Define style presets
  local styles = {
    bold = { "bold" },
    italic = { "italic" },
  }

  -- Semantic color aliases
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
    on_surface_variant = colors.on_surface_variant or "#B8C9CE",

    surface_container_high = colors.surface_container_high or "#232B2D",
    surface_container_highest = colors.surface_container_highest or "#2D3638",
    surface_container_low = colors.surface_container_low or "#141D1F",

    outline = colors.outline or "#839498",
    outline_variant = colors.outline_variant or "#3A494D",
  }

  -- Active sections
  set_hl("LualineNormal", {
    fg = C.on_primary_container,
    bg = C.primary_container,
  })

  set_hl("LualineA", {
    fg = C.primary,
    bg = C.primary_container,
    style = styles.bold,
  })

  set_hl("LualineB", {
    fg = C.on_primary_container,
    bg = C.surface_container_high,
  })

  set_hl("LualineC", {
    fg = C.on_surface,
    bg = C.surface_container_low,
  })

  set_hl("LualineX", {
    fg = C.on_surface,
    bg = C.surface_container_low,
  })

  set_hl("LualineY", {
    fg = C.on_primary_container,
    bg = C.surface_container_high,
  })

  set_hl("LualineZ", {
    fg = C.primary,
    bg = C.primary_container,
    style = styles.bold,
  })

  -- Inactive sections (for inactive windows)
  set_hl("LualineInactive", {
    fg = C.on_surface_variant,
    bg = C.surface_container_high,
  })

  set_hl("LualineAInactive", {
    fg = C.on_surface_variant,
    bg = C.surface_container_highest,
  })

  set_hl("LualineBInactive", {
    fg = C.on_surface_variant,
    bg = C.surface_container_highest,
  })

  set_hl("LualineCInactive", {
    fg = C.outline_variant,
    bg = C.surface_container_high,
  })

  set_hl("LualineXInactive", {
    fg = C.outline_variant,
    bg = C.surface_container_high,
  })

  set_hl("LualineYInactive", {
    fg = C.on_surface_variant,
    bg = C.surface_container_highest,
  })

  set_hl("LualineZInactive", {
    fg = C.on_surface_variant,
    bg = C.surface_container_highest,
  })

  -- Mode-specific colors
  set_hl("LualineInsert", {
    fg = colors.on_secondary_container or "#E3DFFF",
    bg = C.secondary_container,
    style = styles.bold,
  })

  set_hl("LualineVisual", {
    fg = colors.on_tertiary_container or "#AAEDFC",
    bg = C.tertiary_container,
    style = styles.bold,
  })

  set_hl("LualineReplace", {
    fg = colors.on_error_container or "#FFDAD6",
    bg = C.error_container,
    style = styles.bold,
  })

  set_hl("LualineCommand", {
    fg = colors.on_primary_container or "#FFDDAE",
    bg = C.primary_container,
    style = styles.bold,
  })

  set_hl("LualineTerminal", {
    fg = colors.on_tertiary_container or "#AAEDFC",
    bg = colors.tertiary_container or "#004E5A",
    style = styles.bold,
  })

  set_hl("LualineSelect", {
    fg = colors.on_secondary_container or "#E3DFFF",
    bg = C.secondary_container,
    style = styles.bold,
  })

  -- Diagnostic sections
  set_hl("LualineDiagnosticsError", {
    fg = colors.error or "#FFB4AB",
    bg = C.surface_container_high,
  })

  set_hl("LualineDiagnosticsWarn", {
    fg = colors.primary or "#F5BD62",
    bg = C.surface_container_high,
  })

  set_hl("LualineDiagnosticsInfo", {
    fg = colors.tertiary or "#8ED1DF",
    bg = C.surface_container_high,
  })

  set_hl("LualineDiagnosticsHint", {
    fg = colors.outline or "#839498",
    bg = C.surface_container_high,
  })

  -- Git status indicators
  set_hl("LualineDiffAdded", {
    fg = colors.tertiary_fixed or "#AAEDFC",
    bg = C.surface_container_high,
  })

  set_hl("LualineDiffModified", {
    fg = colors.primary or "#F5BD62",
    bg = C.surface_container_high,
  })

  set_hl("LualineDiffRemoved", {
    fg = colors.error or "#FFB4AB",
    bg = C.surface_container_high,
  })

  -- File status indicators
  set_hl("LualineFileFormat", {
    fg = C.on_primary_container,
    bg = C.primary_container,
  })

  set_hl("LualineFileStatus", {
    fg = C.on_surface,
    bg = C.surface_container_low,
  })

  set_hl("LualineFileSize", {
    fg = C.on_surface,
    bg = C.surface_container_low,
  })

  -- Location indicators
  set_hl("LualineLocation", {
    fg = C.primary,
    bg = C.primary_container,
    style = styles.bold,
  })

  set_hl("LualineProgress", {
    fg = C.primary,
    bg = C.primary_container,
  })
end

return M
