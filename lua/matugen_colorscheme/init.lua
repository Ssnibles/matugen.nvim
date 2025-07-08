-- Ssnibles/matugen.nvim/lua/matugen_colorscheme/init.lua

local M = {}

-- Global variable to store loaded colors
local loaded_colors = {}
local current_background_style = "dark"

--- Helper to expand a path (like `~`)
---@param path string The path to expand
---@return string The expanded path
local function expand_path(path)
  if type(path) ~= "string" then
    return path
  end
  return vim.fn.expand(path)
end

--- Strips comments from JSONC content.
--- @param jsonc_content string The JSONC content as a string.
--- @return string The JSON content without comments.
local function strip_jsonc_comments(jsonc_content)
  local without_block_comments = jsonc_content:gsub("/%*.--%*/", "")
  local without_comments = without_block_comments:gsub("//[^\n\r]*", "")
  return without_comments
end

---Reads and parses the Matugen-generated JSONC file.
---@param file_path string The path to the JSONC file.
---@return table|nil The parsed colors table, or nil if an error occurred.
local function read_matugen_colors_file(file_path)
  local f = io.open(file_path, "r")
  if not f then
    vim.notify("Matugen colors file not found at: " .. file_path, vim.log.levels.ERROR, { title = "Matugen.nvim" })
    return nil
  end

  local content = f:read("*a")
  f:close()

  local json_content = strip_jsonc_comments(content)

  local success, colors = pcall(vim.json.decode, json_content)
  if not success then
    vim.notify(
      "Error decoding Matugen colors JSON from " .. file_path .. ": " .. colors,
      vim.log.levels.ERROR,
      { title = "Matugen.nvim" }
    )
    return nil
  end

  return colors
end

-- Helper for setting highlights with override check
local function set_hl(group, fg, bg, style)
  -- Check if this group should be ignored (user override)
  if M.config.ignore_groups and M.config.ignore_groups[group] then
    return
  end

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

-- Helper for setting highlight links with override check
local function set_hl_link(from, to)
  if M.config.ignore_groups and M.config.ignore_groups[from] then
    return
  end
  vim.cmd("highlight link " .. from .. " " .. to)
end

