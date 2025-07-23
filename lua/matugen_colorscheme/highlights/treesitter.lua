local M = {}

function M.apply(colors, set_hl, set_hl_link, config)
  if config.disable_treesitter_highlights then return end

  set_hl("@comment", colors.outline, nil, "italic")
  set_hl("@function", colors.primary, nil, "bold")
  -- ... add more treesitter highlights here
end

return M
