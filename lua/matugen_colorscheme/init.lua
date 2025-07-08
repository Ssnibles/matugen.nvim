-- Ssnibles/matugen.nvim/lua/matugen_colorscheme/init.lua

local M = {}

-- Global variable to store loaded colors
local loaded_colors = {}
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

--- Helper for setting highlights with override check
--- This function centralizes the logic for applying highlights and respecting `ignore_groups`.
--- @param group string The highlight group name.
--- @param fg string|nil Foreground color (hex string or "NONE").
--- @param bg string|nil Background color (hex string or "NONE").
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

--- Applies general highlight groups based on the loaded colors.
--- @param colors table The table of color values (hex strings).
--- @param background_style string "dark" or "light"
local function apply_base_highlights(colors, background_style)
  -- Clear existing highlights before applying new ones
  if not M.config.disable_clear then
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
      vim.cmd("syntax reset")
    end
  end

  vim.o.background = background_style
  vim.g.colors_name = "matugen_colors"

  -- Determine background colors based on transparent_background option
  local bg_normal = M.config.transparent_background and "NONE" or colors.background
  local bg_float = M.config.transparent_background and "NONE" or (colors.surface_container_low or colors.surface)
  local bg_pmenu = M.config.transparent_background and "NONE" or (colors.surface_container or colors.surface)
  local bg_statusline = M.config.transparent_background and "NONE" or (colors.surface_container_high or colors.surface)
  local bg_tabline = M.config.transparent_background and "NONE" or (colors.surface_container_lowest or colors.surface)
  local bg_cursorline = M.config.transparent_background and "NONE" or (colors.surface_container_low or colors.surface)
  local bg_cmdline = M.config.transparent_background and "NONE" or colors.background
  local bg_col_line = M.config.transparent_background and "NONE" or (colors.surface_container_lowest or colors.surface)
  local bg_visual = M.config.transparent_background and "NONE" or colors.surface_variant -- Use surface_variant for visual selection

  -- Base Neovim UI Colors
  set_hl("Normal", colors.on_background, bg_normal)
  set_hl("NormalNC", colors.on_surface_variant, bg_normal) -- Normal for non-current windows
  set_hl("NormalFloat", colors.on_surface, bg_float)
  set_hl("FloatBorder", colors.outline_variant, bg_float)
  set_hl("VertSplit", colors.outline, bg_normal) -- Changed to outline for better visibility
  set_hl("WinSeparator", colors.outline, bg_normal) -- Linked to VertSplit for consistency
  set_hl("Pmenu", colors.on_surface, bg_pmenu)
  set_hl("PmenuSel", colors.on_primary, colors.primary)
  set_hl("PmenuSbar", nil, bg_pmenu)
  set_hl("PmenuThumb", nil, colors.on_surface_variant or colors.on_surface)
  set_hl("FloatFooter", colors.on_surface, bg_float)
  set_hl("FloatHeader", colors.on_surface, bg_float)

  -- Line Numbers, Sign Column, Fold Column
  set_hl("LineNr", colors.outline, bg_normal) -- Subtle outline for line numbers
  set_hl("LineNrAbove", colors.outline, bg_normal) -- For relative line numbers above cursor
  set_hl("LineNrBelow", colors.outline, bg_normal) -- For relative line numbers below cursor
  set_hl("SignColumn", colors.outline, bg_normal)
  set_hl("FoldColumn", colors.outline, bg_normal)

  -- Cursorline and Number
  set_hl("CursorLine", nil, bg_cursorline)
  set_hl("CursorLineNr", colors.primary, bg_cursorline, "bold") -- Primary for active line number
  set_hl("CursorColumn", nil, bg_cursorline) -- Highlight for cursor column

  -- Visual mode selection
  set_hl("Visual", nil, bg_visual)
  set_hl("VisualNOS", nil, bg_visual)

  -- Search and IncSearch
  set_hl("IncSearch", colors.on_secondary, colors.secondary_container, "bold") -- Stronger contrast for incremental search
  set_hl("Search", colors.on_tertiary, colors.tertiary_container) -- Distinct color for search results

  -- Diagnostics (errors, warnings, info, hints)
  set_hl("ErrorMsg", colors.on_error, colors.error, "bold") -- Use error as background for strong emphasis
  set_hl("WarningMsg", colors.on_primary_container, colors.primary_container, "bold")
  set_hl("InfoMsg", colors.on_secondary_container, colors.secondary_container)
  set_hl("HintMsg", colors.on_tertiary_container, colors.tertiary_container)

  -- LSP Diagnostics (linking to general diagnostic messages)
  set_hl_link("LspDiagnosticsError", "ErrorMsg")
  set_hl_link("LspDiagnosticsWarning", "WarningMsg")
  set_hl_link("LspDiagnosticsInformation", "InfoMsg")
  set_hl_link("LspDiagnosticsHint", "HintMsg")

  -- Diffs
  set_hl("DiffAdd", colors.on_tertiary_container, colors.tertiary_container) -- Use on_tertiary_container for fg
  set_hl("DiffChange", colors.on_primary_container, colors.primary_container) -- Use on_primary_container for fg
  set_hl("DiffDelete", colors.on_error_container, colors.error_container) -- Use on_error_container for fg
  set_hl("DiffText", colors.on_secondary_container, colors.secondary_container) -- Use on_secondary_container for fg

  -- Statusline and Tabline
  set_hl("StatusLine", colors.on_surface, bg_statusline)
  set_hl("StatusLineNC", colors.outline, bg_float) -- Use float background for inactive statusline
  set_hl("TabLine", colors.on_surface_variant or colors.on_surface, bg_tabline)
  set_hl("TabLineFill", colors.on_surface_variant or colors.on_surface, bg_tabline)
  set_hl("TabLineSel", colors.on_primary, colors.primary, "bold")

  -- Command Line
  set_hl("CmdLine", colors.on_surface, bg_cmdline)

  -- Spell checking
  set_hl("SpellBad", colors.on_error, colors.error_container, "underline")
  set_hl("SpellCap", colors.on_primary_container, colors.primary_container, "underline")
  set_hl("SpellRare", colors.on_secondary_container, colors.secondary_container, "underline")
  set_hl("SpellLocal", colors.on_tertiary_container, colors.tertiary_container, "underline")

  -- Other UI elements
  set_hl("ColorColumn", nil, bg_col_line)
  set_hl("Cursor", colors.background, colors.on_background)
  set_hl("lCursor", colors.background, colors.on_background)
  set_hl("MatchParen", colors.on_primary, colors.primary_container, "bold")
  set_hl("NonText", colors.outline_variant)
  set_hl("Whitespace", colors.outline_variant)
  set_hl("Conceal", colors.outline_variant)
  set_hl("Directory", colors.primary) -- Primary for directories
  set_hl("Title", colors.primary)
  set_hl("ModeMsg", colors.primary_container)
  set_hl("MoreMsg", colors.tertiary)
  set_hl("Question", colors.secondary)
  set_hl("Folded", colors.on_surface_variant or colors.on_surface, bg_statusline, "italic")
  set_hl("EndOfBuffer", colors.outline_variant) -- For '~' at end of buffer
  set_hl("SpecialKey", colors.outline_variant) -- For special characters like tabs

  -- Basic Syntax Highlighting (often falls back if TS is not active)
  set_hl("Comment", colors.comment or colors.outline, nil, "italic")
  set_hl("Constant", colors.tertiary) -- Tertiary for constants
  set_hl("String", colors.secondary) -- Secondary for strings
  set_hl("Character", colors.secondary_fixed or colors.secondary)
  set_hl("Number", colors.tertiary)
  set_hl("Boolean", colors.tertiary)
  set_hl("Float", colors.tertiary)
  set_hl("Identifier", colors.on_surface) -- Changed to on_surface for better visibility than on_background
  set_hl("Function", colors.primary)
  set_hl("Statement", colors.primary, nil, "bold")
  set_hl("Conditional", colors.primary)
  set_hl("Repeat", colors.primary)
  set_hl("Label", colors.primary_fixed_dim or colors.primary)
  set_hl("Operator", colors.on_surface_variant) -- Changed to on_surface_variant for better contrast
  set_hl("Keyword", colors.primary)
  set_hl("Exception", colors.error)
  set_hl("PreProc", colors.secondary)
  set_hl("Include", colors.secondary)
  set_hl("Define", colors.secondary)
  set_hl("Macro", colors.secondary)
  set_hl("PreCondit", colors.secondary)
  set_hl("Type", colors.secondary_fixed or colors.secondary)
  set_hl("StorageClass", colors.secondary_fixed or colors.secondary)
  set_hl("Structure", colors.secondary_fixed or colors.secondary)
  set_hl("Typedef", colors.secondary_fixed or colors.secondary)
  set_hl("Special", colors.tertiary_container)
  set_hl("SpecialChar", colors.tertiary_container)
  set_hl("Tag", colors.tertiary_container)
  set_hl("Delimiter", colors.outline) -- Changed to outline
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
  set_hl("markdownItalic", colors.comment or colors.outline, nil, "italic") -- Re-apply italic explicitly with comment color
  set_hl_link("markdownLinkText", "Function")
  set_hl_link("markdownLinkUrl", "Underlined")
  set_hl_link("markdownHeading1", "Title")
  set_hl_link("markdownHeading2", "Title")
  set_hl_link("markdownHeading3", "Title") -- Added more markdown headings
  set_hl_link("markdownHeading4", "Title")
  set_hl_link("markdownHeading5", "Title")
  set_hl_link("markdownHeading6", "Title")

  -- Plugin highlights (only if not disabled)
  if not M.config.disable_plugin_highlights then
    -- NvimTree
    set_hl("NvimTreeRoot", colors.primary, nil, "bold")
    set_hl("NvimTreeFolderIcon", colors.secondary)
    set_hl("NvimTreeGitDirty", colors.tertiary) -- Changed to tertiary for dirty
    set_hl("NvimTreeGitNew", colors.tertiary_container) -- Kept tertiary_container for new
    set_hl("NvimTreeIndentMarker", colors.outline_variant)
    set_hl("NvimTreeSymlink", colors.tertiary)

    -- Telescope
    set_hl("TelescopeNormal", colors.on_surface, bg_float)
    set_hl("TelescopeBorder", colors.outline, bg_float)
    set_hl("TelescopePromptNormal", colors.on_surface, bg_statusline)
    set_hl("TelescopePromptBorder", colors.primary, bg_statusline)
    set_hl("TelescopePromptPrefix", colors.primary, bg_statusline, "bold")
    set_hl("TelescopeMatching", colors.primary, nil, "bold")
    set_hl("TelescopeSelection", colors.on_primary_container, colors.primary_container)
    set_hl_link("TelescopeResultsNormal", "NormalFloat")
    set_hl_link("TelescopeResultsSelection", "TelescopeSelection")

    -- Cmp (Completion)
    set_hl("CmpBorder", colors.outline_variant, bg_float)
    set_hl("CmpMenu", colors.on_surface, bg_float)
    set_hl("CmpItemKind", colors.outline) -- Default kind color
    set_hl("CmpItemKindText", colors.on_surface)
    set_hl("CmpItemKindMethod", colors.primary)
    set_hl("CmpItemKindFunction", colors.primary)
    set_hl("CmpItemKindConstructor", colors.primary)
    set_hl("CmpItemKindField", colors.tertiary) -- Changed to tertiary
    set_hl("CmpItemKindVariable", colors.on_background)
    set_hl("CmpItemKindClass", colors.secondary_fixed or colors.secondary)
    set_hl("CmpItemKindInterface", colors.secondary_fixed or colors.secondary)
    set_hl("CmpItemKindModule", colors.secondary)
    set_hl("CmpItemKindProperty", colors.tertiary) -- Changed to tertiary
    set_hl("CmpItemKindUnit", colors.tertiary)
    set_hl("CmpItemKindValue", colors.tertiary)
    set_hl("CmpItemKindEnum", colors.secondary_fixed or colors.secondary)
    set_hl("CmpItemKindKeyword", colors.primary)
    set_hl("CmpItemKindSnippet", colors.tertiary_container)
    set_hl("CmpItemKindColor", colors.tertiary)
    set_hl("CmpItemKindFile", colors.primary_container)
    set_hl("CmpItemKindReference", colors.primary)
    set_hl("CmpItemKindFolder", colors.secondary)
    set_hl("CmpItemKindEnumMember", colors.tertiary)
    set_hl("CmpItemKindConstant", colors.tertiary)
    set_hl("CmpItemKindStruct", colors.secondary_fixed or colors.secondary)
    set_hl("CmpItemKindEvent", colors.tertiary_fixed or colors.tertiary)
    set_hl("CmpItemKindOperator", colors.outline)
    set_hl("CmpItemKindTypeParameter", colors.secondary_fixed or colors.secondary)
    set_hl("CmpItemAbbr", colors.on_surface)
    set_hl("CmpItemAbbrDeprecated", colors.outline_variant, nil, "strikethrough")
    set_hl("CmpItemAbbrMatch", colors.primary, nil, "bold")
    set_hl("CmpItemAbbrMatchFuzzy", colors.primary, nil, "underline")
    set_hl("CmpItemMenu", colors.outline_variant)
    set_hl("CmpItemSel", colors.on_primary, colors.primary)
    set_hl("CmpDocBorder", colors.outline_variant, bg_pmenu)
    set_hl("CmpDoc", colors.on_surface, bg_pmenu)

    -- Gitsigns
    set_hl("GitSignsAdd", colors.tertiary, nil, "bold")
    set_hl("GitSignsChange", colors.primary, nil, "bold")
    set_hl("GitSignsDelete", colors.error, nil, "bold")
    set_hl("GitSignsChangeDelete", colors.error, nil, "bold")

    -- Bufferline / Barbar
    set_hl("BufferLineFill", bg_tabline)
    set_hl(
      "BufferLineBuffer",
      colors.on_surface_variant or colors.on_surface,
      bg_float -- Use float background for inactive buffers
    )
    set_hl("BufferLineBufferSelected", colors.on_primary, colors.primary, "bold")
    set_hl("BufferLineTabSeparator", colors.background, bg_tabline)
    set_hl("BufferLineBufferVisible", colors.on_surface, bg_pmenu) -- Use pmenu background for visible but not selected

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