---Applies general highlight groups based on the loaded colors.
---@param colors table The table of color values (hex strings).
---@param background_style string "dark" or "light"
local function apply_base_highlights(colors, background_style)
  if not M.config.disable_clear then
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
      vim.cmd("syntax reset")
    end
  end

  vim.o.background = background_style
  vim.g.colors_name = "matugen_colors"

  -- Base Neovim UI Colors
  set_hl("Normal", colors.on_background, colors.background)
  set_hl("NormalFloat", colors.on_surface, colors.surface_container_low or colors.surface)
  set_hl("FloatBorder", colors.outline_variant, colors.surface_container_low or colors.surface)
  set_hl("VertSplit", colors.outline_variant, colors.background)
  set_hl("Pmenu", colors.on_surface, colors.surface_container or colors.surface)
  set_hl("PmenuSel", colors.on_primary, colors.primary)
  set_hl("PmenuSbar", nil, colors.surface_variant)
  set_hl("PmenuThumb", nil, colors.on_surface_variant or colors.on_surface)

  -- Line Numbers, Sign Column, Fold Column
  set_hl("LineNr", colors.outline, colors.background)
  set_hl("SignColumn", colors.outline, colors.background)
  set_hl("FoldColumn", colors.outline, colors.background)

  -- Cursorline and Number
  set_hl("CursorLine", nil, colors.surface_container_low or colors.surface)
  set_hl("CursorLineNr", colors.primary, colors.surface_container_low or colors.surface, "bold")

  -- Visual mode selection
  set_hl("Visual", nil, colors.surface_variant)
  set_hl("VisualNOS", nil, colors.surface_variant)

  -- Search and IncSearch
  set_hl("IncSearch", colors.on_secondary, colors.secondary_container, "bold")
  set_hl("Search", colors.on_tertiary, colors.tertiary_container)

  -- Diagnostics (errors, warnings, info, hints)
  set_hl("ErrorMsg", colors.on_error, colors.error_container, "bold")
  set_hl("WarningMsg", colors.on_primary_container, colors.primary_container, "bold")
  set_hl("InfoMsg", colors.on_secondary_container, colors.secondary_container)
  set_hl("HintMsg", colors.on_tertiary_container, colors.tertiary_container)

  -- Diffs
  set_hl("DiffAdd", colors.on_tertiary_container, colors.tertiary_container)
  set_hl("DiffChange", colors.on_primary_container, colors.primary_container)
  set_hl("DiffDelete", colors.on_error_container, colors.error_container)
  set_hl("DiffText", colors.on_secondary_container, colors.secondary_container)

  -- Statusline and Tabline
  set_hl("StatusLine", colors.on_surface, colors.surface_container_high or colors.surface)
  set_hl("StatusLineNC", colors.outline, colors.surface_container_low or colors.surface)
  set_hl("TabLine", colors.on_surface_variant or colors.on_surface, colors.surface_container_lowest or colors.surface)
  set_hl(
    "TabLineFill",
    colors.on_surface_variant or colors.on_surface,
    colors.surface_container_lowest or colors.surface
  )
  set_hl("TabLineSel", colors.on_primary, colors.primary, "bold")

  -- Command Line
  set_hl("CmdLine", colors.on_surface, colors.background)

  -- Spell checking
  set_hl("SpellBad", colors.on_error, colors.error_container, "underline")
  set_hl("SpellCap", colors.on_primary_container, colors.primary_container, "underline")
  set_hl("SpellRare", colors.on_secondary_container, colors.secondary_container, "underline")
  set_hl("SpellLocal", colors.on_tertiary_container, colors.tertiary_container, "underline")

  -- Other UI elements
  set_hl("ColorColumn", nil, colors.surface_container_lowest or colors.surface)
  set_hl("Cursor", colors.background, colors.on_background)
  set_hl("lCursor", colors.background, colors.on_background)
  set_hl("MatchParen", colors.on_primary, colors.primary_container, "bold")
  set_hl("NonText", colors.outline_variant)
  set_hl("Whitespace", colors.outline_variant)
  set_hl("Conceal", colors.outline_variant)
  set_hl("Directory", colors.primary)
  set_hl("Title", colors.primary)
  set_hl("ModeMsg", colors.primary_container)
  set_hl("MoreMsg", colors.tertiary)
  set_hl("Question", colors.secondary)
  set_hl(
    "Folded",
    colors.on_surface_variant or colors.on_surface,
    colors.surface_container_high or colors.surface,
    "italic"
  )

  -- Basic Syntax Highlighting (often falls back if TS is not active)
  set_hl("Comment", colors.comment or colors.outline, nil, "italic")
  set_hl("Constant", colors.tertiary)
  set_hl("String", colors.secondary)
  set_hl("Character", colors.secondary_fixed or colors.secondary)
  set_hl("Number", colors.tertiary)
  set_hl("Boolean", colors.tertiary)
  set_hl("Float", colors.tertiary)
  set_hl("Identifier", colors.primary_container)
  set_hl("Function", colors.primary)
  set_hl("Statement", colors.primary, nil, "bold")
  set_hl("Conditional", colors.primary)
  set_hl("Repeat", colors.primary)
  set_hl("Label", colors.primary_fixed_dim or colors.primary)
  set_hl("Operator", colors.outline)
  set_hl("Keyword", colors.primary)
  set_hl("Exception", colors.error)
  set_hl("PreProc", colors.secondary)
  set_hl("Include", colors.secondary)
  set_hl("Define", colors.secondary)
  set_hl("Macro", colors.secondary)
  set_hl("PreCondit", colors.secondary)
  set_hl("Type", colors.tertiary_fixed or colors.tertiary)
  set_hl("StorageClass", colors.tertiary_fixed or colors.tertiary)
  set_hl("Structure", colors.tertiary_fixed or colors.tertiary)
  set_hl("Typedef", colors.tertiary_fixed or colors.tertiary)
  set_hl("Special", colors.tertiary_container)
  set_hl("SpecialChar", colors.tertiary_container)
  set_hl("Tag", colors.tertiary_container)
  set_hl("Delimiter", colors.outline)
  set_hl("SpecialComment", colors.tertiary, nil, "italic")
  set_hl("Underlined", nil, nil, "underline")
  set_hl("Ignore", colors.background, colors.background)
  set_hl("Todo", colors.on_tertiary, colors.tertiary_container, "bold")

  -- Link common groups for consistency
  set_hl_link("htmlTag", "Tag")
  set_hl_link("htmlTagName", "Statement")
  set_hl_link("cssTagName", "Statement")
  set_hl_link("xmlTag", "Tag")
  set_hl_link("rubyConstant", "Constant")
  set_hl_link("pythonBuiltin", "Function")
  set_hl_link("markdownCode", "Constant")
  set_hl_link("markdownCodeBlock", "Constant")
  set_hl_link("markdownBold", "Statement")
  set_hl_link("markdownItalic", "Comment")
  set_hl("markdownItalic", nil, nil, "italic")
  set_hl_link("markdownLinkText", "Function")
  set_hl_link("markdownLinkUrl", "Underlined")
  set_hl_link("markdownHeading1", "Title")
  set_hl_link("markdownHeading2", "Title")

  -- Plugin highlights (only if not disabled)
  if not M.config.disable_plugin_highlights then
    -- NvimTree
    set_hl("NvimTreeRoot", colors.primary, nil, "bold")
    set_hl("NvimTreeFolderIcon", colors.secondary)
    set_hl("NvimTreeGitDirty", colors.primary_container)
    set_hl("NvimTreeGitNew", colors.tertiary_container)
    set_hl("NvimTreeIndentMarker", colors.outline_variant)
    set_hl("NvimTreeSymlink", colors.tertiary)

    -- Telescope
    set_hl("TelescopeNormal", colors.on_surface, colors.surface_container_low or colors.surface)
    set_hl("TelescopeBorder", colors.outline, colors.surface_container_low or colors.surface)
    set_hl("TelescopePromptNormal", colors.on_surface, colors.surface_container_high or colors.surface)
    set_hl("TelescopePromptBorder", colors.primary, colors.surface_container_high or colors.surface)
    set_hl("TelescopePromptPrefix", colors.primary, colors.surface_container_high or colors.surface, "bold")
    set_hl("TelescopeMatching", colors.primary, nil, "bold")
    set_hl("TelescopeSelection", colors.on_primary_container, colors.primary_container)

    -- Cmp (Completion)
    set_hl("CmpBorder", colors.outline_variant, colors.surface_container_low or colors.surface)
    set_hl("CmpMenu", colors.on_surface, colors.surface_container_low or colors.surface)
    set_hl("CmpItemKind", colors.outline)
    set_hl("CmpItemAbbr", colors.on_surface)
    set_hl("CmpItemAbbrDeprecated", colors.outline_variant, nil, "strikethrough")
    set_hl("CmpItemAbbrMatch", colors.primary, nil, "bold")
    set_hl("CmpItemAbbrMatchFuzzy", colors.primary, nil, "underline")
    set_hl("CmpItemMenu", colors.outline_variant)
    set_hl("CmpItemSel", colors.on_primary, colors.primary)
    set_hl("CmpDocBorder", colors.outline_variant, colors.surface_container or colors.surface)
    set_hl("CmpDoc", colors.on_surface, colors.surface_container or colors.surface)

    -- Gitsigns
    set_hl("GitSignsAdd", colors.tertiary, nil, "bold")
    set_hl("GitSignsChange", colors.primary, nil, "bold")
    set_hl("GitSignsDelete", colors.error, nil, "bold")
    set_hl("GitSignsChangeDelete", colors.error, nil, "bold")

    -- Bufferline / Barbar
    set_hl("BufferLineFill", colors.surface_container_lowest or colors.surface)
    set_hl(
      "BufferLineBuffer",
      colors.on_surface_variant or colors.on_surface,
      colors.surface_container_low or colors.surface
    )
    set_hl("BufferLineBufferSelected", colors.on_primary, colors.primary, "bold")
    set_hl("BufferLineTabSeparator", colors.background, colors.surface_container_lowest or colors.surface)
    set_hl("BufferLineBufferVisible", colors.on_surface, colors.surface_container or colors.surface)

    -- LspSaga
    set_hl("LspSagaBorderTitle", colors.primary)
    set_hl("LspSagaBorder", colors.outline)
    set_hl("LspSagaError", colors.error)
    set_hl("LspSagaWarning", colors.primary)
    set_hl("LspSagaInfo", colors.secondary)
    set_hl("LspSagaHint", colors.tertiary)
    set_hl("LspSagaDef", colors.primary)
    set_hl("LspSagaTypeDefinition", colors.secondary)
    set_hl("LspSagaDiagSource", colors.outline_variant)
    set_hl("LspSagaCodeActionTitle", colors.primary)
    set_hl("LspSagaCodeActionSelected", colors.on_primary, colors.primary)
  end

  -- General links to standard groups
  set_hl_link("CursorIM", "Normal")
