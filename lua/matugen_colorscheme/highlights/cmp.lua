-- ~/projects/matugen.nvim/lua/matugen_colorscheme/highlights/cmp.lua
-- Completion highlights for nvim-cmp and blink.cmp using centralized colors.

local M = {}

local U = require("matugen_colorscheme.utils")
local Cmod = require("matugen_colorscheme.colors")

-- Simple style aliases
local STYLES = {
  bold = { "bold" },
  italic = { "italic" },
  strikethrough = { "strikethrough" },
  bold_italic = { "bold", "italic" },
}

-- LSP CompletionItemKind list (used by both engines for per-kind groups).
local LSP_KINDS = {
  "Text",
  "Method",
  "Function",
  "Constructor",
  "Field",
  "Variable",
  "Class",
  "Interface",
  "Module",
  "Property",
  "Unit",
  "Value",
  "Enum",
  "Keyword",
  "Snippet",
  "Color",
  "File",
  "Reference",
  "Folder",
  "EnumMember",
  "Constant",
  "Struct",
  "Event",
  "Operator",
  "TypeParameter",
}

function M.apply(colors, config, set_hl)
  -- Centralized palette snapshot
  local C = Cmod.get()

  -- Menu/doc surfaces and separations (provided by colors.lua)
  local menu_bg = C.menu_bg
  local menu_fg = C.menu_fg
  local menu_muted = C.menu_muted
  local doc_bg = C.doc_bg
  local doc_border = C.doc_border

  local selected_bg = C.selection_bg
  local selected_fg = C.selection_fg

  -- Matching/emphasis accents
  local match_fg = C.match_fg

  -- nvim-cmp
  set_hl("CmpItemAbbr", { fg = menu_fg })
  set_hl("CmpItemAbbrDeprecated", { fg = menu_muted, style = STYLES.strikethrough })
  set_hl("CmpItemAbbrMatch", { fg = match_fg, style = STYLES.bold })
  set_hl("CmpItemAbbrMatchFuzzy", { fg = U.ensure_contrast(C.primary_container, menu_bg, 4.5), style = STYLES.bold })

  set_hl("CmpItemKind", { fg = menu_muted })
  set_hl("CmpItemMenu", { fg = menu_muted })

  for _, kind in ipairs(LSP_KINDS) do
    -- Map kinds to accents using centralized prim/sec/tert variants
    local color = C.primary
    if kind == "Function" or kind == "Method" or kind == "Module" then
      color = C.secondary
    elseif kind == "Class" or kind == "Interface" or kind == "Struct" or kind == "TypeParameter" then
      color = C.tertiary
    elseif kind == "Constant" or kind == "Enum" or kind == "EnumMember" or kind == "Number" or kind == "Value" then
      color = C.primary_container
    elseif kind == "String" or kind == "File" or kind == "Folder" or kind == "Unit" then
      color = C.tertiary_container
    elseif kind == "Variable" or kind == "Field" or kind == "Property" then
      color = C.primary_container
    elseif kind == "Snippet" then
      color = C.secondary_container
    elseif kind == "Boolean" or kind == "Keyword" or kind == "Operator" or kind == "Event" then
      color = C.primary
    elseif kind == "Color" or kind == "Reference" then
      color = menu_muted
    end
    set_hl("CmpItemKind" .. kind, { fg = U.ensure_contrast(color, menu_bg, 4.5) })
  end

  set_hl("CmpDocumentation", { bg = doc_bg })
  set_hl("CmpDocumentationBorder", { fg = doc_border })
  set_hl("CmpGhostText", { fg = U.ensure_contrast(C.fg_muted, menu_bg, 4.5), style = STYLES.italic })

  -- blink.cmp (BlinkCmp* namespace)
  set_hl("BlinkCmpMenu", { fg = menu_fg, bg = menu_bg })
  set_hl("BlinkCmpMenuBorder", { fg = U.ensure_contrast(C.border, menu_bg, 4.5) })
  set_hl("BlinkCmpMenuSelection", { fg = selected_fg, bg = selected_bg, style = STYLES.bold })

  set_hl("BlinkCmpLabel", { fg = menu_fg })
  set_hl("BlinkCmpLabelDeprecated", { fg = menu_muted, style = STYLES.strikethrough })
  set_hl("BlinkCmpLabelMatch", { fg = match_fg, style = STYLES.bold })
  set_hl("BlinkCmpGhostText", { fg = U.ensure_contrast(C.fg_muted, menu_bg, 4.5), style = STYLES.italic })

  set_hl("BlinkCmpDoc", { bg = doc_bg })
  set_hl("BlinkCmpDocBorder", { fg = doc_border })
  set_hl("BlinkCmpSignatureHelpBorder", { fg = doc_border })

  set_hl("BlinkCmpKind", { fg = menu_muted })
  for _, kind in ipairs(LSP_KINDS) do
    local color = C.primary
    if kind == "Function" or kind == "Method" or kind == "Module" then
      color = C.secondary
    elseif kind == "Class" or kind == "Interface" or kind == "Struct" or kind == "TypeParameter" then
      color = C.tertiary
    elseif kind == "Constant" or kind == "Enum" or kind == "EnumMember" or kind == "Number" or kind == "Value" then
      color = C.primary_container
    elseif kind == "String" or kind == "File" or kind == "Folder" or kind == "Unit" then
      color = C.tertiary_container
    elseif kind == "Variable" or kind == "Field" or kind == "Property" then
      color = C.primary_container
    elseif kind == "Snippet" then
      color = C.secondary_container
    elseif kind == "Boolean" or kind == "Keyword" or kind == "Operator" or kind == "Event" then
      color = C.primary
    elseif kind == "Color" or kind == "Reference" then
      color = menu_muted
    end
    set_hl("BlinkCmpKind" .. kind, { fg = U.ensure_contrast(color, menu_bg, 4.5) })
  end
end

return M