--- Applies Treesitter-specific highlight groups.
--- @param colors table The table of color values (hex strings).
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

  set_hl("@variable", colors.on_surface) -- Changed to on_surface for general variables
  set_hl("@variable.builtin", colors.tertiary_fixed_dim or colors.tertiary)
  set_hl("@property", colors.tertiary) -- Changed to tertiary for properties
  set_hl("@function", colors.primary)
  set_hl("@function.call", colors.primary)
  set_hl("@function.builtin", colors.primary_fixed_dim or colors.primary)
  set_hl("@function.macro", colors.primary_container)
  set_hl("@method", colors.primary)

  set_hl("@keyword", colors.primary)
  set_hl("@operator", colors.on_surface_variant) -- Consistent with base operator
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
  set_hl("@text.warning", colors.on_primary_container, colors.primary_container) -- Linked to WarningMsg
  set_hl("@text.danger", colors.on_error, colors.error_container) -- Linked to ErrorMsg
  set_hl("@text.info", colors.on_secondary_container, colors.secondary_container) -- Linked to InfoMsg
  set_hl("@text.hint", colors.on_tertiary_container, colors.tertiary_container) -- Linked to HintMsg

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
  set_hl("@lsp.type.variable", colors.on_surface) -- Consistent with @variable
  set_hl("@lsp.type.function", colors.primary)
  set_hl("@lsp.type.method", colors.primary)
  set_hl("@lsp.type.enumMember", colors.tertiary)
  set_hl("@lsp.type.property", colors.tertiary) -- Consistent with @property
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

