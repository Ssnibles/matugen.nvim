-- Ssnibles/matugen.nvim/lua/matugen_colorscheme/init.lua

local M = {}

-- Global variable to store loaded colors
local loaded_colors = {}

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
  local without_block_comments = jsonc_content:gsub("/%*%X*?%*/", "")
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

---Applies highlight groups based on the loaded colors.
---@param colors table The table of color values (hex strings).
---@param background_style string "dark" or "light"
local function apply_highlights(colors, background_style)
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  vim.o.background = background_style

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

  -- Base Neovim UI Colors
  -- Normal text and background
  set_hl("Normal", colors.on_background, colors.background)
  -- Background for floating windows (e.g., LSP, healthcheck)
  set_hl("NormalFloat", colors.on_surface, colors.surface_container_low)
  -- Border for floating windows
  set_hl("FloatBorder", colors.outline_variant, colors.surface_container_low)
  -- Main window separator
  set_hl("VertSplit", colors.outline_variant, colors.background)
  -- Popup Menu (completion, hover docs)
  set_hl("Pmenu", colors.on_surface, colors.surface_container)
  set_hl("PmenuSel", colors.on_primary, colors.primary) -- Selected item in Pmenu
  set_hl("PmenuSbar", nil, colors.surface_variant) -- Scrollbar in Pmenu
  set_hl("PmenuThumb", nil, colors.on_surface_variant) -- Thumb of scrollbar

  -- Line Numbers, Sign Column, Fold Column
  set_hl("LineNr", colors.outline, colors.background)
  set_hl("SignColumn", colors.outline, colors.background)
  set_hl("FoldColumn", colors.outline, colors.background)

  -- Cursorline and Number
  set_hl("CursorLine", nil, colors.surface_container_low) -- Highlight current line
  set_hl("CursorLineNr", colors.primary, colors.surface_container_low, "bold") -- Highlight line number on current line

  -- Visual mode selection
  set_hl("Visual", nil, colors.surface_variant) -- Visual selection background
  set_hl("VisualNOS", nil, colors.surface_variant) -- Non-owned visual selection (e.g., from another client)

  -- Search and IncSearch
  set_hl("IncSearch", colors.on_secondary, colors.secondary_container, "bold") -- Incremental search match
  set_hl("Search", colors.on_tertiary, colors.tertiary_container) -- Other search matches

  -- Diagnostics (errors, warnings, info, hints)
  set_hl("ErrorMsg", colors.on_error, colors.error_container, "bold")
  set_hl("WarningMsg", colors.on_primary_container, colors.primary_container, "bold") -- Reusing primary for warnings
  set_hl("InfoMsg", colors.on_secondary_container, colors.secondary_container) -- Info messages
  set_hl("HintMsg", colors.on_tertiary_container, colors.tertiary_container) -- Hint messages

  -- Diffs
  set_hl("DiffAdd", colors.on_tertiary_container, colors.tertiary_container) -- Added lines
  set_hl("DiffChange", colors.on_primary_container, colors.primary_container) -- Changed lines
  set_hl("DiffDelete", colors.on_error_container, colors.error_container) -- Deleted lines
  set_hl("DiffText", colors.on_secondary_container, colors.secondary_container) -- Changed text within a line

  -- Statusline and Tabline
  set_hl("StatusLine", colors.on_surface, colors.surface_container_high)
  set_hl("StatusLineNC", colors.outline, colors.surface_container_low) -- Non-current statusline
  set_hl("TabLine", colors.on_surface_variant, colors.surface_container_lowest)
  set_hl("TabLineFill", colors.on_surface_variant, colors.surface_container_lowest)
  set_hl("TabLineSel", colors.on_primary, colors.primary, "bold")

  -- Command Line
  set_hl("CmdLine", colors.on_surface, colors.background)

  -- Spell checking
  set_hl("SpellBad", colors.on_error, colors.error_container, "underline")
  set_hl("SpellCap", colors.on_primary_container, colors.primary_container, "underline")
  set_hl("SpellRare", colors.on_secondary_container, colors.secondary_container, "underline")
  set_hl("SpellLocal", colors.on_tertiary_container, colors.tertiary_container, "underline")

  -- Other UI elements
  set_hl("ColorColumn", nil, colors.surface_container_lowest) -- Column for `colorcolumn` option
  set_hl("Cursor", colors.background, colors.on_background) -- Invert foreground/background at cursor
  set_hl("lCursor", colors.background, colors.on_background) -- Like Cursor, for language-specific cursor
  set_hl("MatchParen", colors.on_primary, colors.primary_container, "bold") -- Matching parenthesis
  set_hl("NonText", colors.outline_variant) -- '@' at end of buffer, etc.
  set_hl("Whitespace", colors.outline_variant) -- Invisible characters like tabs, spaces
  set_hl("Conceal", colors.outline_variant) -- Concealed text
  set_hl("Directory", colors.primary) -- Directory names
  set_hl("Title", colors.primary) -- Title of `:help` or startup screen
  set_hl("ModeMsg", colors.primary_container) -- Mode message in command line
  set_hl("MoreMsg", colors.tertiary) -- Hit ENTER to continue message
  set_hl("Question", colors.secondary) -- Yes/No questions
  set_hl("Folded", colors.on_surface_variant, colors.surface_container_high, "italic") -- Folded lines

  -- Syntax Highlighting (Common groups, adjusted for expressive palette)
  -- Comments should be subtle
  set_hl("Comment", colors.outline, nil, "italic")
  -- Constants (numbers, booleans, etc.)
  set_hl("Constant", colors.tertiary)
  set_hl("String", colors.secondary)
  set_hl("Character", colors.secondary_fixed) -- A slightly different shade for characters
  set_hl("Number", colors.tertiary)
  set_hl("Boolean", colors.tertiary)
  set_hl("Float", colors.tertiary)

  -- Identifiers (variable names, function names)
  set_hl("Identifier", colors.primary_container) -- Make identifiers stand out a bit less than functions
  set_hl("Function", colors.primary) -- Function definitions/calls

  -- Keywords and statements
  set_hl("Statement", colors.primary, nil, "bold") -- `if`, `for`, `while`, etc.
  set_hl("Conditional", colors.primary)
  set_hl("Repeat", colors.primary)
  set_hl("Label", colors.primary_fixed_dim) -- For goto labels, etc.
  set_hl("Operator", colors.outline) -- Operators like +, -, =
  set_hl("Keyword", colors.primary)
  set_hl("Exception", colors.error) -- `try`, `catch`, `throw`

  -- Preprocessor directives, includes, defines
  set_hl("PreProc", colors.secondary)
  set_hl("Include", colors.secondary)
  set_hl("Define", colors.secondary)
  set_hl("Macro", colors.secondary)
  set_hl("PreCondit", colors.secondary)

  -- Types, storage classes, structures, typedefs
  set_hl("Type", colors.tertiary_fixed) -- Distinct color for types
  set_hl("StorageClass", colors.tertiary_fixed)
  set_hl("Structure", colors.tertiary_fixed)
  set_hl("Typedef", colors.tertiary_fixed)

  -- Special characters, tags, delimiters
  set_hl("Special", colors.tertiary_container) -- Special characters, e.g., in regex
  set_hl("SpecialChar", colors.tertiary_container)
  set_hl("Tag", colors.tertiary_container) -- HTML/XML tags
  set_hl("Delimiter", colors.outline) -- Brackets, commas, etc.
  set_hl("SpecialComment", colors.tertiary, nil, "italic") -- Special comments like TODO, FIXME

  -- Underlined, Ignored, Error, Todo
  set_hl("Underlined", nil, nil, "underline")
  set_hl("Ignore", colors.background, colors.background) -- As discussed, makes it blend in
  set_hl("Todo", colors.on_tertiary, colors.tertiary_container, "bold") -- Clearly visible TODOs

  -- Link common groups for consistency
  vim.cmd("highlight link htmlTag Tag")
  vim.cmd("highlight link htmlTagName Statement")
  vim.cmd("highlight link cssTagName Statement")
  vim.cmd("highlight link xmlTag Tag")
  vim.cmd("highlight link rubyConstant Constant")
  vim.cmd("highlight link pythonBuiltin Function") -- Python built-in functions
  vim.cmd("highlight link markdownCode Constant")
  vim.cmd("highlight link markdownCodeBlock Constant")
  vim.cmd("highlight link markdownBold Statement")
  vim.cmd("highlight link markdownItalic Comment")
  vim.cmd("highlight link markdownLinkText Function")
  vim.cmd("highlight link markdownLinkUrl Underlined")
  vim.cmd("highlight link markdownHeading1 Title")
  vim.cmd("highlight link markdownHeading2 Title")
  -- ... add more links for various plugins/filetypes as needed

  -- Treesitter highlight group links (Crucial for modern Neovim)
  -- This is a starting point, you might need to adjust based on your specific TS setup.
  set_hl("@comment", colors.comment, nil, "italic")
  set_hl("@constant", colors.tertiary)
  set_hl("@constant.builtin", colors.tertiary_fixed)
  set_hl("@constant.macro", colors.tertiary_container)
  set_hl("@string", colors.secondary)
  set_hl("@string.escape", colors.tertiary) -- For escape sequences
  set_hl("@character", colors.secondary_fixed)
  set_hl("@number", colors.tertiary)
  set_hl("@boolean", colors.tertiary)
  set_hl("@float", colors.tertiary)

  set_hl("@variable", colors.on_background)
  set_hl("@variable.builtin", colors.tertiary_fixed_dim)
  set_hl("@property", colors.primary_container) -- Object properties/keys
  set_hl("@function", colors.primary)
  set_hl("@function.call", colors.primary)
  set_hl("@function.builtin", colors.primary_fixed_dim)
  set_hl("@function.macro", colors.primary_container)
  set_hl("@method", colors.primary) -- Object methods

  set_hl("@keyword", colors.primary)
  set_hl("@operator", colors.outline)
  set_hl("@exception", colors.error)
  set_hl("@type", colors.secondary_fixed)
  set_hl("@type.builtin", colors.secondary_fixed_dim)
  set_hl("@type.qualifier", colors.outline) -- e.g., `const`, `static`
  set_hl("@type.definition", colors.tertiary_fixed)

  set_hl("@punctuation.delimiter", colors.outline)
  set_hl("@punctuation.bracket", colors.outline_variant)
  set_hl("@punctuation.special", colors.tertiary_fixed)

  set_hl("@tag", colors.primary_fixed)
  set_hl("@tag.attribute", colors.secondary_fixed)
  set_hl("@tag.builtin", colors.primary_fixed_dim)

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
  set_hl("@markup.raw", colors.secondary_container) -- For code blocks in markdown
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
  set_hl("@lsp.type.comment", colors.comment)
  set_hl("@lsp.type.keyword", colors.primary)
  set_hl("@lsp.type.variable", colors.on_background)
  set_hl("@lsp.type.function", colors.primary)
  set_hl("@lsp.type.method", colors.primary)
  set_hl("@lsp.type.enumMember", colors.tertiary)
  set_hl("@lsp.type.property", colors.primary_container)
  set_hl("@lsp.type.parameter", colors.tertiary_fixed_dim)
  set_hl("@lsp.type.namespace", colors.secondary)
  set_hl("@lsp.type.type", colors.secondary_fixed)
  set_hl("@lsp.type.interface", colors.secondary_fixed)
  set_hl("@lsp.type.struct", colors.secondary_fixed)
  set_hl("@lsp.type.enum", colors.secondary_fixed)
  set_hl("@lsp.type.class", colors.secondary_fixed)
  set_hl("@lsp.type.event", colors.tertiary_fixed)
  set_hl("@lsp.type.macro", colors.tertiary_container)

  -- More specific linking or overrides for common plugins
  -- NvimTree
  set_hl("NvimTreeRoot", colors.primary, nil, "bold")
  set_hl("NvimTreeFolderIcon", colors.secondary)
  set_hl("NvimTreeGitDirty", colors.primary_container)
  set_hl("NvimTreeGitNew", colors.tertiary_container)
  set_hl("NvimTreeIndentMarker", colors.outline_variant)
  set_hl("NvimTreeSymlink", colors.tertiary)

  -- Telescope
  set_hl("TelescopeNormal", colors.on_surface, colors.surface_container_low)
  set_hl("TelescopeBorder", colors.outline, colors.surface_container_low)
  set_hl("TelescopePromptNormal", colors.on_surface, colors.surface_container_high)
  set_hl("TelescopePromptBorder", colors.primary, colors.surface_container_high)
  set_hl("TelescopePromptPrefix", colors.primary, colors.surface_container_high, "bold")
  set_hl("TelescopeMatching", colors.primary, nil, "bold")
  set_hl("TelescopeSelection", colors.on_primary_container, colors.primary_container)

  -- Cmp (Completion)
  set_hl("CmpBorder", colors.outline_variant, colors.surface_container_low)
  set_hl("CmpMenu", colors.on_surface, colors.surface_container_low)
  set_hl("CmpItemKind", colors.outline) -- Icon kind (e.g., function, variable)
  set_hl("CmpItemAbbr", colors.on_surface) -- Abbreviation (text itself)
  set_hl("CmpItemAbbrDeprecated", colors.outline_variant, nil, "strikethrough")
  set_hl("CmpItemAbbrMatch", colors.primary, nil, "bold")
  set_hl("CmpItemAbbrMatchFuzzy", colors.primary, nil, "underline")
  set_hl("CmpItemMenu", colors.outline_variant) -- Source name
  set_hl("CmpItemSel", colors.on_primary, colors.primary) -- Selected item
  set_hl("CmpDocBorder", colors.outline_variant, colors.surface_container)
  set_hl("CmpDoc", colors.on_surface, colors.surface_container)

  -- Gitsigns
  set_hl("GitSignsAdd", colors.tertiary, nil, "bold")
  set_hl("GitSignsChange", colors.primary, nil, "bold")
  set_hl("GitSignsDelete", colors.error, nil, "bold")
  set_hl("GitSignsChangeDelete", colors.error, nil, "bold") -- For mixed changes

  -- Bufferline / Barbar (if used)
  set_hl("BufferLineFill", colors.surface_container_lowest)
  set_hl("BufferLineBuffer", colors.on_surface_variant, colors.surface_container_low)
  set_hl("BufferLineBufferSelected", colors.on_primary, colors.primary, "bold")
  set_hl("BufferLineTabSeparator", colors.background, colors.surface_container_lowest)
  set_hl("BufferLineBufferVisible", colors.on_surface, colors.surface_container)

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

  -- General links to standard groups
  -- Ensure that if a plugin doesn't define its own groups, it falls back nicely
  vim.cmd("highlight link CursorIM Normal") -- For input method
  vim.cmd("highlight link Search Highlight") -- Old name for search, often linked

  -- And many more as you integrate specific plugins!
end

---Loads the Matugen-generated colorscheme.
function M.load_matugen_colorscheme()
  local colors_file_path = expand_path(M.config.file)

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
    return
  end

  loaded_colors = colors
  apply_highlights(loaded_colors, M.config.background_style)
  vim.notify("Matugen colorscheme loaded successfully!", vim.log.levels.INFO, { title = "Matugen.nvim" })
end

---Setup function for the plugin.
---@param opts table User configuration options.
function M.setup(opts)
  -- Default configuration
  M.config = {
    file = vim.fn.stdpath("cache") .. "/matugen/colors.jsonc",
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

  -- Autocmd to load on VimEnter
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
