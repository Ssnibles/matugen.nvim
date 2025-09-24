-- lua/matugen_colorscheme/utils.lua
-- Color utilities aligned with WCAG relative luminance and contrast ratio,
-- and standard sRGB <-> linear transfer functions.

local M = {}

-- Clamp a numeric value to [lo, hi].
local function clamp(x, lo, hi)
  if x < lo then
    return lo
  end
  if x > hi then
    return hi
  end
  return x
end

-- Export clamp for consumers/tests.
M.clamp = clamp

-- Validate and normalize a hex string (strip leading '#', lowercase).
local function normalize_hex_str(hex)
  if type(hex) ~= "string" then
    return nil
  end
  hex = hex:gsub("^#", ""):lower()
  if not hex:match("^[%x]+$") then
    return nil
  end -- only hex digits
  local n = #hex
  if n ~= 3 and n ~= 4 and n ~= 6 and n ~= 8 then
    return nil
  end
  return hex
end

-- Expand a single hex nibble to a byte string ("a" -> "aa").
local function dup_nibble(s, i)
  local ch = s:sub(i, i)
  return ch .. ch
end

-- Parse #RGB, #RGBA, #RRGGBB, #RRGGBBAA (hash optional).
-- Returns r,g,b,a in 0..255 and had_alpha boolean, or nil if invalid.
local function parse_hex(hex)
  hex = normalize_hex_str(hex)
  if not hex then
    return nil
  end
  local n = #hex
  local r, g, b, a
  if n == 3 then
    r = tonumber(dup_nibble(hex, 1), 16)
    g = tonumber(dup_nibble(hex, 2), 16)
    b = tonumber(dup_nibble(hex, 3), 16)
    a = 255
    return r, g, b, a, false
  elseif n == 4 then
    r = tonumber(dup_nibble(hex, 1), 16)
    g = tonumber(dup_nibble(hex, 2), 16)
    b = tonumber(dup_nibble(hex, 3), 16)
    a = tonumber(dup_nibble(hex, 4), 16)
    return r, g, b, a, true
  elseif n == 6 then
    r = tonumber(hex:sub(1, 2), 16)
    g = tonumber(hex:sub(3, 4), 16)
    b = tonumber(hex:sub(5, 6), 16)
    a = 255
    return r, g, b, a, false
  else -- n == 8
    r = tonumber(hex:sub(1, 2), 16)
    g = tonumber(hex:sub(3, 4), 16)
    b = tonumber(hex:sub(5, 6), 16)
    a = tonumber(hex:sub(7, 8), 16)
    return r, g, b, a, true
  end
end

-- Export parser for reuse.
M.parse_hex = parse_hex

-- Format hex color preserving alpha if present; uppercase for consistency.
local function format_hex(r, g, b, a, had_alpha)
  r = clamp(r, 0, 255)
  g = clamp(g, 0, 255)
  b = clamp(b, 0, 255)
  a = clamp(a or 255, 0, 255)
  if had_alpha then
    return string.format("#%02X%02X%02X%02X", r, g, b, a)
  else
    return string.format("#%02X%02X%02X", r, g, b)
  end
end

M.format_hex = format_hex

-- sRGB -> linear (piecewise), component in 0..255 to linear 0..1.
-- Threshold and exponents per sRGB transfer function.
local function srgb_to_linear(c)
  local s = clamp(c, 0, 255) / 255
  if s <= 0.04045 then
    return s / 12.92
  else
    return ((s + 0.055) / 1.055) ^ 2.4
  end
end

-- linear -> sRGB (piecewise), linear 0..1 to component 0..255.
local function linear_to_srgb(x)
  local L = clamp(x, 0, 1)
  if L <= 0.0031308 then
    L = 12.92 * L
  else
    L = 1.055 * (L ^ (1 / 2.4)) - 0.055
  end
  return clamp(math.floor(L * 255 + 0.5), 0, 255)
end

-- Calculate relative luminance (0..1) using WCAG formula in linear light.
local function relative_luminance(hex)
  local r, g, b = parse_hex(hex)
  if not r then
    return 0.5
  end -- fallback for invalid colors
  local rl = srgb_to_linear(r)
  local gl = srgb_to_linear(g)
  local bl = srgb_to_linear(b)
  return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl
end

-- Calculate WCAG contrast ratio between two colors.
local function contrast_ratio(fg_hex, bg_hex)
  local l1 = relative_luminance(fg_hex)
  local l2 = relative_luminance(bg_hex)
  local light = (l1 > l2) and l1 or l2
  local dark = (l1 > l2) and l2 or l1
  return (light + 0.05) / (dark + 0.05)
end

-- Mix toward target (0 -> black, 1 -> white) in linear space by amount t in [0,1].
local function mix_toward_linear(rl, gl, bl, target, t)
  rl = rl + (target - rl) * t
  gl = gl + (target - gl) * t
  bl = bl + (target - bl) * t
  return rl, gl, bl
end

