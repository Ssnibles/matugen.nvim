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

  -- IMPROVED: Make CursorLine much more visible by using a more contrasting background
  local bg_cursorline = M.config.transparent_background and "NONE"
    or (colors.surface_container or colors.surface_variant)

  local bg_cmdline = M.config.transparent_background and "NONE" or colors.background
  local bg_col_line = M.config.transparent_background and "NONE" or (colors.surface_container_lowest or colors.surface)

  -- IMPROVED: Make Visual selection more prominent
  local bg_visual = M.config.transparent_background and "NONE" or (colors.primary_container or colors.surface_variant)

  -- Define consistent foreground colors for UI elements
  local ui_normal_fg = colors.outline or colors.on_surface_variant
  -- IMPROVED: Better contrast for line numbers
  local ui_line_number_fg = colors.on_surface_variant or colors.outline

  --- Base Neovim UI Colors ---
  -- Normal text (consistent throughout the main buffer)
  set_hl("Normal", colors.on_background, bg_normal)
  set_hl("NormalNC", colors.on_surface_variant, bg_normal)
  set_hl("NormalFloat", colors.on_surface, bg_float)

  -- Borders and Separators (more visible)
  set_hl("FloatBorder", colors.outline, bg_float)
  set_hl("VertSplit", colors.outline_variant or colors.outline, bg_normal)
  set_hl("WinSeparator", colors.outline_variant or colors.outline, bg_normal)

  -- Pop-up Menu (better contrast)
  set_hl("Pmenu", colors.on_surface, bg_pmenu)
  set_hl("PmenuSel", colors.on_primary, colors.primary, "bold")
  set_hl("PmenuSbar", nil, colors.surface_container_low)
  set_hl("PmenuThumb", nil, colors.primary)
  set_hl("FloatFooter", colors.on_surface_variant, bg_float)
  set_hl("FloatHeader", colors.on_surface, bg_float, "bold")

  --- Line Numbers, Sign Column, Fold Column (better visibility) ---
  set_hl("LineNr", ui_line_number_fg, bg_normal)
  set_hl("LineNrAbove", ui_line_number_fg, bg_normal)
  set_hl("LineNrBelow", ui_line_number_fg, bg_normal)
  set_hl("SignColumn", ui_line_number_fg, bg_normal)
  set_hl("FoldColumn", ui_line_number_fg, bg_normal)

  --- IMPROVED: Cursorline and Number (much more visible) ---
  set_hl("CursorLine", nil, bg_cursorline)
  set_hl("CursorLineNr", colors.primary, bg_cursorline, "bold")
  set_hl("CursorColumn", nil, bg_cursorline)

  --- IMPROVED: Visual mode selection (more prominent) ---
  set_hl("Visual", colors.on_primary_container, bg_visual)
  set_hl("VisualNOS", colors.on_primary_container, bg_visual)

  --- IMPROVED: Search and IncSearch (better contrast) ---
  set_hl("IncSearch", colors.on_secondary, colors.secondary, "bold")
  set_hl("Search", colors.on_tertiary_container, colors.tertiary_container)
  set_hl("CurSearch", colors.on_secondary, colors.secondary, "bold") -- Current search match

  --- IMPROVED: Diagnostics (clearer and more intuitive) ---
  set_hl("ErrorMsg", colors.on_error_container, colors.error_container, "bold")
  set_hl("WarningMsg", colors.on_primary_container, colors.primary_container, "bold")
  set_hl("InfoMsg", colors.on_secondary_container, colors.secondary_container)
  set_hl("HintMsg", colors.on_tertiary_container, colors.tertiary_container)

  -- LSP Diagnostics (better mapping)
  set_hl("DiagnosticError", colors.error, nil, "bold")
  set_hl("DiagnosticWarn", colors.primary, nil, "bold")
  set_hl("DiagnosticInfo", colors.secondary)
  set_hl("DiagnosticHint", colors.tertiary)

  -- Diagnostic underlines
  set_hl("DiagnosticUnderlineError", colors.error, nil, "underline")
  set_hl("DiagnosticUnderlineWarn", colors.primary, nil, "underline")
  set_hl("DiagnosticUnderlineInfo", colors.secondary, nil, "underline")
  set_hl("DiagnosticUnderlineHint", colors.tertiary, nil, "underline")

  -- Legacy LSP diagnostics links
  set_hl_link("LspDiagnosticsError", "DiagnosticError")
  set_hl_link("LspDiagnosticsWarning", "DiagnosticWarn")
  set_hl_link("LspDiagnosticsInformation", "DiagnosticInfo")
  set_hl_link("LspDiagnosticsHint", "DiagnosticHint")

  --- IMPROVED: Diffs (more intuitive colors) ---
  set_hl("DiffAdd", colors.on_tertiary_container, colors.tertiary_container)
  set_hl("DiffChange", colors.on_secondary_container, colors.secondary_container)
  set_hl("DiffDelete", colors.on_error_container, colors.error_container)
  set_hl("DiffText", colors.on_primary_container, colors.primary_container, "bold")

  --- IMPROVED: Statusline and Tabline (clearer hierarchy) ---
  set_hl("StatusLine", colors.on_surface, bg_statusline, "bold")
  set_hl("StatusLineNC", colors.on_surface_variant, bg_float)
  set_hl("TabLine", colors.on_surface_variant, bg_tabline)
  set_hl("TabLineFill", colors.on_surface_variant, bg_tabline)
  set_hl("TabLineSel", colors.on_primary, colors.primary, "bold")

  --- Command Line ---
  set_hl("CmdLine", colors.on_surface, bg_cmdline)

  --- IMPROVED: Spell checking (more visible) ---
  set_hl("SpellBad", colors.error, nil, "underline")
  set_hl("SpellCap", colors.primary, nil, "underline")
  set_hl("SpellRare", colors.secondary, nil, "underline")
  set_hl("SpellLocal", colors.tertiary, nil, "underline")

  --- IMPROVED: Other UI elements ---
  set_hl("ColorColumn", nil, bg_col_line)
  set_hl("Cursor", colors.background, colors.on_background)
  set_hl("lCursor", colors.background, colors.on_background)
  set_hl("MatchParen", colors.on_primary_container, colors.primary_container, "bold")
  set_hl("NonText", ui_normal_fg)
  set_hl("Whitespace", ui_normal_fg)
  set_hl("Conceal", colors.on_surface_variant)
  set_hl("Directory", colors.primary, nil, "bold")
  set_hl("Title", colors.primary, nil, "bold")
  set_hl("ModeMsg", colors.on_primary_container, colors.primary_container)
  set_hl("MoreMsg", colors.tertiary)
  set_hl("Question", colors.secondary)
  set_hl("Folded", colors.on_surface_variant, bg_statusline, "italic")
  set_hl("EndOfBuffer", ui_normal_fg)
  set_hl("SpecialKey", colors.on_surface_variant)

  --- IMPROVED: Basic Syntax Highlighting ---
  set_hl("Comment", colors.on_surface_variant, nil, "italic")
  set_hl("Constant", colors.tertiary)
  set_hl("String", colors.secondary)
  set_hl("Character", colors.secondary)
  set_hl("Number", colors.tertiary)
  set_hl("Boolean", colors.error, nil, "bold") -- More prominent for booleans
  set_hl("Float", colors.tertiary)
  set_hl("Identifier", colors.on_surface)
  set_hl("Function", colors.primary, nil, "bold")
  set_hl("Statement", colors.primary, nil, "bold")
  set_hl("Conditional", colors.primary, nil, "bold")
  set_hl("Repeat", colors.primary, nil, "bold")
  set_hl("Label", colors.primary)
  set_hl("Operator", colors.on_surface_variant)
  set_hl("Keyword", colors.primary, nil, "bold")
  set_hl("Exception", colors.error, nil, "bold")
  set_hl("PreProc", colors.secondary)
  set_hl("Include", colors.secondary)
  set_hl("Define", colors.secondary)
  set_hl("Macro", colors.secondary)
  set_hl("PreCondit", colors.secondary)
  set_hl("Type", colors.secondary, nil, "bold")
  set_hl("StorageClass", colors.secondary)
  set_hl("Structure", colors.secondary)
  set_hl("Typedef", colors.secondary)
  set_hl("Special", colors.tertiary)
  set_hl("SpecialChar", colors.tertiary)
  set_hl("Tag", colors.primary)
  set_hl("Delimiter", colors.outline)
  set_hl("SpecialComment", colors.tertiary, nil, "italic")
  set_hl("Underlined", nil, nil, "underline")
  set_hl("Ignore", colors.background, colors.background)
  set_hl("Todo", colors.on_tertiary_container, colors.tertiary_container, "bold")

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
  set_hl("markdownItalic", colors.on_surface_variant, nil, "italic")
  set_hl_link("markdownLinkText", "Function")
  set_hl_link("markdownLinkUrl", "Underlined")
  set_hl_link("markdownHeading1", "Title")
  set_hl_link("markdownHeading2", "Title")
  set_hl_link("markdownHeading3", "Title")
  set_hl_link("markdownHeading4", "Title")
  set_hl_link("markdownHeading5", "Title")
  set_hl_link("markdownHeading6", "Title")