--- Applies custom user highlight overrides.
--- This function now uses the `set_hl` helper to ensure `ignore_groups` are respected.
--- @param colors table The table of color values (hex strings).
local function apply_custom_highlights(colors)
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
      -- Simple color string, assume it's foreground
      fg = opts
    elseif type(opts) == "table" then
      fg = opts.fg or opts[1]
      bg = opts.bg or opts[2]
      style = opts.style or opts[3]

      -- Allow color references like "colors.primary"
      if fg and type(fg) == "string" and fg:match("^colors%.") then
        local color_key = fg:match("^colors%.(.+)$")
        fg = colors[color_key] or fg -- Fallback to original string if key not found
      end
      if bg and type(bg) == "string" and bg:match("^colors%.") then
        local color_key = bg:match("^colors%.(.+)$")
        bg = colors[color_key] or bg -- Fallback to original string if key not found
      end
    end

    -- Use the centralized set_hl function to apply the custom highlight
    set_hl(group, fg, bg, style)
    ::continue:: -- Label for goto
  end
end

--- Sets terminal colors based on Matugen's palette.
--- @param colors table The table of color values (hex strings).
local function set_terminal_colors(colors)
  if not M.config.set_term_colors then
    return
  end

  -- Map Matugen colors to standard 16 terminal colors
  local term_colors = {
    colors.surface_container_high, -- 0: Black (dark grey)
    colors.error, -- 1: Red
    colors.tertiary, -- 2: Green
    colors.secondary, -- 3: Yellow
    colors.primary, -- 4: Blue
    colors.error_container, -- 5: Magenta
    colors.secondary_container, -- 6: Cyan
    colors.on_surface, -- 7: White (light grey)

    colors.outline, -- 8: Bright Black (brighter dark grey)
    colors.on_error, -- 9: Bright Red
    colors.on_tertiary, -- 10: Bright Green
    colors.on_secondary, -- 11: Bright Yellow
    colors.on_primary, -- 12: Bright Blue
    colors.on_error_container, -- 13: Bright Magenta
    colors.on_secondary_container, -- 14: Bright Cyan
    colors.on_background, -- 15: Bright White (white)
  }

  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = term_colors[i + 1]
  end
