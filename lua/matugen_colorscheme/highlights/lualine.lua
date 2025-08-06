local M = {}

-- Style combinations for consistency
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  bold_italic = { "bold", "italic" },
}

--- Apply Lualine highlights with comprehensive mode and component support
--- @param colors table Color palette
--- @param config table Plugin configuration
--- @param set_hl function Highlight setter function
function M.apply(colors, config, set_hl)
  -- Semantic color mapping with fallbacks
  local c = {
    -- Primary theme colors
    primary = colors.primary,
    primary_container = colors.primary_container,
    on_primary_container = colors.on_primary_container,

    -- Secondary theme colors
    secondary = colors.secondary,
    secondary_container = colors.secondary_container,
    on_secondary_container = colors.on_secondary_container,

    -- Tertiary theme colors
    tertiary = colors.tertiary,
    tertiary_container = colors.tertiary_container,
    on_tertiary_container = colors.on_tertiary_container,

    -- Error colors
    error = colors.error,
    error_container = colors.error_container,
    on_error_container = colors.on_error_container,

    -- Surface colors
    surface = colors.surface,
    on_surface = colors.on_surface,
    surface_variant = colors.on_surface_variant,

    -- Container surfaces with fallbacks
    container_low = colors.surface_container_low or colors.surface,
    container_high = colors.surface_container_high or colors.surface,
    container_highest = colors.surface_container_highest or colors.surface,

    -- Utility colors
    outline = colors.outline,
    tertiary_fixed = colors.tertiary_fixed or colors.tertiary,
  }

  -- Mode definitions with their corresponding color schemes
  local modes = {
    { name = "normal", colors = { fg = c.primary, bg = c.primary_container } },
    { name = "insert", colors = { fg = c.on_secondary_container, bg = c.secondary_container } },
    { name = "visual", colors = { fg = c.on_tertiary_container, bg = c.tertiary_container } },
    { name = "replace", colors = { fg = c.on_error_container, bg = c.error_container } },
    { name = "command", colors = { fg = c.on_primary_container, bg = c.primary_container } },
    { name = "terminal", colors = { fg = c.on_tertiary_container, bg = c.tertiary_container } },
  }

  -- Component sections with their styling
  local sections = {
    { name = "a", style = STYLES.bold },
    { name = "b", style = nil },
    { name = "c", style = nil },
  }

  -- Generate mode-based highlights
  local highlights = {}

  -- Generate highlights for each mode and section
  for _, mode in ipairs(modes) do
    local mode_name = mode.name
    local mode_colors = mode.colors

    for _, section in ipairs(sections) do
      local section_name = section.name
      local section_style = section.style

      local group_name = "lualine_" .. section_name .. "_" .. mode_name

      -- Define section-specific styling
      if section_name == "a" then
        highlights[group_name] = {
          fg = mode_colors.fg,
          bg = mode_colors.bg,
          style = section_style,
        }
      elseif section_name == "b" then
        highlights[group_name] = {
          fg = mode_name == "normal" and c.on_primary_container or mode_colors.fg,
          bg = c.container_high,
        }
      else -- section "c"
        highlights[group_name] = {
          fg = c.on_surface,
          bg = c.container_low,
        }
      end
    end
  end

  -- Inactive mode highlights
  local inactive_sections = {
    lualine_a_inactive = { fg = c.surface_variant, bg = c.container_highest },
    lualine_b_inactive = { fg = c.surface_variant, bg = c.container_high },
    lualine_c_inactive = { fg = c.outline, bg = c.container_low },
  }

  -- Diagnostic highlights
  local diagnostics = {
    { name = "error", color = c.error },
    { name = "warn", color = c.primary },
    { name = "info", color = c.tertiary },
    { name = "hint", color = c.outline },
  }

  for _, diag in ipairs(diagnostics) do
    highlights["lualine_diagnostics_" .. diag.name .. "_normal"] = {
      fg = diag.color,
      bg = c.container_high,
    }
  end

  -- Diff highlights
  local diff_highlights = {
    lualine_diff_added_normal = { fg = c.tertiary_fixed, bg = c.container_high },
    lualine_diff_modified_normal = { fg = c.primary, bg = c.container_high },
    lualine_diff_removed_normal = { fg = c.error, bg = c.container_high },
  }

  -- Component-specific highlights
  local component_highlights = {
    -- File information
    lualine_filename_normal = { fg = c.on_surface, bg = c.container_low },
    lualine_filename_inactive = { fg = c.outline, bg = c.container_low },

    -- Location and progress
    lualine_location_normal = { fg = c.primary, bg = c.primary_container, style = STYLES.bold },
    lualine_progress_normal = { fg = c.primary, bg = c.primary_container },

    -- File type and encoding
    lualine_filetype_normal = { fg = c.on_surface, bg = c.container_high },
    lualine_encoding_normal = { fg = c.surface_variant, bg = c.container_high },

    -- Branch information
    lualine_branch_normal = { fg = c.tertiary, bg = c.container_high, style = STYLES.bold },
    lualine_branch_inactive = { fg = c.outline, bg = c.container_high },
  }

  -- Additional mode variants for other sections
  local additional_modes = {
    "insert",
    "visual",
    "replace",
    "command",
    "terminal",
  }

  for _, mode in ipairs(additional_modes) do
    component_highlights["lualine_filename_" .. mode] = component_highlights.lualine_filename_normal
    component_highlights["lualine_filetype_" .. mode] = component_highlights.lualine_filetype_normal
    component_highlights["lualine_branch_" .. mode] = component_highlights.lualine_branch_normal
  end

  -- Merge all highlight groups
  for group, opts in pairs(inactive_sections) do
    highlights[group] = opts
  end

  for group, opts in pairs(diff_highlights) do
    highlights[group] = opts
  end

  for group, opts in pairs(component_highlights) do
    highlights[group] = opts
  end

  -- Apply all highlights
  for group, opts in pairs(highlights) do
    set_hl(group, opts)
  end
end

return M