end

---Applies Treesitter-specific highlight groups.
---@param colors table The table of color values (hex strings).
local function apply_treesitter_highlights(colors)
  if M.config.disable_treesitter_highlights then
    return
  end

  -- Treesitter highlight groups
  set_hl("@comment", colors.comment or colors.outline, nil, "italic")
  set_hl("@constant", colors.tertiary)
  set_hl("@constant.builtin", colors.tertiary_fixed or colors.tertiary)
  set_hl("@constant.macro", colors.tertiary_container)
  set_hl("@string", colors.secondary)
  set_hl("@string.escape", colors.tertiary)
  set_hl("@character", colors.secondary_fixed or colors.secondary)
  set_hl("@number", colors.tertiary)
  set_hl("@boolean", colors.tertiary)
  set_hl("@float", colors.tertiary)

  set_hl("@variable", colors.on_background)
  set_hl("@variable.builtin", colors.tertiary_fixed_dim or colors.tertiary)
  set_hl("@property", colors.primary_container)
  set_hl("@function", colors.primary)
  set_hl("@function.call", colors.primary)
  set_hl("@function.builtin", colors.primary_fixed_dim or colors.primary)
  set_hl("@function.macro", colors.primary_container)
  set_hl("@method", colors.primary)

  set_hl("@keyword", colors.primary)
  set_hl("@operator", colors.outline)
  set_hl("@exception", colors.error)
  set_hl("@type", colors.secondary_fixed or colors.secondary)
  set_hl("@type.builtin", colors.secondary_fixed_dim or colors.secondary)
  set_hl("@type.qualifier", colors.outline)
  set_hl("@type.definition", colors.tertiary_fixed or colors.tertiary)

  set_hl("@punctuation.delimiter", colors.outline)
  set_hl("@punctuation.bracket", colors.outline_variant)
  set_hl("@punctuation.special", colors.tertiary_fixed or colors.tertiary)

  set_hl("@tag", colors.primary_fixed or colors.primary)
  set_hl("@tag.attribute", colors.secondary_fixed or colors.secondary)
  set_hl("@tag.builtin", colors.primary_fixed_dim or colors.primary)

  set_hl("@text", colors.on_background)
  set_hl("@text.literal", colors.secondary_container)
  set_hl("@text.reference", colors.primary)
  set_hl("@text.title", colors.primary, nil, "bold")
  set_hl("@text.uri", colors.tertiary, nil, "underline")
  set_hl("@text.underline", nil, nil, "underline")
  set_hl("@text.todo", colors.on_tertiary, colors.tertiary_container, "bold")
  set_hl("@text.warning", colors.on_primary_container, colors.primary_container)
  set_hl("@text.danger", colors.on_error, colors.error_container)
  set_hl("@text.info", colors.on_secondary_container, colors.secondary_container)

  set_hl("@markup.heading", colors.primary, nil, "bold")
  set_hl("@markup.raw", colors.secondary_container)
  set_hl("@markup.list", colors.tertiary)
  set_hl("@markup.link", colors.tertiary, nil, "underline")
  set_hl("@markup.link.url", colors.outline, nil, "underline")
  set_hl("@markup.italic", nil, nil, "italic")
  set_hl("@markup.bold", nil, nil, "bold")
  set_hl("@markup.strikethrough", nil, nil, "strikethrough")

  set_hl("@diff.minus", colors.error_container)
  set_hl("@diff.plus", colors.tertiary_container)
  set_hl("@diff.delta", colors.primary_container)

  set_hl("@diagnostic.error", colors.error)
  set_hl("@diagnostic.warning", colors.primary)
  set_hl("@diagnostic.info", colors.secondary)
  set_hl("@diagnostic.hint", colors.tertiary)
  set_hl("@lsp.type.comment", colors.comment or colors.outline)
  set_hl("@lsp.type.keyword", colors.primary)
  set_hl("@lsp.type.variable", colors.on_background)
  set_hl("@lsp.type.function", colors.primary)
  set_hl("@lsp.type.method", colors.primary)
  set_hl("@lsp.type.enumMember", colors.tertiary)
  set_hl("@lsp.type.property", colors.primary_container)
  set_hl("@lsp.type.parameter", colors.tertiary_fixed_dim or colors.tertiary)
  set_hl("@lsp.type.namespace", colors.secondary)
  set_hl("@lsp.type.type", colors.secondary_fixed or colors.secondary)
  set_hl("@lsp.type.interface", colors.secondary_fixed or colors.secondary)
  set_hl("@lsp.type.struct", colors.secondary_fixed or colors.secondary)
  set_hl("@lsp.type.enum", colors.secondary_fixed or colors.secondary)
  set_hl("@lsp.type.class", colors.secondary_fixed or colors.secondary)
  set_hl("@lsp.type.event", colors.tertiary_fixed or colors.tertiary)
  set_hl("@lsp.type.macro", colors.tertiary_container)