end

---Loads the Matugen-generated colorscheme.
function M.load_matugen_colorscheme()
  local colors_file_path = expand_path(M.config.file)
  current_background_style = M.config.background_style -- Update global style

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

  loaded_colors = colors -- Store loaded colors globally
  apply_base_highlights(loaded_colors, current_background_style)

  -- Apply Treesitter highlights immediately if available
  if vim.treesitter and vim.treesitter.highlighter then
    apply_treesitter_highlights(loaded_colors)
  end

  -- Apply custom highlights last, allowing them to override previous settings
  apply_custom_highlights(loaded_colors)

  -- Set terminal colors if enabled
  set_terminal_colors(loaded_colors)

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
    disable_clear = false, -- Don't clear existing highlights before applying
    disable_plugin_highlights = false, -- Don't apply plugin-specific highlights
    disable_treesitter_highlights = false, -- Don't apply Treesitter highlights
    disable_notifications = false, -- Don't show success notifications
    disable_generation_hint = false, -- Don't show generation hint when file not found
    ignore_groups = {}, -- Table of highlight groups to ignore: { "Normal" = true, "Comment" = true }
    custom_highlights = {}, -- Custom highlight overrides: { "Normal" = { fg = "#RRGGBB", bg = "colors.surface", style = "bold" } }
    transparent_background = false, -- Set background to NONE for UI elements (e.g., Normal, Float, StatusLine)
    set_term_colors = true, -- Set terminal colors (terminal_color_0 to terminal_color_15) based on Matugen palette
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
    -- Toggle the background style and reload
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

  -- Autocmd for Treesitter-specific highlights and custom highlights
  -- These need to be re-applied after a ColorScheme event, as other plugins
  -- or Neovim itself might overwrite them.
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("MatugenTreesitterHighlights", { clear = true }),
    callback = function()
      -- Only apply if our colorscheme is active and we have loaded colors
      if vim.g.colors_name == "matugen_colors" and next(loaded_colors) ~= nil then
        apply_treesitter_highlights(loaded_colors)
        apply_custom_highlights(loaded_colors)
        set_terminal_colors(loaded_colors) -- Re-apply terminal colors if needed
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
