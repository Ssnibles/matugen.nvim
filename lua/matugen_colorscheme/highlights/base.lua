local M = {}

function M.apply(colors, set_hl, set_hl_link, config)
  -- Put only base highlights here, e.g.
  set_hl("Normal", colors.on_background, config.transparent_background and "NONE" or colors.background)
  set_hl("Comment", colors.on_surface_variant, nil, "italic")
  -- ... add more base highlights here
end

return M
