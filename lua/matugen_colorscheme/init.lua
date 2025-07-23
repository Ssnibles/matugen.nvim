local M = {}

-- Utility to get highlight module path
local function get_highlight_module_path(name)
  return "matugen_colorscheme.highlights." .. name
end

--- Enhanced highlight setter with proper style handling
--- @param group string Highlight group name
--- @param opts table Highlight attributes
local function set_hl(group, opts)
  if opts.link then
    vim.api.nvim_set_hl(0, group, { link = opts.link })
    return
  end

  local hl = {}

  -- Color attributes
  if opts.fg then
    hl.fg = opts.fg
  end
  if opts.bg then
    hl.bg = opts.bg
  end
  if opts.sp then
    hl.sp = opts.sp
  end

  -- Style attributes - convert to individual flags
  if opts.style then
    local styles = type(opts.style) == "string" and vim.split(opts.style, "[%s,]+", { plain = true, trimempty = true })
      or opts.style
    for _, s in ipairs(styles) do
      if s == "bold" then
        hl.bold = true
      elseif s == "italic" then
        hl.italic = true
      elseif s == "underline" then
        hl.underline = true
      elseif s == "undercurl" then
        hl.undercurl = true
      elseif s == "reverse" then
        hl.reverse = true
      elseif s == "strikethrough" then
        hl.strikethrough = true
      elseif s == "nocombine" then
        hl.nocombine = true
      end
    end
  end

  -- Terminal attributes
  if opts.ctermfg then
    hl.ctermfg = opts.ctermfg
  end
  if opts.ctermbg then
    hl.ctermbg = opts.ctermbg
  end
  if opts.cterm then
    hl.cterm = type(opts.cterm) == "string" and vim.split(opts.cterm, "[%s,]+", { plain = true, trimempty = true })
      or opts.cterm
  end

  vim.api.nvim_set_hl(0, group, hl)
end

-- Default configuration
M.config = {
  file = vim.fn.stdpath("cache") .. "/matugen/colors.jsonc",
  plugins = {
    base = true,
    treesitter = true,
    cmp = false,
    lualine = false,
    gitsigns = false,
    telescope = false,
  },
  ignore_groups = {},
  custom_highlights = {},
}

--- Reads and parses color file
--- @return table|nil Parsed colors or nil on error
local function read_colors()
  local file_path = vim.fn.expand(M.config.file)
  local f, err = io.open(file_path, "r")
  if not f then
    vim.notify("MatugenColorscheme: File error - " .. (err or "unknown"), vim.log.levels.ERROR)
    return nil
  end

  local content = f:read("*a")
  f:close()

  -- Strip JSONC comments
  local cleaned = content:gsub("//[^\n]*", "")
  local ok, colors = pcall(vim.json.decode, cleaned)

  if not ok then
    vim.notify("MatugenColorscheme: JSON parse error - " .. colors, vim.log.levels.ERROR)
    return nil
  end

  return colors
end

--- Applies highlight module safely
--- @param name string Module name
--- @param colors table Color palette
local function apply_highlight_module(name, colors)
  if not M.config.plugins[name] then
    return
  end

  local mod_ok, mod = pcall(require, get_highlight_module_path(name))
  if not mod_ok or type(mod.apply) ~= "function" then
    vim.notify("MatugenColorscheme: Invalid module - " .. name, vim.log.levels.WARN)
    return
  end

  mod.apply(colors, M.config, set_hl)
end

--- Setup Lualine highlights
--- @param colors table Color palette
local function setup_lualine(colors)
  if not M.config.plugins.lualine then
    return
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "LualineReady",
    once = true,
    callback = function()
      apply_highlight_module("lualine", colors)
    end,
  })

  if vim.b.lualine_setup then
    vim.schedule(function()
      vim.cmd("doautocmd User LualineReady")
    end)
  end
end

--- Apply colorscheme
function M.apply_colors()
  -- Reset environment
  vim.cmd("highlight clear")
  vim.cmd("syntax reset")
  vim.opt.termguicolors = true

  -- Load colors
  local colors = read_colors()
  if not colors then
    return
  end

  -- Set base background
  set_hl("Normal", {
    bg = colors.background or "NONE",
    fg = colors.on_surface or "NONE",
  })

  -- Apply core highlights
  apply_highlight_module("base", colors)
  apply_highlight_module("treesitter", colors)
  apply_highlight_module("cmp", colors)
  apply_highlight_module("gitsigns", colors)
  apply_highlight_module("telescope", colors)

  -- Setup deferred highlights
  setup_lualine(colors)

  -- Apply custom highlights
  for group, opts in pairs(M.config.custom_highlights) do
    set_hl(group, opts)
  end

  -- Clear ignored groups
  for _, group in ipairs(M.config.ignore_groups) do
    vim.cmd(string.format("highlight! clear %s", group))
  end
end

--- Setup entry point
--- @param opts table|nil User configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  M.apply_colors()
end

-- Create user command
vim.api.nvim_create_user_command("MatugenColorschemeApply", M.apply_colors, {
  desc = "Apply Matugen colorscheme",
})

return M
