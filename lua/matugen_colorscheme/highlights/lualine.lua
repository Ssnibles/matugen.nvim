local M = {}

--- Applies Lualine specific highlight groups.
--- @param colors table The table of colors parsed from Matugen.
--- @param config table The plugin's configuration table.
--- @param set_hl function Helper function to set highlight groups.
function M.apply(colors, config, set_hl)
  -- Active sections
  set_hl("LualineNormal", colors.on_primary_container, colors.primary_container) -- Overall active statusline
  set_hl("LualineA", colors.primary, colors.primary_container, "bold") -- Mode indicator (e.g., NORMAL, INSERT)
  set_hl("LualineB", colors.on_primary_container, colors.surface_container_high) -- Section B (e.g., git branch)
  set_hl("LualineC", colors.on_surface, colors.surface_container_low) -- Main section C (e.g., file path)
  set_hl("LualineX", colors.on_surface, colors.surface_container_low) -- Main section X (e.g., file type)
  set_hl("LualineY", colors.on_primary_container, colors.surface_container_high) -- Section Y (e.g., diagnostics)
  set_hl("LualineZ", colors.primary, colors.primary_container, "bold") -- End section Z (e.g., line/col)

  -- Inactive sections (for inactive windows)
  set_hl("LualineInactive", colors.on_surface_variant, colors.surface_container_high) -- Overall inactive statusline
  set_hl("LualineAInactive", colors.on_surface_variant, colors.surface_container_highest)
  set_hl("LualineBInactive", colors.on_surface_variant, colors.surface_container_highest)
  set_hl("LualineCInactive", colors.outline_variant, colors.surface_container_high)
  set_hl("LualineXInactive", colors.outline_variant, colors.surface_container_high)
  set_hl("LualineYInactive", colors.on_surface_variant, colors.surface_container_highest)
  set_hl("LualineZInactive", colors.on_surface_variant, colors.surface_container_highest)

  -- Mode-specific colors (these are usually backgrounds for LualineA)
  set_hl("LualineInsert", colors.on_secondary, colors.secondary) -- Brighter secondary for insert
  set_hl("LualineVisual", colors.on_tertiary, colors.tertiary) -- Brighter tertiary for visual
  set_hl("LualineReplace", colors.on_error, colors.error) -- Error color for replace
  set_hl("LualineCommand", colors.on_primary, colors.primary) -- Primary for command line

  -- Define a lualine theme using these colors (optional, but good practice for custom themes)
  -- This part requires lualine to be loaded, so ensure it's loaded before your colorscheme applies.
  -- If you set a custom theme name, you'll need to set `lualine_setup.options.theme = 'your_theme_name'`
  -- in your lualine configuration.
  -- Example of defining a simple theme (you'd put this in your lualine setup):
  -- local custom_lualine_theme = {
  --     normal = {
  --         a = { fg = colors.primary, bg = colors.primary_container, gui = "bold" },
  --         b = { fg = colors.on_primary_container, bg = colors.surface_container_high },
  --         c = { fg = colors.on_surface, bg = colors.surface_container_low },
  --     },
  --     inactive = {
  --         a = { fg = colors.on_surface_variant, bg = colors.surface_container_highest },
  --         b = { fg = colors.on_surface_variant, bg = colors.surface_container_highest },
  --         c = { fg = colors.outline_variant, bg = colors.surface_container_high },
  --     },
  --     insert = { a = { fg = colors.on_secondary, bg = colors.secondary } },
  --     visual = { a = { fg = colors.on_tertiary, bg = colors.tertiary } },
  --     replace = { a = { fg = colors.on_error, bg = colors.error } },
  --     command = { a = { fg = colors.on_primary, bg = colors.primary } },
  -- }
  -- require('lualine.themes').my_matugen_theme = custom_lualine_theme
end

return M
