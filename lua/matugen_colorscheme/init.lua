local M = {}
local config = {}
local hl_modules = {
  base = true,
  treesitter = true,
  cmp = false,
  lualine = false,
  gitsigns = false,
  telescope = false,
}

-- Style attribute mappings
local style_attrs = {
  bold = "bold",
  italic = "italic",
  underline = "underline",
  undercurl = "undercurl",
  reverse = "reverse",
  strikethrough = "strikethrough",
  nocombine = "nocombine",
}

--- Enhanced highlight setter
--- @param group string
--- @param opts table
local function set_hl(group, opts)
  if opts.link then
    vim.api.nvim_set_hl(0, group, { link = opts.link })
    return
  end

  local hl = {}
  local fields = { "fg", "bg", "sp", "ctermfg", "ctermbg" }

  -- Set color fields
  for _, field in ipairs(fields) do
    if opts[field] then
      hl[field] = opts[field]
    end
  end

  -- Parse style attributes
  if opts.style then
    local styles = type(opts.style) == "table" and opts.style or vim.split(opts.style, "[%s,]+", { trimempty = true })

    for _, style in ipairs(styles) do
      local attr = style_attrs[style]
      if attr then
        hl[attr] = true
      end
    end
  end

  -- Handle cterm styles
  if opts.cterm then
    hl.cterm = type(opts.cterm) == "table" and opts.cterm or vim.split(opts.cterm, "[%s,]+", { trimempty = true })
  end

  vim.api.nvim_set_hl(0, group, hl)
end

--- Loads color data with error handling
--- @return table|nil
local function load_colors()
  local file_path = vim.fn.expand(config.file)
  local f, err = io.open(file_path, "r")
  if not f then
    vim.notify("MatugenColorscheme: File error - " .. (err or "unknown"), vim.log.levels.ERROR)
    return nil
  end

  local content = f:read("*a")
  f:close()

  -- Strip JSONC comments
  local cleaned = content:gsub("//[^\n]*", "")
  local ok, colors = pcall(vim.json.decode, cleaned, { luanil = { object = true } })

  if not ok or not colors then
    vim.notify("MatugenColorscheme: JSON parse error - " .. (colors or "invalid data"), vim.log.levels.ERROR)
    return nil
  end

  return colors
end

--- Applies highlight module
--- @param name string
--- @param colors table
local function apply_hl_module(name, colors)
  if not config.plugins[name] then
    return
  end

  local ok, mod = pcall(require, "matugen_colorscheme.highlights." .. name)
  if not ok or type(mod.apply) ~= "function" then
    vim.notify("MatugenColorscheme: Invalid module - " .. name, vim.log.levels.WARN)
    return
  end

  mod.apply(colors, config, set_hl)
end

--- Sets up deferred highlights
--- @param colors table
local function setup_deferred_highlights(colors)
  if not config.plugins.lualine then
    return
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "LualineReady",
    once = true,
    callback = function()
      apply_hl_module("lualine", colors)
    end,
  })

  if vim.b.lualine_setup then
    vim.schedule(function()
      vim.cmd("doautocmd User LualineReady")
    end)
  end
end

--- Applies colorscheme
function M.apply_colors()
  vim.cmd("highlight clear | syntax reset")
  vim.opt.termguicolors = true

  local colors = load_colors()
  if not colors then
    return
  end

  -- Set base colors
  set_hl("Normal", {
    bg = colors.background or "NONE",
    fg = colors.on_surface or "NONE",
  })

  -- Apply core highlights
  for module in pairs(hl_modules) do
    apply_hl_module(module, colors)
  end

  -- Apply custom highlights
  for group, opts in pairs(config.custom_highlights) do
    set_hl(group, opts)
  end

  -- Clear ignored groups
  for _, group in ipairs(config.ignore_groups) do
    vim.cmd("hi! clear " .. group)
  end

  setup_deferred_highlights(colors)
end

--- Setup function
--- @param opts table|nil
function M.setup(opts)
  config = vim.tbl_deep_extend("force", {
    file = vim.fn.stdpath("cache") .. "/matugen/colors.jsonc",
    plugins = hl_modules,
    ignore_groups = {},
    custom_highlights = {},
  }, opts or {})

  M.apply_colors()
end

-- Create user command
vim.api.nvim_create_user_command("MatugenColorschemeApply", M.apply_colors, {
  desc = "Apply Matugen colorscheme",
})

return M
