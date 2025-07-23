local M = {}

local loaded_colors = {}
local current_background_style = "dark"

local function set_hl(group, fg, bg, style)
  if M.config.ignore_groups and M.config.ignore_groups[group] then return end
  local cmd = "highlight " .. group
  if fg then cmd = cmd .. " guifg=" .. fg end
  if bg then cmd = cmd .. " guibg=" .. bg end
  if style then cmd = cmd .. " gui=" .. style end
  vim.cmd(cmd)
end

local function set_hl_link(from, to)
  if M.config.ignore_groups and M.config.ignore_groups[from] then return end
  vim.cmd("highlight link " .. from .. " " .. to)
end

local function load_highlight_module(name)
  local ok, mod = pcall(require, "matugen_colorscheme.highlights." .. name)
  if not ok then
    vim.notify("Failed to load highlights module '" .. name .. "': " .. mod, vim.log.levels.ERROR, { title =
    "Matugen.nvim" })
    return nil
  end
  return mod
end

local function apply_all_highlights(colors)
  local sets = { "base", "treesitter" } -- add more names here if needed

  -- Clear highlights if not disabled
  if not M.config.disable_clear then
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") == 1 then
      vim.cmd("syntax reset")
    end
  end

  vim.o.background = current_background_style
  vim.g.colors_name = "matugen_colors"

  for _, name in ipairs(sets) do
    local mod = load_highlight_module(name)
    if mod and mod.apply then
      mod.apply(colors, set_hl, set_hl_link, M.config)
    end
  end
end

function M.load_matugen_colorscheme()
  local path = vim.fn.expand(M.config.file)
  current_background_style = M.config.background_style

  if vim.fn.filereadable(path) == 0 then
    vim.notify("Matugen colors file not found at: " .. path, vim.log.levels.ERROR, { title = "Matugen.nvim" })
    return
  end

  local f = io.open(path, "r")
  if not f then return end
  local content = f:read("*a")
  f:close()

  -- strip JSONC comments
  content = content:gsub("/%*.-%*/", ""):gsub("//[^\n]*", "")

  local ok, colors = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Failed to decode colors JSON: " .. colors, vim.log.levels.ERROR, { title = "Matugen.nvim" })
    return
  end

  loaded_colors = colors
  apply_all_highlights(loaded_colors)

  if not M.config.disable_notifications then
    vim.notify("Matugen colorscheme loaded successfully!", vim.log.levels.INFO, { title = "Matugen.nvim" })
  end
end

function M.setup(opts)
  local defaults = {
    file = vim.fn.stdpath("cache") .. "/matugen/colors.jsonc",
    background_style = "dark",
    auto_load = true,
    disable_clear = false,
    disable_treesitter_highlights = false,
    disable_notifications = false,
    ignore_groups = {},
    transparent_background = false,
  }

  M.config = vim.tbl_deep_extend("force", defaults, opts or {})

  if M.config.auto_load then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("MatugenColorschemeAutoLoad", { clear = true }),
      callback = function() M.load_matugen_colorscheme() end,
    })
  end
end

return M