end

--- Applies Treesitter-specific highlight groups with enhanced contrast.
--- @param colors table The table of color values (hex strings).
local function apply_treesitter_highlights(colors)
  if M.config.disable_treesitter_highlights then
    return
  end

  -- ENHANCED: More contrasting Treesitter highlight groups inspired by Rose Pine
  -- Key principle: Use more distinct colors for different semantic elements

  -- Comments - muted but readable
  set_hl("@comment", colors.on_surface_variant, nil, "italic")
  set_hl("@comment.documentation", colors.outline, nil, "italic")

  -- Constants group - use tertiary for regular constants, primary for special ones
  set_hl("@constant", colors.tertiary, nil, "bold")
  set_hl("@constant.builtin", colors.primary, nil, "bold") -- More prominent for built-ins
  set_hl("@constant.macro", colors.secondary, nil, "bold") -- Distinct color for macros

  -- Strings - keep secondary but enhance special strings
  set_hl("@string", colors.secondary)
  set_hl("@string.escape", colors.primary, nil, "bold") -- Make escapes pop
  set_hl("@string.special", colors.tertiary, nil, "bold") -- Special strings more visible
  set_hl("@string.regexp", colors.error, nil, "bold") -- Regex strings stand out

  -- Character literals
  set_hl("@character", colors.secondary)
  set_hl("@character.special", colors.primary, nil, "bold")

  -- Numbers - tertiary but with better distinction
  set_hl("@number", colors.tertiary, nil, "bold")
  set_hl("@number.float", colors.tertiary, nil, "bold,italic")

  -- Booleans - highly contrasting (Rose Pine principle)
  set_hl("@boolean", colors.error, nil, "bold")

  -- Variables - create hierarchy with different weights
  set_hl("@variable", colors.on_surface)
  set_hl("@variable.builtin", colors.primary, nil, "bold,italic") -- Built-in variables stand out
  set_hl("@variable.parameter", colors.on_surface, nil, "italic") -- Parameters slightly different
  set_hl("@variable.member", colors.tertiary) -- Object members more visible
  set_hl("@property", colors.tertiary) -- Properties same as members

  -- Functions - enhanced hierarchy and contrast
  set_hl("@function", colors.primary, nil, "bold")
  set_hl("@function.call", colors.primary) -- Function calls less bold
  set_hl("@function.builtin", colors.secondary, nil, "bold") -- Built-in functions distinct
  set_hl("@function.macro", colors.error, nil, "bold") -- Macros highly visible
  set_hl("@method", colors.primary, nil, "bold")
  set_hl("@method.call", colors.primary)
  set_hl("@constructor", colors.secondary, nil, "bold") -- Constructors distinct

  -- Keywords - enhanced contrast and semantic grouping
  set_hl("@keyword", colors.primary, nil, "bold")
  set_hl("@keyword.function", colors.secondary, nil, "bold") -- Function keywords distinct
  set_hl("@keyword.operator", colors.tertiary, nil, "bold") -- Operator keywords
  set_hl("@keyword.return", colors.error, nil, "bold") -- Return statements prominent
  set_hl("@keyword.conditional", colors.primary, nil, "bold")
  set_hl("@keyword.repeat", colors.primary, nil, "bold")
  set_hl("@keyword.import", colors.secondary, nil, "bold") -- Import/include statements
  set_hl("@keyword.export", colors.secondary, nil, "bold")
  set_hl("@keyword.storage", colors.secondary, nil, "bold") -- Storage class keywords
  set_hl("@keyword.modifier", colors.tertiary, nil, "bold") -- Modifiers like static, const

  -- Operators - more visible
  set_hl("@operator", colors.tertiary, nil, "bold")

  -- Control flow - highly visible
  set_hl("@conditional", colors.primary, nil, "bold")
  set_hl("@repeat", colors.primary, nil, "bold")
  set_hl("@label", colors.secondary, nil, "bold")
  set_hl("@exception", colors.error, nil, "bold")

  -- Includes and modules
  set_hl("@include", colors.secondary, nil, "bold")
  set_hl("@namespace", colors.tertiary, nil, "bold")
  set_hl("@module", colors.tertiary, nil, "bold")

  -- Types - enhanced hierarchy
  set_hl("@type", colors.secondary, nil, "bold")
  set_hl("@type.builtin", colors.primary, nil, "bold") -- Built-in types more prominent
  set_hl("@type.qualifier", colors.tertiary, nil, "bold") -- Type qualifiers distinct
  set_hl("@type.definition", colors.secondary, nil, "bold,underline") -- Type definitions
  set_hl("@storageclass", colors.tertiary, nil, "bold")

  -- Attributes and annotations
  set_hl("@attribute", colors.error, nil, "bold") -- Attributes/decorators stand out
  set_hl("@annotation", colors.error, nil, "bold")

  -- Punctuation - enhanced visibility
  set_hl("@punctuation.delimiter", colors.outline, nil, "bold")
  set_hl("@punctuation.bracket", colors.outline, nil, "bold")
  set_hl("@punctuation.special", colors.primary, nil, "bold")

  -- Tags (HTML/XML) - better contrast
  set_hl("@tag", colors.primary, nil, "bold")
  set_hl("@tag.attribute", colors.tertiary, nil, "bold")
  set_hl("@tag.delimiter", colors.outline, nil, "bold")

  -- Text content and formatting
  set_hl("@text", colors.on_background)
  set_hl("@text.literal", colors.secondary, nil, "bold") -- Code blocks more visible
  set_hl("@text.reference", colors.primary, nil, "bold")
  set_hl("@text.title", colors.primary, nil, "bold")
  set_hl("@text.uri", colors.tertiary, nil, "underline,bold")
  set_hl("@text.underline", nil, nil, "underline")
  set_hl("@text.todo", colors.on_tertiary_container, colors.tertiary_container, "bold")
  set_hl("@text.warning", colors.on_primary_container, colors.primary_container, "bold")
  set_hl("@text.danger", colors.on_error_container, colors.error_container, "bold")
  set_hl("@text.info", colors.on_secondary_container, colors.secondary_container, "bold")
  set_hl("@text.hint", colors.on_tertiary_container, colors.tertiary_container, "bold")

  -- Markdown specific - enhanced hierarchy
  set_hl("@markup.heading", colors.primary, nil, "bold")
  set_hl("@markup.heading.1", colors.primary, nil, "bold,underline")
  set_hl("@markup.heading.2", colors.secondary, nil, "bold")
  set_hl("@markup.heading.3", colors.tertiary, nil, "bold")
  set_hl("@markup.heading.4", colors.primary, nil, "bold")
  set_hl("@markup.heading.5", colors.secondary, nil, "bold")
  set_hl("@markup.heading.6", colors.tertiary, nil, "bold")
  set_hl("@markup.raw", colors.secondary, colors.surface_container, "bold")
  set_hl("@markup.raw.block", colors.secondary, colors.surface_container, "bold")
  set_hl("@markup.list", colors.tertiary, nil, "bold")
  set_hl("@markup.list.checked", colors.tertiary, nil, "bold")
  set_hl("@markup.list.unchecked", colors.outline, nil, "bold")
  set_hl("@markup.link", colors.primary, nil, "underline,bold")
  set_hl("@markup.link.label", colors.primary, nil, "bold")
  set_hl("@markup.link.url", colors.tertiary, nil, "underline,bold")
  set_hl("@markup.italic", colors.on_surface, nil, "italic")
  set_hl("@markup.bold", colors.on_surface, nil, "bold")
  set_hl("@markup.strikethrough", colors.on_surface_variant, nil, "strikethrough")
  set_hl("@markup.quote", colors.on_surface_variant, colors.surface_container, "italic")

  -- Diff - more contrasting
  set_hl("@diff.minus", colors.on_error_container, colors.error_container, "bold")
  set_hl("@diff.plus", colors.on_tertiary_container, colors.tertiary_container, "bold")
  set_hl("@diff.delta", colors.on_primary_container, colors.primary_container, "bold")

  -- Diagnostic (TS) - enhanced visibility
  set_hl("@diagnostic.error", colors.error, nil, "bold")
  set_hl("@diagnostic.warning", colors.primary, nil, "bold")
  set_hl("@diagnostic.info", colors.secondary, nil, "bold")
  set_hl("@diagnostic.hint", colors.tertiary, nil, "bold")

  -- LSP semantic tokens - enhanced contrast
  set_hl("@lsp.type.comment", colors.on_surface_variant, nil, "italic")
  set_hl("@lsp.type.keyword", colors.primary, nil, "bold")
  set_hl("@lsp.type.variable", colors.on_surface)
  set_hl("@lsp.type.parameter", colors.on_surface, nil, "italic")
  set_hl("@lsp.type.property", colors.tertiary, nil, "bold")
  set_hl("@lsp.type.function", colors.primary, nil, "bold")
  set_hl("@lsp.type.method", colors.primary, nil, "bold")
  set_hl("@lsp.type.enumMember", colors.tertiary, nil, "bold")
  set_hl("@lsp.type.namespace", colors.secondary, nil, "bold")
  set_hl("@lsp.type.type", colors.secondary, nil, "bold")
  set_hl("@lsp.type.interface", colors.secondary, nil, "bold,italic")
  set_hl("@lsp.type.struct", colors.secondary, nil, "bold")
  set_hl("@lsp.type.enum", colors.secondary, nil, "bold")
  set_hl("@lsp.type.class", colors.secondary, nil, "bold,underline")
  set_hl("@lsp.type.event", colors.tertiary, nil, "bold")
  set_hl("@lsp.type.macro", colors.error, nil, "bold")
  set_hl("@lsp.type.decorator", colors.error, nil, "bold")
  set_hl("@lsp.type.modifier", colors.tertiary, nil, "bold")

  -- Language-specific enhancements
  -- JavaScript/TypeScript
  set_hl("@lsp.type.typeParameter", colors.primary, nil, "bold,italic")
  set_hl("@constructor.typescript", colors.secondary, nil, "bold")
  set_hl("@constructor.javascript", colors.secondary, nil, "bold")

  -- Rust
  set_hl("@lsp.type.lifetime", colors.error, nil, "bold,italic")
  set_hl("@lsp.type.selfKeyword", colors.primary, nil, "bold,italic")

  -- Python
  set_hl("@lsp.type.decorator.python", colors.error, nil, "bold")
  set_hl("@lsp.type.selfParameter", colors.primary, nil, "bold,italic")

  -- C/C++
  set_hl("@lsp.type.concept", colors.secondary, nil, "bold,italic")
  set_hl("@preproc", colors.secondary, nil, "bold")

  -- Additional semantic enhancements
  set_hl("@field", colors.tertiary) -- Struct/class fields
  set_hl("@constant.macro", colors.secondary, nil, "bold") -- Macro constants
  set_hl("@define", colors.secondary, nil, "bold") -- Preprocessor defines
  set_hl("@symbol", colors.primary, nil, "bold") -- Symbols
  set_hl("@embedded", colors.on_surface, colors.surface_container) -- Embedded code
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
      goto continue
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
        fg = colors[color_key] or fg
      end
      if bg and type(bg) == "string" and bg:match("^colors%.") then
        local color_key = bg:match("^colors%.(.+)$")
        bg = colors[color_key] or bg
      end
    end

    -- Use the centralized set_hl function to apply the custom highlight
    set_hl(group, fg, bg, style)
    ::continue::
  end
