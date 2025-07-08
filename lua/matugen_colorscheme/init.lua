-- ~/projects/matugen.nvim/lua/matugen_colorscheme/init.lua

local M = {}

-- User configuration (defaults)
M.config = {
  -- Default path for the Matugen-generated colors JSON file
  -- This is now the ONLY path the user needs to worry about for Matugen output
  file = vim.fn.stdpath("cache") .. "/matugen/colors.json",
  -- Option to choose background: "dark" or "light"
  background_style = "dark", -- Default, but Matugen might imply this
  -- You could add a path to the matugen executable here if you want to run it from Neovim
  -- matugen_executable = "matugen",
  -- image_path = "/path/to/your/default_image.jpg", -- If you want to integrate image picking
  -- template_path = "/path/to/your/matugen_nvim_template.json", -- If you want to integrate template picking
}

-- Global variable to store loaded colors
local loaded_colors = {}

---Reads and parses the Matugen-generated JSON file.
---@param file_path string The path to the JSON file.
---@return table|nil The parsed colors table, or nil if an error occurred.
local function read_matugen_colors_file(file_path)
  local f = io.open(file_path, "r")
  if not f then
    vim.notify("Could not open Matugen colors file: " .. file_path, vim.log.levels.ERROR)
    return nil
  end

  local content = f:read("*a")
  f:close()

  local success, colors = pcall(vim.json.decode, content)
  if not success then
    vim.notify("Error decoding Matugen colors JSON from " .. file_path .. ": " .. colors, vim.log.levels.ERROR)
    return nil
  end

  return colors
end

---Applies highlight groups based on the loaded colors.
---@param colors table The table of color values (hex strings).
local function apply_highlights(colors)
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = M.config.background_style -- Use the configured background style

  local function set_hl(group, fg, bg, style)
    local cmd = "highlight " .. group
    if fg then
      cmd = cmd .. " guifg=" .. fg
    end
    if bg then
      cmd = cmd .. " guibg=" .. bg
    end
    if style then
      cmd = cmd .. " gui=" .. style
    end
    vim.cmd(cmd)
  end

  -- General UI elements (using 'colors' table directly)
  set_hl("Normal", colors.on_background, colors.background)
  set_hl("NormalFloat", colors.on_surface, colors.surface)
  set_hl("FloatBorder", colors.on_surface_variant, colors.surface)
  set_hl("LineNr", colors.outline, colors.background)
  set_hl("SignColumn", colors.outline, colors.background)
  set_hl("FoldColumn", colors.outline, colors.background)
  set_hl("VertSplit", colors.surface_variant, colors.surface_variant)
  set_hl("ColorColumn", nil, colors.surface_variant)
  set_hl("CursorLine", nil, colors.surface)
  set_hl("CursorLineNr", colors.on_surface, colors.surface)
  set_hl("MatchParen", colors.primary, nil, "bold")
  set_hl("Pmenu", colors.on_surface, colors.surface_variant)
  set_hl("PmenuSel", colors.on_primary, colors.primary)
  set_hl("PmenuSbar", nil, colors.surface_variant)
  set_hl("PmenuThumb", nil, colors.on_surface)

  -- Syntax highlighting (basic examples, expand as needed)
  set_hl("Comment", colors.comment, nil, "italic")
  set_hl("Constant", colors.tertiary)
  set_hl("String", colors.secondary)
  set_hl("Number", colors.tertiary)
  set_hl("Boolean", colors.tertiary)
  set_hl("Float", colors.tertiary)
  set_hl("Identifier", colors.primary_container)
  set_hl("Function", colors.primary)
  set_hl("Statement", colors.primary, nil, "bold")
  set_hl("Conditional", colors.primary)
  set_hl("Repeat", colors.primary)
  set_hl("Label", colors.primary)
  set_hl("Operator", colors.on_background)
  set_hl("Keyword", colors.primary)
  set_hl("Exception", colors.error)
  set_hl("PreProc", colors.tertiary)
  set_hl("Include", colors.tertiary)
  set_hl("Define", colors.tertiary)
  set_hl("Macro", colors.tertiary)
  set_hl("PreCondit", colors.tertiary)
  set_hl("Type", colors.secondary)
  set_hl("StorageClass", colors.secondary)
  set_hl("Structure", colors.secondary)
  set_hl("Typedef", colors.secondary)
  set_hl("Special", colors.tertiary_container)
  set_hl("SpecialChar", colors.tertiary_container)
  set_hl("Tag", colors.tertiary_container)
  set_hl("Delimiter", colors.tertiary_container)
  set_hl("SpecialComment", colors.tertiary_container)
  set_hl("Debug", colors.error)
  set_hl("Underlined", nil, nil, "underline")
  set_hl("Ignore", nil, nil, "invisible")
  set_hl("Error", colors.on_error, colors.error)
  set_hl("Todo", colors.on_primary_container, colors.primary_container, "bold")

  -- Diffs
  set_hl("DiffAdd", colors.on_secondary_container, colors.secondary_container)
  set_hl("DiffChange", colors.on_primary_container, colors.primary_container)
  set_hl("DiffDelete", colors.on_error_container, colors.error_container)
  set_hl("DiffText", colors.on_tertiary_container, colors.tertiary_container)

  -- Visual mode
  set_hl("Visual", nil, colors.surface_variant)
  set_hl("VisualNOS", nil, colors.surface_variant)

  -- IncSearch & Search
  set_hl("IncSearch", colors.on_primary, colors.primary)
  set_hl("Search", colors.on_secondary, colors.secondary)

  -- Statusline and Tabline
  set_hl("StatusLine", colors.on_surface, colors.surface_variant)
  set_hl("StatusLineNC", colors.outline, colors.surface)
  set_hl("TabLine", colors.on_surface, colors.surface)
  set_hl("TabLineFill", colors.on_surface, colors.surface)
  set_hl("TabLineSel", colors.on_primary, colors.primary)

  -- Spell checking
  set_hl("SpellBad", colors.on_error, colors.error, "underline")
  set_hl("SpellCap", colors.on_secondary, colors.secondary, "underline")
  set_hl("SpellRare", colors.on_tertiary, colors.tertiary, "underline")
  set_hl("SpellLocal", colors.on_primary, colors.primary, "underline")

  -- Directory and Title
  set_hl("Directory", colors.primary)
  set_hl("Title", colors.primary)

  -- Cursor
  set_hl("Cursor", colors.background, colors.on_background)
  set_hl("lCursor", colors.background, colors.on_background)
  set_hl("vCursor", colors.background, colors.on_background)
  set_hl("iCursor", colors.background, colors.on_background)

  -- More specific elements (can be expanded)
  set_hl("NonText", colors.outline_variant)
  set_hl("Whitespace", colors.outline_variant)
  set_hl("Conceal", colors.outline_variant)
