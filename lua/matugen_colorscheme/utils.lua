-- lua/matugen_colorscheme/utils.lua

local M = {}

-- Brighten a hex color by a given percentage (0 - 100)
-- Input: hex string "#RRGGBB" or "RRGGBB"
-- Output: hex string "#RRGGBB"
local function brighten_hex(hex, percent)
  -- Remove '#' if present
  hex = hex:gsub("#", "")
  -- Parse RGB components
  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)

  -- Increase each channel by percent (up to max 255)
  local function brighten_channel(c)
    c = math.floor(c * (1 + percent / 100))
    if c > 255 then
      c = 255
    end
    return c
  end

  r = brighten_channel(r)
  g = brighten_channel(g)
  b = brighten_channel(b)

  -- Return as hex string with '#'
  return string.format("#%02X%02X%02X", r, g, b)
end

M.brighten_hex = brighten_hex

return M