end

--- Applies plugin-specific highlight groups based on the enabled plugins in config.
--- These highlights are loaded from separate Lua modules.
--- @param colors table The table of color values (hex strings).
--- @param background_style string "dark" or "light"
local function apply_plugin_highlights(colors, background_style)
  if not M.config.plugins then
    return
  end

  for plugin_name, enabled in pairs(M.config.plugins) do
    if enabled then
      -- Construct the module path for the plugin highlights
      local plugin_module_path = "matugen_colorscheme.plugins." .. plugin_name

      local ok, plugin_module = pcall(require, plugin_module_path)
      if ok and type(plugin_module) == "table" and type(plugin_module.setup) == "function" then
        -- Pass colors, set_hl, set_hl_link, and the main config to the plugin module
        plugin_module.setup(colors, set_hl, set_hl_link, M.config)
      elseif not ok then
        vim.notify(
          "Failed to load plugin highlight module '" .. plugin_module_path .. "': " .. plugin_module,
          vim.log.levels.ERROR,
          { title = "Matugen.nvim" }
        )
      else
        vim.notify(
          "Plugin highlight module '"
            .. plugin_module_path
            .. "' is not correctly structured (missing setup function or not a table).",
          vim.log.levels.WARN,
          { title = "Matugen.nvim" }
        )
      end
    end
  end
