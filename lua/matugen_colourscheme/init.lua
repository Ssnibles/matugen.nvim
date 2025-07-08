-- Ssnibles/matugen.nvim/lua/matugen_coloursscheme/init.lua

local M = {}

-- Global variable to store loaded colourss
local loaded_colourss = {}
-- Global variable to store the current background style, updated by config or toggle
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
--- This function handles both single-line (//) and multi-line (/* ... */) comments.
--- @param jsonc_content string The JSONC content as a string.
--- @return string The JSON content without comments.
local function strip_jsonc_comments(jsonc_content)
  -- Remove multi-line comments /* ... */
  local without_block_comments = jsonc_content:gsub("/%*.-\\%*/", "")
  -- Remove single-line comments // ... to end of line
  local without_comments = without_block_comments:gsub("//[^\n\r]*", "")
  return without_comments
end

---Reads and parses the Matugen-generated JSONC file.
---@param file_path string The path to the JSONC file.
---@return table|nil The parsed colourss table, or nil if an error occurred.
local function read_matugen_colourss_file(file_path)
  local f = io.open(file_path, "r")
  if not f then
    vim.notify("Matugen colourss file not found at: " .. file_path, vim.log.levels.ERROR, { title = "Matugen.nvim" })
    return nil
  end

  local content = f:read("*a")
  f:close()

  local json_content = strip_jsonc_comments(content)

  local success, colourss = pcall(vim.json.decode, json_content)
  if not success then
    vim.notify(
      "Error decoding Matugen colourss JSON from " .. file_path .. ": " .. colourss,
      vim.log.levels.ERROR,
      { title = "Matugen.nvim" }
    )
    return nil
  end

  return colourss
end

--- Helper for setting highlights with override check
--- This function centralizes the logic for applying highlights and respecting `ignore_groups`.
--- @param group string The highlight group name.
--- @param fg string|nil Foreground colours (hex string or "NONE").
--- @param bg string|nil Background colours (hex string or "NONE").
--- @param style string|nil Style (e.g., "bold", "italic", "underline", "reverse").
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

--- Helper for setting highlight links with override check
--- This function centralizes the logic for linking highlights and respecting `ignore_groups`.
--- @param from string The highlight group to link from.
--- @param to string The highlight group to link to.
local function set_hl_link(from, to)
  if M.config.ignore_groups and M.config.ignore_groups[from] then
    return
  end
  vim.cmd("highlight link " .. from .. " " .. to)
end

--- Applies general highlight groups based on the loaded colourss.
--- @param colourss table The table of colours values (hex strings).
--- @param background_style string "dark" or "light"
local function apply_base_highlights(colourss, background_style)
  -- Clear existing highlights before applying new ones
  if not M.config.disable_clear then
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
      vim.cmd("syntax reset")
    end
  end

  vim.o.background = background_style
  vim.g.colourss_name = "matugen_colourss"

  -- Determine background colourss based on transparent_background option
  local bg_normal = M.config.transparent_background and "NONE" or colourss.background
  local bg_float = M.config.transparent_background and "NONE" or (colourss.surface_container_low or colourss.surface)
  local bg_pmenu = M.config.transparent_background and "NONE" or (colourss.surface_container or colourss.surface)
  local bg_statusline = M.config.transparent_background and "NONE"
    or (colourss.surface_container_high or colourss.surface)
  local bg_tabline = M.config.transparent_background and "NONE"
    or (colourss.surface_container_lowest or colourss.surface)
  local bg_cursorline = M.config.transparent_background and "NONE"
    or (colourss.surface_container_low or colourss.surface)
  local bg_cmdline = M.config.transparent_background and "NONE" or colourss.background
  local bg_col_line = M.config.transparent_background and "NONE"
    or (colourss.surface_container_lowest or colourss.surface)
  local bg_visual = M.config.transparent_background and "NONE" or colourss.surface_variant

  -- Define consistent foreground colourss for UI elements
  local ui_normal_fg = colourss.outline or colourss.on_surface_variant -- For subtle UI elements
  local ui_active_fg = colourss.on_surface -- For more prominent UI elements

  --- Base Neovim UI colourss ---
  -- Normal text (consistent throughout the main buffer)
  set_hl("Normal", colourss.on_background, bg_normal)
  set_hl("NormalNC", colourss.on_surface_variant, bg_normal) -- Non-current windows: slightly muted but still readable
  set_hl("NormalFloat", colourss.on_surface, bg_float)

  -- Borders and Separators (consistent, subtle visibility)
  set_hl("FloatBorder", colourss.outline_variant, bg_float)
  set_hl("VertSplit", colourss.outline, bg_normal)
  set_hl("WinSeparator", colourss.outline, bg_normal)

  -- Pop-up Menu (Pmenu)
  set_hl("Pmenu", colourss.on_surface, bg_pmenu)
  set_hl("PmenuSel", colourss.on_primary, colourss.primary) -- Strong contrast for selection
  set_hl("PmenuSbar", nil, bg_pmenu)
  set_hl("PmenuThumb", nil, colourss.primary_fixed) -- Clear scrollbar thumb
  set_hl("FloatFooter", colourss.on_surface, bg_float)
  set_hl("FloatHeader", colourss.on_surface, bg_float)

  --- Line Numbers, Sign Column, Fold Column (subtle and consistent) ---
  set_hl("LineNr", ui_normal_fg, bg_normal)
  set_hl("LineNrAbove", ui_normal_fg, bg_normal)
  set_hl("LineNrBelow", ui_normal_fg, bg_normal)
  set_hl("SignColumn", ui_normal_fg, bg_normal)
  set_hl("FoldColumn", ui_normal_fg, bg_normal)

  --- Cursorline and Number (clear emphasis) ---
  set_hl("CursorLine", nil, bg_cursorline)
  set_hl("CursorLineNr", colourss.primary_fixed, bg_cursorline, "bold") -- Strong emphasis on active line number
  set_hl("CursorColumn", nil, bg_cursorline)

  --- Visual mode selection (distinct but not jarring) ---
  set_hl("Visual", nil, bg_visual)
  set_hl("VisualNOS", nil, bg_visual)

  --- Search and IncSearch (high contrast for visibility) ---
  set_hl("IncSearch", colourss.on_secondary, colourss.secondary_container, "bold")
  set_hl("Search", colourss.on_tertiary, colourss.tertiary_container)

  --- Diagnostics (clear and impactful) ---
  set_hl("ErrorMsg", colourss.on_error, colourss.error, "bold")
  set_hl("WarningMsg", colourss.on_primary_container, colourss.primary_container, "bold")
  set_hl("InfoMsg", colourss.on_secondary_container, colourss.secondary_container)
  set_hl("HintMsg", colourss.on_tertiary_container, colourss.tertiary_container)

  -- LSP Diagnostics (linking to general diagnostic messages for consistency)
  set_hl_link("LspDiagnosticsError", "ErrorMsg")
  set_hl_link("LspDiagnosticsWarning", "WarningMsg")
  set_hl_link("LspDiagnosticsInformation", "InfoMsg")
  set_hl_link("LspDiagnosticsHint", "HintMsg")

  --- Diffs (semantic and clear distinctions) ---
  set_hl("DiffAdd", colourss.on_tertiary_container, colourss.tertiary_container)
  set_hl("DiffChange", colourss.on_primary_container, colourss.primary_container)
  set_hl("DiffDelete", colourss.on_error_container, colourss.error_container)
  set_hl("DiffText", colourss.on_secondary_container, colourss.secondary_container)

  --- Statusline and Tabline (subtle hierarchy, clear active state) ---
  set_hl("StatusLine", colourss.on_surface, bg_statusline)
  set_hl("StatusLineNC", colourss.outline, bg_float) -- Inactive statusline uses float background
  set_hl("TabLine", colourss.on_surface_variant, bg_tabline)
  set_hl("TabLineFill", colourss.on_surface_variant, bg_tabline)
  set_hl("TabLineSel", colourss.on_primary, colourss.primary, "bold")

  --- Command Line ---
  set_hl("CmdLine", colourss.on_surface, bg_cmdline)

  --- Spell checking (distinct underlines with clear foregrounds) ---
  set_hl("SpellBad", colourss.on_error, colourss.error_container, "underline")
  set_hl("SpellCap", colourss.on_primary_container, colourss.primary_container, "underline")
  set_hl("SpellRare", colourss.on_secondary_container, colourss.secondary_container, "underline")
  set_hl("SpellLocal", colourss.on_tertiary_container, colourss.tertiary_container, "underline")

  --- Other UI elements (consistent and less "coloursful" where possible) ---
  set_hl("coloursColumn", nil, bg_col_line)
  set_hl("Cursor", colourss.background, colourss.on_background)
  set_hl("lCursor", colourss.background, colourss.on_background)
  set_hl("MatchParen", colourss.on_primary, colourss.primary_container, "bold")
  set_hl("NonText", ui_normal_fg) -- Consistent with line numbers
  set_hl("Whitespace", ui_normal_fg) -- Consistent with line numbers
  set_hl("Conceal", ui_normal_fg)
  set_hl("Directory", colourss.primary) -- Primary for directories
  set_hl("Title", colourss.primary)
  set_hl("ModeMsg", colourss.primary_container)
  set_hl("MoreMsg", colourss.tertiary)
  set_hl("Question", colourss.secondary)
  set_hl("Folded", colourss.on_surface_variant, bg_statusline, "italic")
  set_hl("EndOfBuffer", ui_normal_fg)
  set_hl("SpecialKey", ui_normal_fg)

  --- Basic Syntax Highlighting (often falls back if TS is not active) ---
  set_hl("Comment", colourss.comment or colourss.outline, nil, "italic")
  set_hl("Constant", colourss.tertiary_fixed) -- General constants, numbers, floats
  set_hl("String", colourss.secondary_fixed)
  set_hl("Character", colourss.secondary_fixed)
  set_hl("Number", colourss.tertiary_fixed)
  set_hl("Boolean", colourss.on_error_container or colourss.error) -- More distinct for booleans (e.g., true/false)
  set_hl("Float", colourss.tertiary_fixed)
  set_hl("Identifier", colourss.on_surface) -- Consistent with Normal text
  set_hl("Function", colourss.primary_fixed)
  set_hl("Statement", colourss.primary, nil, "bold") -- General keywords, flow control
  set_hl("Conditional", colourss.primary_fixed_dim or colourss.primary, nil, "bold") -- Specific for 'if', 'else', 'switch'
  set_hl("Repeat", colourss.primary_fixed_dim or colourss.primary, nil, "bold") -- Specific for 'for', 'while'
  set_hl("Label", colourss.primary_fixed_dim or colourss.primary)
  set_hl("Operator", colourss.on_surface_variant)
  set_hl("Keyword", colourss.primary)
  set_hl("Exception", colourss.error)
  set_hl("PreProc", colourss.secondary)
  set_hl("Include", colourss.secondary)
  set_hl("Define", colourss.secondary)
  set_hl("Macro", colourss.secondary)
  set_hl("PreCondit", colourss.secondary)
  set_hl("Type", colourss.secondary_fixed_dim or colourss.secondary) -- Types, storage classes, structs
  set_hl("StorageClass", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("Structure", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("Typedef", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("Special", colourss.tertiary_container)
  set_hl("SpecialChar", colourss.tertiary_container)
  set_hl("Tag", colourss.primary_fixed)
  set_hl("Delimiter", colourss.outline)
  set_hl("SpecialComment", colourss.tertiary, nil, "italic")
  set_hl("Underlined", nil, nil, "underline")
  set_hl("Ignore", colourss.background, colourss.background)
  set_hl("Todo", colourss.on_tertiary, colourss.tertiary_container, "bold")

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
  set_hl("markdownItalic", colourss.comment or colourss.outline, nil, "italic")
  set_hl_link("markdownLinkText", "Function")
  set_hl_link("markdownLinkUrl", "Underlined")
  set_hl_link("markdownHeading1", "Title")
  set_hl_link("markdownHeading2", "Title")
  set_hl_link("markdownHeading3", "Title")
  set_hl_link("markdownHeading4", "Title")
  set_hl_link("markdownHeading5", "Title")
  set_hl_link("markdownHeading6", "Title")

  --- Plugin highlights (only if not disabled) ---
  if not M.config.disable_plugin_highlights then
    -- NvimTree
    set_hl("NvimTreeRoot", colourss.primary, nil, "bold")
    set_hl("NvimTreeFolderIcon", colourss.secondary)
    set_hl("NvimTreeGitDirty", colourss.tertiary)
    set_hl("NvimTreeGitNew", colourss.tertiary_fixed)
    set_hl("NvimTreeIndentMarker", colourss.outline_variant)
    set_hl("NvimTreeSymlink", colourss.tertiary)

    -- Telescope
    set_hl("TelescopeNormal", colourss.on_surface, bg_float)
    set_hl("TelescopeBorder", colourss.outline, bg_float)
    set_hl("TelescopePromptNormal", colourss.on_surface, bg_statusline)
    set_hl("TelescopePromptBorder", colourss.primary, bg_statusline)
    set_hl("TelescopePromptPrefix", colourss.primary, bg_statusline, "bold")
    set_hl("TelescopeMatching", colourss.primary, nil, "bold")
    set_hl("TelescopeSelection", colourss.on_primary_container, colourss.primary_container)
    set_hl_link("TelescopeResultsNormal", "NormalFloat")
    set_hl_link("TelescopeResultsSelection", "TelescopeSelection")

    -- Cmp (Completion) - aiming for consistency in kind colourss
    set_hl("CmpBorder", colourss.outline_variant, bg_float)
    set_hl("CmpMenu", colourss.on_surface, bg_float)
    set_hl("CmpItemKind", ui_normal_fg) -- Default kind colours
    set_hl("CmpItemKindText", colourss.on_surface)
    set_hl("CmpItemKindMethod", colourss.primary_fixed)
    set_hl("CmpItemKindFunction", colourss.primary_fixed)
    set_hl("CmpItemKindConstructor", colourss.primary_fixed)
    set_hl("CmpItemKindField", colourss.tertiary_fixed)
    set_hl("CmpItemKindVariable", colourss.on_surface)
    set_hl("CmpItemKindClass", colourss.secondary_fixed)
    set_hl("CmpItemKindInterface", colourss.secondary_fixed)
    set_hl("CmpItemKindModule", colourss.secondary)
    set_hl("CmpItemKindProperty", colourss.tertiary_fixed)
    set_hl("CmpItemKindUnit", colourss.tertiary_fixed_dim)
    set_hl("CmpItemKindValue", colourss.tertiary_fixed_dim)
    set_hl("CmpItemKindEnum", colourss.secondary_fixed)
    set_hl("CmpItemKindKeyword", colourss.primary)
    set_hl("CmpItemKindSnippet", colourss.tertiary_container)
    set_hl("CmpItemKindcolours", colourss.tertiary)
    set_hl("CmpItemKindFile", colourss.primary_container)
    set_hl("CmpItemKindReference", colourss.primary)
    set_hl("CmpItemKindFolder", colourss.secondary)
    set_hl("CmpItemKindEnumMember", colourss.tertiary_fixed_dim)
    set_hl("CmpItemKindConstant", colourss.tertiary_fixed_dim)
    set_hl("CmpItemKindStruct", colourss.secondary_fixed)
    set_hl("CmpItemKindEvent", colourss.tertiary_fixed_dim)
    set_hl("CmpItemKindOperator", colourss.outline)
    set_hl("CmpItemKindTypeParameter", colourss.secondary_fixed)
    set_hl("CmpItemAbbr", colourss.on_surface)
    set_hl("CmpItemAbbrDeprecated", colourss.outline_variant, nil, "strikethrough")
    set_hl("CmpItemAbbrMatch", colourss.primary, nil, "bold")
    set_hl("CmpItemAbbrMatchFuzzy", colourss.primary, nil, "underline")
    set_hl("CmpItemMenu", colourss.outline_variant)
    set_hl("CmpItemSel", colourss.on_primary, colourss.primary)
    set_hl("CmpDocBorder", colourss.outline_variant, bg_pmenu)
    set_hl("CmpDoc", colourss.on_surface, bg_pmenu)

    -- Gitsigns
    set_hl("GitSignsAdd", colourss.tertiary, nil, "bold")
    set_hl("GitSignsChange", colourss.primary, nil, "bold")
    set_hl("GitSignsDelete", colourss.error, nil, "bold")
    set_hl("GitSignsChangeDelete", colourss.error, nil, "bold")

    -- Bufferline / Barbar
    set_hl("BufferLineFill", bg_tabline)
    set_hl(
      "BufferLineBuffer",
      colourss.on_surface_variant,
      bg_float -- Use float background for inactive buffers for consistency
    )
    set_hl("BufferLineBufferSelected", colourss.on_primary, colourss.primary, "bold")
    set_hl("BufferLineTabSeparator", colourss.background, bg_tabline)
    set_hl("BufferLineBufferVisible", colourss.on_surface, bg_pmenu)

    -- LspSaga
    set_hl("LspSagaBorderTitle", colourss.primary)
    set_hl("LspSagaBorder", colourss.outline)
    set_hl("LspSagaError", colourss.error)
    set_hl("LspSagaWarning", colourss.primary)
    set_hl("LspSagaInfo", colourss.secondary)
    set_hl("LspSagaHint", colourss.tertiary)
    set_hl("LspSagaDef", colourss.primary)
    set_hl("LspSagaTypeDefinition", colourss.secondary)
    set_hl("LspSagaDiagSource", colourss.outline_variant)
    set_hl("LspSagaCodeActionTitle", colourss.primary)
    set_hl("LspSagaCodeActionSelected", colourss.on_primary, colourss.primary)

    -- Lualine (explicitly define mode highlight groups for contrast)
    -- These are crucial for a clear mode indication.
    set_hl("LualineNormal", colourss.on_primary, colourss.primary, "bold") -- Very prominent for Normal mode
    set_hl("LualineInsert", colourss.on_tertiary, colourss.tertiary, "bold") -- Greenish for Insert
    set_hl("LualineVisual", colourss.on_secondary, colourss.secondary, "bold") -- Yellowish/Orange for Visual
    set_hl("LualineReplace", colourss.on_error, colourss.error, "bold") -- Red for Replace (like error)
    set_hl("LualineCommand", colourss.on_primary_container, colourss.primary_container, "bold") -- Slightly muted primary for Cmd
    set_hl("LualineTerminal", colourss.on_secondary_container, colourss.secondary_container, "bold") -- Cyanish for Terminal
    set_hl("LualineStatusLine", colourss.on_surface, bg_statusline) -- Default Lualine section bg/fg
    set_hl("LualineStatusLineNC", colourss.outline, bg_float) -- Inactive Lualine statusline
    set_hl("LualineSpecial", colourss.primary_fixed_dim) -- For special symbols/separators in Lualine
  end

  -- General links to standard groups
  set_hl_link("CursorIM", "Normal")
end

--- Applies Treesitter-specific highlight groups.
--- @param colourss table The table of colours values (hex strings).
local function apply_treesitter_highlights(colourss)
  if M.config.disable_treesitter_highlights then
    return
  end

  -- Reuse the consistent foreground colourss for UI elements defined in apply_base_highlights
  local ui_normal_fg = colourss.outline or colourss.on_surface_variant

  -- Treesitter highlight groups (harmonious and distinct, less reliance on arbitrary colourss)
  set_hl("@comment", colourss.comment or colourss.outline, nil, "italic")

  -- Constants, numbers, floats (more generally "literal" values)
  set_hl("@constant", colourss.tertiary_fixed)
  set_hl("@constant.builtin", colourss.tertiary_fixed_dim or colourss.tertiary)
  set_hl("@constant.macro", colourss.tertiary_container)
  set_hl("@string", colourss.secondary_fixed)
  set_hl("@string.escape", colourss.tertiary)
  set_hl("@character", colourss.secondary_fixed)
  set_hl("@number", colourss.tertiary_fixed)
  set_hl("@float", colourss.tertiary_fixed)

  -- Booleans - give them a distinct, possibly slightly "alarming" but readable colours, like error_container
  -- This provides strong contrast and signals a "state" value.
  set_hl("@boolean", colourss.on_error_container or colourss.error)

  -- Variables, properties
  set_hl("@variable", colourss.on_surface) -- Consistent with base Identifier
  set_hl("@variable.builtin", colourss.tertiary_fixed_dim or colourss.tertiary)
  set_hl("@property", colourss.tertiary_fixed)

  -- Functions, methods
  set_hl("@function", colourss.primary_fixed)
  set_hl("@function.call", colourss.primary_fixed)
  set_hl("@function.builtin", colourss.primary_fixed_dim or colourss.primary)
  set_hl("@function.macro", colourss.primary_container)
  set_hl("@method", colourss.primary_fixed)

  -- Keywords, operators, exceptions
  set_hl("@keyword", colourss.primary)
  set_hl("@operator", colourss.on_surface_variant) -- Consistent with base Operator
  set_hl("@exception", colourss.error)

  -- Conditionals and Repeats/Flow Control - use a distinct, slightly bolder variant of primary
  -- This makes "if", "else", "for", "while", "return" stand out more.
  set_hl("@conditional", colourss.primary, nil, "bold") -- Using primary with bold
  set_hl("@repeat", colourss.primary, nil, "bold") -- Consistent with conditional
  set_hl("@label", colourss.primary_fixed_dim or colourss.primary)
  set_hl("@include", colourss.secondary) -- Link includes to secondary
  set_hl("@return", colourss.primary, nil, "bold") -- Explicitly highlight returns

  -- Types
  set_hl("@type", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("@type.builtin", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("@type.qualifier", colourss.outline)
  set_hl("@type.definition", colourss.tertiary_fixed or colourss.tertiary)

  -- Punctuation
  set_hl("@punctuation.delimiter", colourss.outline)
  set_hl("@punctuation.bracket", colourss.outline_variant)
  set_hl("@punctuation.special", colourss.tertiary_fixed or colourss.tertiary)

  -- Tags
  set_hl("@tag", colourss.primary_fixed)
  set_hl("@tag.attribute", colourss.secondary_fixed or colourss.secondary)
  set_hl("@tag.builtin", colourss.primary_fixed_dim or colourss.primary)

  -- Text content and formatting
  set_hl("@text", colourss.on_background)
  set_hl("@text.literal", colourss.secondary_container)
  set_hl("@text.reference", colourss.primary)
  set_hl("@text.title", colourss.primary, nil, "bold")
  set_hl("@text.uri", colourss.tertiary, nil, "underline")
  set_hl("@text.underline", nil, nil, "underline")
  set_hl("@text.todo", colourss.on_tertiary, colourss.tertiary_container, "bold")
  set_hl("@text.warning", colourss.on_primary_container, colourss.primary_container)
  set_hl("@text.danger", colourss.on_error, colourss.error_container)
  set_hl("@text.info", colourss.on_secondary_container, colourss.secondary_container)
  set_hl("@text.hint", colourss.on_tertiary_container, colourss.tertiary_container)

  -- Markdown specific
  set_hl("@markup.heading", colourss.primary, nil, "bold")
  set_hl("@markup.raw", colourss.secondary_container)
  set_hl("@markup.list", colourss.tertiary)
  set_hl("@markup.link", colourss.tertiary, nil, "underline")
  set_hl("@markup.link.url", colourss.outline, nil, "underline")
  set_hl("@markup.italic", nil, nil, "italic")
  set_hl("@markup.bold", nil, nil, "bold")
  set_hl("@markup.strikethrough", nil, nil, "strikethrough")

  -- Diff
  set_hl("@diff.minus", colourss.error_container)
  set_hl("@diff.plus", colourss.tertiary_container)
  set_hl("@diff.delta", colourss.primary_container)

  -- Diagnostic (TS)
  set_hl("@diagnostic.error", colourss.error)
  set_hl("@diagnostic.warning", colourss.primary)
  set_hl("@diagnostic.info", colourss.secondary)
  set_hl("@diagnostic.hint", colourss.tertiary)

  -- LSP Types (TS) - consistent with base syntax groups
  set_hl("@lsp.type.comment", colourss.comment or colourss.outline)
  set_hl("@lsp.type.keyword", colourss.primary)
  set_hl("@lsp.type.variable", colourss.on_surface)
  set_hl("@lsp.type.function", colourss.primary_fixed)
  set_hl("@lsp.type.method", colourss.primary_fixed)
  set_hl("@lsp.type.enumMember", colourss.tertiary_fixed_dim)
  set_hl("@lsp.type.property", colourss.tertiary_fixed)
  set_hl("@lsp.type.parameter", colourss.tertiary_fixed_dim or colourss.tertiary)
  set_hl("@lsp.type.namespace", colourss.secondary)
  set_hl("@lsp.type.type", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("@lsp.type.interface", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("@lsp.type.struct", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("@lsp.type.enum", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("@lsp.type.class", colourss.secondary_fixed_dim or colourss.secondary)
  set_hl("@lsp.type.event", colourss.tertiary_fixed_dim or colourss.tertiary)
  set_hl("@lsp.type.macro", colourss.tertiary_container)
end

--- Applies custom user highlight overrides.
--- This function now uses the `set_hl` helper to ensure `ignore_groups` are respected.
--- @param colourss table The table of colours values (hex strings).
local function apply_custom_highlights(colourss)
  if not M.config.custom_highlights then
    return
  end

  for group, opts in pairs(M.config.custom_highlights) do
    -- If the group is ignored, skip it entirely
    if M.config.ignore_groups and M.config.ignore_groups[group] then
      goto continue -- Lua's goto for skipping loop iteration
    end

    local fg, bg, style = nil, nil, nil

    if type(opts) == "string" then
      -- Simple colours string, assume it's foreground
      fg = opts
    elseif type(opts) == "table" then
      fg = opts.fg or opts[1]
      bg = opts.bg or opts[2]
      style = opts.style or opts[3]

      -- Allow colours references like "colourss.primary"
      if fg and type(fg) == "string" and fg:match("^colourss%.") then
        local colours_key = fg:match("^colourss%.(.+)$")
        fg = colourss[colours_key] or fg -- Fallback to original string if key not found
      end
      if bg and type(bg) == "string" and bg:match("^colourss%.") then
        local colours_key = bg:match("^colourss%.(.+)$")
        bg = colourss[colours_key] or bg -- Fallback to original string if key not found
      end
    end

    -- Use the centralized set_hl function to apply the custom highlight
    set_hl(group, fg, bg, style)
    ::continue:: -- Label for goto
  end
end

--- Sets terminal colourss based on Matugen's palette.
--- @param colourss table The table of colours values (hex strings).
local function set_terminal_colourss(colourss)
  if not M.config.set_term_colourss then
    return
  end

  -- Map Matugen colourss to standard 16 terminal colourss
  -- Prioritize specific, harmonious Matugen colourss for terminal consistency
  local term_colourss = {
    colourss.surface_container_high, -- 0: Black (dark grey)
    colourss.error, -- 1: Red
    colourss.tertiary, -- 2: Green
    colourss.secondary, -- 3: Yellow
    colourss.primary, -- 4: Blue
    colourss.error_container, -- 5: Magenta (can be more purple if error_container leans that way)
    colourss.secondary_container, -- 6: Cyan
    colourss.on_surface, -- 7: White (light grey)

    colourss.outline, -- 8: Bright Black (brighter dark grey)
    colourss.on_error, -- 9: Bright Red
    colourss.on_tertiary, -- 10: Bright Green
    colourss.on_secondary, -- 11: Bright Yellow
    colourss.on_primary, -- 12: Bright Blue
    colourss.on_error_container, -- 13: Bright Magenta
    colourss.on_secondary_container, -- 14: Bright Cyan
    colourss.on_background, -- 15: Bright White (white)
  }

  for i = 0, 15 do
    vim.g["terminal_colours_" .. i] = term_colourss[i + 1]
  end
end

---Loads the Matugen-generated coloursscheme.
function M.load_matugen_coloursscheme()
  local colourss_file_path = expand_path(M.config.file)
  current_background_style = M.config.background_style -- Update global style

  if vim.fn.filereadable(colourss_file_path) == 0 then
    vim.notify(
      "Matugen colourss file not found at: " .. colourss_file_path,
      vim.log.levels.ERROR,
      { title = "Matugen.nvim" }
    )
    if not M.config.disable_generation_hint then
      vim.notify(
        "Please generate it using Matugen, e.g.: matugen generate -i /path/to/your/image.jpg -t /path/to/your/template.jsonc -o "
          .. colourss_file_path,
        vim.log.levels.INFO,
        { title = "Matugen.nvim" }
      )
    end
    return
  end

  local colourss = read_matugen_colourss_file(colourss_file_path)
  if not colourss then
    return
  end

  loaded_colourss = colourss -- Store loaded colourss globally
  apply_base_highlights(loaded_colourss, current_background_style)

  -- Apply Treesitter highlights immediately if available
  if vim.treesitter and vim.treesitter.highlighter then
    apply_treesitter_highlights(loaded_colourss)
  end

  -- Apply custom highlights last, allowing them to override previous settings
  apply_custom_highlights(loaded_colourss)

  -- Set terminal colourss if enabled
  set_terminal_colourss(loaded_colourss)

  if not M.config.disable_notifications then
    vim.notify("Matugen coloursscheme loaded successfully!", vim.log.levels.INFO, { title = "Matugen.nvim" })
  end
end

---Setup function for the plugin.
---@param opts table|nil User configuration options.
function M.setup(opts)
  -- Default configuration
  local defaults = {
    file = vim.fn.stdpath("cache") .. "/matugen/colourss.jsonc",
    background_style = "dark", -- "dark" or "light"
    auto_load = true, -- Auto-load on VimEnter
    disable_clear = false, -- Don't clear existing highlights before applying
    disable_plugin_highlights = false, -- Don't apply plugin-specific highlights
    disable_treesitter_highlights = false, -- Don't apply Treesitter highlights
    disable_notifications = false, -- Don't show success notifications
    disable_generation_hint = false, -- Don't show generation hint when file not found
    ignore_groups = {}, -- Table of highlight groups to ignore: { "Normal" = true, "Comment" = true }
    custom_highlights = {}, -- Custom highlight overrides: { "Normal" = { fg = "#RRGGBB", bg = "colourss.surface", style = "bold" } }
    transparent_background = false, -- Set background to NONE for UI elements (e.g., Normal, Float, StatusLine)
    set_term_colourss = true, -- Set terminal colourss (terminal_colours_0 to terminal_colours_15) based on Matugen palette
  }

  -- Handle both opts table and config function patterns
  if type(opts) == "function" then
    opts = opts()
  end

  -- Merge user options with defaults
  M.config = vim.tbl_deep_extend("force", defaults, opts or {})

  -- Validate configuration
  if M.config.background_style ~= "dark" and M.config.background_style ~= "light" then
    vim.notify(
      "Invalid background_style: '" .. M.config.background_style .. "'. Using 'dark' instead.",
      vim.log.levels.WARN,
      { title = "Matugen.nvim" }
    )
    M.config.background_style = "dark"
  end

  -- Define user commands
  vim.api.nvim_create_user_command("MatugencoloursschemeLoad", function()
    M.load_matugen_coloursscheme()
  end, {
    desc = "Load the Matugen-generated coloursscheme",
  })

  vim.api.nvim_create_user_command("MatugencoloursschemeReload", function()
    M.load_matugen_coloursscheme()
  end, {
    desc = "Reload the Matugen-generated coloursscheme",
  })

  vim.api.nvim_create_user_command("MatugencoloursschemeToggle", function()
    -- Toggle the background style and reload
    M.config.background_style = M.config.background_style == "dark" and "light" or "dark"
    M.load_matugen_coloursscheme()
  end, {
    desc = "Toggle between light and dark background styles",
  })

  -- Auto-load on VimEnter if enabled
  if M.config.auto_load then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("MatugencoloursschemeAutoLoad", { clear = true }),
      callback = function()
        M.load_matugen_coloursscheme()
      end,
    })
  end

  -- Autocmd for Treesitter-specific highlights and custom highlights
  -- These need to be re-applied after a coloursScheme event, as other plugins
  -- or Neovim itself might overwrite them.
  vim.api.nvim_create_autocmd("coloursScheme", {
    group = vim.api.nvim_create_augroup("MatugenTreesitterHighlights", { clear = true }),
    callback = function()
      -- Only apply if our coloursscheme is active and we have loaded colourss
      if vim.g.colourss_name == "matugen_colourss" and next(loaded_colourss) ~= nil then
        apply_treesitter_highlights(loaded_colourss)
        apply_custom_highlights(loaded_colourss)
        set_terminal_colourss(loaded_colourss) -- Re-apply terminal colourss if needed
      end
    end,
  })
end

-- Function to get the currently loaded colourss (useful for other plugins)
function M.get_colourss()
  return loaded_colourss
end

-- Function to get the current config
function M.get_config()
  return M.config
end

-- Function to update configuration at runtime
---@param new_opts table New options to merge into the current config.
function M.update_config(new_opts)
  M.config = vim.tbl_deep_extend("force", M.config, new_opts or {})
  -- Re-validate background_style after update
  if M.config.background_style ~= "dark" and M.config.background_style ~= "light" then
    vim.notify(
      "Invalid background_style after update: '" .. M.config.background_style .. "'. Using 'dark' instead.",
      vim.log.levels.WARN,
      { title = "Matugen.nvim" }
    )
    M.config.background_style = "dark"
  end
end

return M