-- Brighten (percent > 0) by mixing toward white in linear light,
-- Darken (percent < 0) by mixing toward black in linear light.
-- percent clamped to [-100, 100].
function M.brighten_hex(hex, percent)
  local r, g, b, a, had_alpha = parse_hex(hex)
  if not r then
    return hex
  end
  local t = clamp(tonumber(percent or 0) or 0, -100, 100) / 100
  if t == 0 then
    return format_hex(r, g, b, a, had_alpha)
  end

  -- Convert to linear, mix, then return to sRGB.
  local rl = srgb_to_linear(r)
  local gl = srgb_to_linear(g)
  local bl = srgb_to_linear(b)
  local target = (t > 0) and 1.0 or 0.0
  local amt = math.abs(t)
  rl, gl, bl = mix_toward_linear(rl, gl, bl, target, amt)
  local R = linear_to_srgb(rl)
  local G = linear_to_srgb(gl)
  local B = linear_to_srgb(bl)
  return format_hex(R, G, B, a, had_alpha)
end

-- Optional: mix two hex colors in linear space by t in [0,1].
function M.mix_hex(a_hex, b_hex, t)
  local ar, ag, ab, aa, a_has = parse_hex(a_hex)
  local br, bg, bb, ba, b_has = parse_hex(b_hex)
  if not ar or not br then
    return a_hex
  end
  t = clamp(tonumber(t or 0) or 0, 0, 1)
  local arl, agl, abl = srgb_to_linear(ar), srgb_to_linear(ag), srgb_to_linear(ab)
  local brl, bgl, bbl = srgb_to_linear(br), srgb_to_linear(bg), srgb_to_linear(bb)
  local rl = arl + (brl - arl) * t
  local gl = agl + (bgl - agl) * t
  local bl = abl + (bbl - abl) * t
  local R = linear_to_srgb(rl)
  local G = linear_to_srgb(gl)
  local B = linear_to_srgb(bl)
  local A, has = aa, a_has
  if b_has then
    -- If both have alpha, linearly interpolate alpha in 0..255.
    A = math.floor((aa * (1 - t) + ba * t) + 0.5)
    has = true
  end
  return format_hex(R, G, B, A, has)
end

-- Adjust color to meet minimum contrast ratio against background.
-- Uses a directed binary search for fast, monotonic convergence.
function M.ensure_contrast(fg_hex, bg_hex, min_ratio, options)
  options = options or {}
  local max_iter = options.max_iterations or 14
  local epsilon = 1e-3

  if not fg_hex or not bg_hex or not min_ratio then
    return fg_hex
  end

  local current_ratio = contrast_ratio(fg_hex, bg_hex)
  if current_ratio >= min_ratio then
    return fg_hex
  end

  -- Choose direction: brighten if background is dark, else darken.
  local bg_lum = relative_luminance(bg_hex)
  local dir = (bg_lum < 0.5) and 1 or -1

  local lo, hi = 0.0, 1.0
  local best = fg_hex
  local best_ratio = current_ratio

  for _ = 1, max_iter do
    local mid = (lo + hi) * 0.5
    local candidate = M.brighten_hex(fg_hex, dir * mid * 100)
    local cr = contrast_ratio(candidate, bg_hex)

    if cr > best_ratio then
      best = candidate
      best_ratio = cr
    end

    if cr >= min_ratio then
      best = candidate
      if (hi - lo) < epsilon then
        break
      end
      hi = mid
    else
      lo = mid
    end

    if (hi - lo) < epsilon then
      break
    end
  end

  return best
end

-- Get the contrast ratio between two colors.
function M.get_contrast_ratio(fg_hex, bg_hex)
  return contrast_ratio(fg_hex, bg_hex)
end

-- Get relative luminance of a color (0.0 = black, 1.0 = white).
function M.get_luminance(hex)
  return relative_luminance(hex)
end

-- Check if a color is considered "light" (luminance > 0.5).
function M.is_light_color(hex)
  return relative_luminance(hex) > 0.5
end

-- Get a readable text color (black or white) for the given background.
function M.get_readable_text_color(bg_hex, options)
  options = options or {}
  local white_color = options.white_color or "#FFFFFF"
  local black_color = options.black_color or "#000000"
  local min_ratio = options.min_ratio or 4.5

  local white_ratio = contrast_ratio(white_color, bg_hex)
  local black_ratio = contrast_ratio(black_color, bg_hex)

  if white_ratio >= min_ratio and black_ratio >= min_ratio then
    return (white_ratio > black_ratio) and white_color or black_color
  elseif white_ratio >= min_ratio then
    return white_color
  elseif black_ratio >= min_ratio then
    return black_color
  else
    return (white_ratio > black_ratio) and white_color or black_color
  end
end

-- Batch ensure contrast for multiple colors against the same background.
function M.ensure_contrast_batch(colors, bg_hex, min_ratio, options)
  local results = {}
  for key, fg_hex in pairs(colors or {}) do
    results[key] = M.ensure_contrast(fg_hex, bg_hex, min_ratio, options)
  end
  return results
end

-- Create a color palette with guaranteed contrast ratios per role.
function M.create_accessible_palette(base_colors, background, contrast_levels)
  contrast_levels = contrast_levels
    or {
      text = 7.0, -- High contrast for body text
      accent = 5.0, -- Medium-high for UI accents
      secondary = 4.5, -- Medium for secondary text
      decorative = 3.0, -- Lower for borders and decorations
    }

  local palette = {}
  local opts = { max_iterations = 14 }
  for role, target in pairs(contrast_levels) do
    if base_colors[role] then
      palette[role] = M.ensure_contrast(base_colors[role], background, target, opts)
    end
  end
  return palette
end

return M