end

---Applies custom user highlight overrides
---@param colors table The table of color values (hex strings).
local function apply_custom_highlights(colors)
  if not M.config.custom_highlights then
    return
  end

  for group, opts in pairs(M.config.custom_highlights) do
    local fg, bg, style = nil, nil, nil

    if type(opts) == "string" then
      -- Simple color string
      fg = opts
    elseif type(opts) == "table" then
      fg = opts.fg or opts[1]
      bg = opts.bg or opts[2]
      style = opts.style or opts[3]

      -- Allow color references like "colors.primary"
      if fg and type(fg) == "string" and fg:match("^colors%.") then
        local color_key = fg:match("^colors%.(.+)$")
        fg = colors[color_key]
      end
      if bg and type(bg) == "string" and bg:match("^colors%.") then
        local color_key = bg:match("^colors%.(.+)$")
        bg = colors[color_key]
      end
    end

    if fg or bg or style then
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
  end
end

---Loads the Matugen-generated colorscheme.
function M.load_matugen_colorscheme()
  local colors_file_path = expand_path(M.config.file)
  current_background_style = M.config.background_style

  if vim.fn.filereadable(colors_file_path) == 0 then
    vim.notify(
      "Matugen colors file not found at: " .. colors_file_path,
      vim.log.levels.ERROR,
      { title = "Matugen.nvim" }
    )
    if not M.config.disable_generation_hint then
      vim.notify(
        "Please generate it using Matugen, e.g.: matugen generate -i /path/to/your/image.jpg -t /path/to/your/template.jsonc -o "
          .. colors_file_path,
        vim.log.levels.INFO,
        { title = "Matugen.nvim" }
      )
    end
    return
  end

  local colors = read_matugen_colors_file(colors_file_path)
  if not colors then
    return
  end

  loaded_colors = colors
  apply_base_highlights(loaded_colors, current_background_style)

  -- Apply Treesitter highlights immediately if available
  if vim.treesitter and vim.treesitter.highlighter then
    apply_treesitter_highlights(loaded_colors)
  end

  -- Apply custom highlights last
  apply_custom_highlights(loaded_colors)

  if not M.config.disable_notifications then
    vim.notify("Matugen colorscheme loaded successfully!", vim.log.levels.INFO, { title = "Matugen.nvim" })
  end