end

---Loads the Matugen-generated colorscheme.
function M.load_matugen_colorscheme()
  local colors_file_path = M.config.file

  if vim.fn.filereadable(colors_file_path) == 0 then
    vim.notify("Matugen colors file not found at: " .. colors_file_path, vim.log.levels.ERROR)
    vim.notify(
      "Please generate it using Matugen, e.g.: matugen generate -i /path/to/your/image.jpg -t /path/to/your/template.json -o "
        .. colors_file_path,
      vim.log.levels.INFO
    )
    return
  end

  local colors = read_matugen_colors_file(colors_file_path)
  if not colors then
    -- Error already notified by read_matugen_colors_file
    return
  end

  loaded_colors = colors -- Store the loaded colors for potential external access
  apply_highlights(loaded_colors)
  vim.cmd("colorscheme matugen_colors") -- Set the colorscheme name for display
  vim.notify("Matugen colorscheme loaded successfully!", vim.log.levels.INFO)
end

---Setup function for the plugin.
---@param opts table User configuration options.
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Define a user command to load the colorscheme
  vim.api.nvim_create_user_command("MatugenColorschemeLoad", function()
    M.load_matugen_colorscheme()
  end, {
    desc = "Load the Matugen-generated colorscheme",
  })

  -- You might want to auto-load it on VimEnter
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("MatugenColorschemeAutoLoad", { clear = true }),
    callback = function()
      M.load_matugen_colorscheme()
    end,
  })
end

-- Function to get the currently loaded colors (useful for other plugins)
function M.get_colors()
  return loaded_colors
end

return M
