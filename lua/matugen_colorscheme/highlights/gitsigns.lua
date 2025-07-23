-- ~/projects/matugen.nvim/lua/matugen_colorscheme/highlights/gitsigns.lua

local M = {}

--- Applies gitsigns.nvim specific highlight groups.
--- @param colors table The table of colors parsed from Matugen.
--- @param config table The plugin's configuration table.
--- @param set_hl function Helper function to set highlight groups.
function M.apply(colors, config, set_hl)
  set_hl("GitSignsAdd", colors.tertiary_fixed_dim or colors.tertiary, "NONE")
  set_hl("GitSignsChange", colors.primary_fixed_dim or colors.primary, "NONE")
  set_hl("GitSignsDelete", colors.error_container or colors.error, "NONE")

  set_hl("GitSignsAddNr", colors.tertiary_fixed_dim or colors.tertiary, "NONE")
  set_hl("GitSignsChangeNr", colors.primary_fixed_dim or colors.primary, "NONE")
  set_hl("GitSignsDeleteNr", colors.error_container or colors.error, "NONE")

  -- Note: Appending "30" to a hex color might not work in all terminals/GUIs directly
  -- for opacity. It's often better to define a separate color in your Matugen template
  -- if you need transparent variations, or use `vim.api.nvim_set_hl` with `blend`
  -- if you're targeting a true-color GUI terminal.
  -- For now, I'm keeping the original idea with the "30" suffix but be aware.
  set_hl("GitSignsAddLn", nil, (colors.tertiary_fixed_dim or colors.tertiary) .. "30")
  set_hl("GitSignsChangeLn", nil, (colors.primary_fixed_dim or colors.primary) .. "30")
  set_hl("GitSignsDeleteLn", nil, (colors.error_container or colors.error) .. "30")

  set_hl("GitSignsCurrentLineBlame", colors.outline_variant, colors.surface_variant)
  set_hl("GitSignsDeleteRemoved", colors.error, nil)
end

return M
