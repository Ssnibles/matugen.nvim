-- Ssnibles/matugen.nvim/lua/matugen_colorscheme/init.lua

local M = {}

-- Global variable to store loaded colors
local loaded_colors = {}

--- Helper to expand a path (like `~`)
---@param path string The path to expand
---@return string The expanded path
local function expand_path(path)
  -- Use vim.fn.expand() for robustness, it handles more than just '~'
  -- If path is nil or not a string, return as is or handle error
  if type(path) ~= "string" then
    return path
  end
  return vim.fn.expand(path)
end

--- Strips comments from JSONC content.
--- This is a simple regex-based stripper. For more robust parsing, a dedicated JSONC parser
--- might be preferred, but this usually suffices for common single-line and multi-line comments.
--- @param jsonc_content string The JSONC content as a string.
--- @return string The JSON content without comments.
local function strip_jsonc_comments(jsonc_content)
  -- Remove multi-line comments /* ... */
  local without_block_comments = jsonc_content:gsub("/%*%X*?%*/", "")
  -- Remove single-line comments // ...
  local without_comments = without_block_comments:gsub("//[^\n\r]*", "")
  return without_comments
end

---Reads and parses the Matugen-generated JSONC file.
---@param file_path string The path to the JSONC file.
---@return table|nil The parsed colors table, or nil if an error occurred.
local function read_matugen_colors_file(file_path)
  local f = io.open(file_path, "r")
  if not f then
    vim.notify("Matugen colors file not found at: " .. file_path, vim.log.levels.ERROR)
    return nil
  end

  local content = f:read("*a")
  f:close()

  -- Strip comments before decoding JSON
  local json_content = strip_jsonc_comments(content)

  local success, colors = pcall(vim.json.decode, json_content)
  if not success then
    vim.notify("Error decoding Matugen colors JSON from " .. file_path .. ": " .. colors, vim.log.levels.ERROR)
    return nil
  end

  return colors
end

---Applies highlight groups based on the loaded colors.
---@param colors table The table of color values (hex strings).
---@param background_style string "dark" or "light"
local function apply_highlights(colors, background_style)
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = background_style -- Use the configured background style

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

  -- General UI elements
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
  set_hl("Ignore", colors.background, colors.background)
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
  local colors_file_path = expand_path(M.config.file) -- Auto-expand the path

  if vim.fn.filereadable(colors_file_path) == 0 then
    vim.notify(
      "Matugen colors file not found at: " .. colors_file_path,
      vim.log.levels.ERROR,
      { title = "Matugen.nvim" }
    )
    vim.notify(
      "Please generate it using Matugen, e.g.: matugen generate -i /path/to/your/image.jpg -t /path/to/your/template.jsonc -o "
        .. colors_file_path,
      vim.log.levels.INFO,
      { title = "Matugen.nvim" }
    )
    return
  end

  local colors = read_matugen_colors_file(colors_file_path)
  if not colors then
    -- Error already notified by read_matugen_colors_file
    return
  end

  loaded_colors = colors -- Store the loaded colors for potential external access
  apply_highlights(loaded_colors, M.config.background_style)
  vim.notify("Matugen colorscheme loaded successfully!", vim.log.levels.INFO, { title = "Matugen.nvim" })
end

---Setup function for the plugin.
---@param opts table User configuration options.
function M.setup(opts)
  -- Default configuration
  M.config = {
    file = vim.fn.stdpath("cache") .. "/matugen/colors.jsonc", -- Default path
    background_style = "dark", -- Default, can be "light"
  }

  -- Merge user options
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Define a user command to load the colorscheme
  vim.api.nvim_create_user_command("MatugenColorschemeLoad", function()
    M.load_matugen_colorscheme()
  end, {
    desc = "Load the Matugen-generated colorscheme",
  })

  -- Autocmd to load on VimEnter (can be disabled by user if they want to call it manually)
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