end

--- Sets terminal colors based on Matugen's palette.
--- @param colors table The table of color values (hex strings).
local function set_terminal_colors(colors)
  if not M.config.set_term_colors then
    return
  end

  -- IMPROVED: Better terminal color mapping
  local term_colors = {
    colors.surface_container_high or colors.surface, -- 0: Black
    colors.error, -- 1: Red
    colors.tertiary, -- 2: Green
    colors.secondary, -- 3: Yellow
    colors.primary, -- 4: Blue
    colors.error_container, -- 5: Magenta
    colors.secondary_container, -- 6: Cyan
    colors.on_surface, -- 7: White

    colors.outline, -- 8: Bright Black
    colors.on_error_container, -- 9: Bright Red
    colors.on_tertiary_container, -- 10: Bright Green
    colors.on_secondary_container, -- 11: Bright Yellow
    colors.on_primary_container, -- 12: Bright Blue
    colors.on_error, -- 13: Bright Magenta
    colors.on_secondary, -- 14: Bright Cyan
    colors.on_background, -- 15: Bright White
  }

  for i = 0, 15 do
    if term_colors[i + 1] then
      vim.g["terminal_color_" .. i] = term_colors[i + 1]
    end
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

  -- Apply plugin-specific highlights
  apply_plugin_highlights(loaded_colors, current_background_style)

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
    -- disable_plugin_highlights is now replaced by the 'plugins' table
    disable_treesitter_highlights = false, -- Don't apply Treesitter highlights
    disable_notifications = false, -- Don't show success notifications
    disable_generation_hint = false, -- Don't show generation hint when file not found
    ignore_groups = {}, -- Table of highlight groups to ignore: { "Normal" = true, "Comment" = true }
    custom_highlights = {}, -- Custom highlight overrides: { "Normal" = { fg = "#RRGGBB", bg = "colors.surface", style = "bold" } }
    transparent_background = false, -- Set background to NONE for UI elements (e.g., Normal, Float, StatusLine)
    set_term_colors = true, -- Set terminal colors (terminal_color_0 to terminal_color_15) based on Matugen palette
    plugins = {
      -- Enable or disable plugin-specific highlights here
      -- Example:
      -- cmp = true,
      -- nvimtree = true,
      -- telescope = true,
      -- gitsigns = true,
      -- bufferline = true, -- For Bufferline / Barbar
      -- lspsaga = true,
    },
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

  -- Autocmd for Treesitter-specific highlights, plugin highlights, and custom highlights
  -- These need to be re-applied after a ColorScheme event, as other plugins
  -- or Neovim itself might overwrite them.
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("MatugenPostHighlights", { clear = true }),
    callback = function()
      -- Only apply if our colorscheme is active and we have loaded colors
      if vim.g.colors_name == "matugen_colors" and next(loaded_colors) ~= nil then
        apply_treesitter_highlights(loaded_colors)
        apply_plugin_highlights(loaded_colors, current_background_style) -- Re-apply plugin highlights
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

return M