end

---Setup function for the plugin.
---@param opts table|nil User configuration options.
function M.setup(opts)
  -- Default configuration
  local defaults = {
    file = vim.fn.stdpath("cache") .. "/matugen/colors.jsonc",
    background_style = "dark", -- "dark" or "light"
    auto_load = true, -- Auto-load on VimEnter
    disable_clear = false, -- Don't clear existing highlights
    disable_plugin_highlights = false, -- Don't apply plugin-specific highlights
    disable_treesitter_highlights = false, -- Don't apply Treesitter highlights
    disable_notifications = false, -- Don't show notifications
    disable_generation_hint = false, -- Don't show generation hint when file not found
    ignore_groups = {}, -- Table of highlight groups to ignore: { "Normal" = true, "Comment" = true }
    custom_highlights = {}, -- Custom highlight overrides
  }

  -- Handle both opts and config function patterns
  if type(opts) == "function" then
    opts = opts()
  end

  -- Merge user options with defaults
  M.config = vim.tbl_deep_extend("force", defaults, opts or {})

  -- Validate configuration
  if M.config.background_style ~= "dark" and M.config.background_style ~= "light" then
    vim.notify(
      "Invalid background_style: " .. M.config.background_style .. ". Using 'dark' instead.",
      vim.log.levels.WARN,
      { title = "Matugen.nvim" }
    )
    M.config.background_style = "dark"
  end

  -- Define user commands
  vim.api.nvim_create_user_command("MatugenColorschemeLoad", function()
    M.load_matugen_colorscheme()
  end, {
    desc = "Load the Matugen-generated colorscheme",
  })

  vim.api.nvim_create_user_command("MatugenColorschemeReload", function()
    M.load_matugen_colorscheme()
  end, {
    desc = "Reload the Matugen-generated colorscheme",
  })

  vim.api.nvim_create_user_command("MatugenColorschemeToggle", function()
    M.config.background_style = M.config.background_style == "dark" and "light" or "dark"
    M.load_matugen_colorscheme()
  end, {
    desc = "Toggle between light and dark background styles",
  })

  -- Auto-load on VimEnter if enabled
  if M.config.auto_load then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("MatugenColorschemeAutoLoad", { clear = true }),
      callback = function()
        M.load_matugen_colorscheme()
      end,
    })
  end

  -- Autocmd for Treesitter-specific highlights
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("MatugenTreesitterHighlights", { clear = true }),
    callback = function()
      -- Only apply if our colorscheme is active and we have loaded colors
      if vim.g.colors_name == "matugen_colors" and next(loaded_colors) ~= nil then
        apply_treesitter_highlights(loaded_colors)
        apply_custom_highlights(loaded_colors)
      end
    end,
  })
end

-- Function to get the currently loaded colors (useful for other plugins)
function M.get_colors()
  return loaded_colors
end

-- Function to get the current config
function M.get_config()
  return M.config
end

-- Function to update configuration at runtime
function M.update_config(new_opts)
  M.config = vim.tbl_deep_extend("force", M.config, new_opts or {})
end

return M
