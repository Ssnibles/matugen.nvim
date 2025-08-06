local M = {}

-- Default configuration
local default_config = {
  file = vim.fn.stdpath("cache") .. "/matugen/colors.jsonc",
  plugins = {
    base = true,
    treesitter = true,
    cmp = false,
    lualine = false,
    gitsigns = false,
    telescope = false,
    miscellaneous = true,
  },
  ignore_groups = {},
  custom_highlights = {},
  debug = false, -- Enable for troubleshooting
}

local config = {}
local colors_cache = nil

-- Style mappings for cleaner code
local STYLES = {
  bold = "bold",
  italic = "italic",
  underline = "underline",
  undercurl = "undercurl",
  reverse = "reverse",
  strikethrough = "strikethrough",
}

--- Debug logging function
--- @param message string
--- @param level? number
local function debug_log(message, level)
  if not config.debug then
    return
  end
  level = level or vim.log.levels.INFO
  vim.notify("Matugen Debug: " .. message, level)
end

--- Enhanced highlight setter with better error handling
--- @param group string
--- @param opts table
local function set_hl(group, opts)
  if not group or type(group) ~= "string" then
    debug_log("Invalid group name: " .. tostring(group), vim.log.levels.WARN)
    return
  end

  if not opts or type(opts) ~= "table" then
    debug_log("Invalid opts for group " .. group, vim.log.levels.WARN)
    return
  end

  -- Handle links
  if opts.link then
    local ok, err = pcall(vim.api.nvim_set_hl, 0, group, { link = opts.link })
    if not ok then
      debug_log("Failed to link " .. group .. " to " .. opts.link .. ": " .. err, vim.log.levels.ERROR)
    end
    return
  end

  local hl = {}

  -- Set color fields
  for _, field in ipairs({ "fg", "bg", "sp", "ctermfg", "ctermbg" }) do
    if opts[field] then
      hl[field] = opts[field]
    end
  end

  -- Handle styles
  if opts.style then
    local styles = type(opts.style) == "table" and opts.style or { opts.style }
    for _, style in ipairs(styles) do
      if STYLES[style] then
        hl[STYLES[style]] = true
      else
        debug_log("Unknown style: " .. tostring(style), vim.log.levels.WARN)
      end
    end
  end

  -- Apply highlight with error handling
  local ok, err = pcall(vim.api.nvim_set_hl, 0, group, hl)
  if not ok then
    debug_log("Failed to set highlight " .. group .. ": " .. err, vim.log.levels.ERROR)
  end
end

--- Load and cache color data with comprehensive error handling
--- @return table|nil
local function load_colors()
  if colors_cache then
    debug_log("Using cached colors")
    return colors_cache
  end

  local file_path = vim.fn.expand(config.file)
  debug_log("Loading colors from: " .. file_path)

  -- Check if file exists
  if vim.fn.filereadable(file_path) ~= 1 then
    vim.notify("Matugen: Color file not found: " .. file_path, vim.log.levels.ERROR)
    debug_log("File does not exist or is not readable")
    return nil
  end

  local file = io.open(file_path, "r")
  if not file then
    vim.notify("Matugen: Cannot open color file: " .. file_path, vim.log.levels.ERROR)
    return nil
  end

  local content = file:read("*a")
  file:close()

  if not content or content == "" then
    vim.notify("Matugen: Color file is empty", vim.log.levels.ERROR)
    return nil
  end

  debug_log("File content length: " .. #content)

  -- Remove JSONC comments
  content = content:gsub("//[^\n]*", "")

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Matugen: Invalid JSON in color file: " .. tostring(data), vim.log.levels.ERROR)
    debug_log("JSON decode error: " .. tostring(data))
    return nil
  end

  if not data or type(data) ~= "table" then
    vim.notify("Matugen: Invalid color data format", vim.log.levels.ERROR)
    return nil
  end

  -- Validate essential colors
  local essential_colors = { "background", "on_surface", "primary" }
  for _, color in ipairs(essential_colors) do
    if not data[color] then
      vim.notify("Matugen: Missing essential color: " .. color, vim.log.levels.WARN)
    end
  end

  colors_cache = data
  debug_log("Colors loaded successfully, found " .. vim.tbl_count(data) .. " colors")
  return colors_cache
end

--- Apply highlight module safely with better error reporting
--- @param name string
--- @param colors table
local function apply_module(name, colors)
  if not config.plugins[name] then
    debug_log("Module " .. name .. " is disabled")
    return
  end

  debug_log("Loading module: " .. name)

  local module_path = "matugen_colorscheme.highlights." .. name
  local ok, module = pcall(require, module_path)

  if not ok then
    vim.notify("Matugen: Failed to load module " .. name .. ": " .. module, vim.log.levels.ERROR)
    debug_log("Module load error: " .. module)
    return
  end

  if type(module.apply) ~= "function" then
    vim.notify("Matugen: Module " .. name .. " has no apply function", vim.log.levels.ERROR)
    return
  end

  debug_log("Applying module: " .. name)
  local apply_ok, apply_err = pcall(module.apply, colors, config, set_hl)

  if not apply_ok then
    vim.notify("Matugen: Error applying module " .. name .. ": " .. apply_err, vim.log.levels.ERROR)
    debug_log("Module apply error: " .. apply_err)
  else
    debug_log("Module " .. name .. " applied successfully")
  end
end

--- Main colorscheme application function
function M.apply()
  debug_log("Starting colorscheme application")

  -- Reset highlights
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end

  -- Set colorscheme name
  vim.g.colors_name = "matugen"
  vim.opt.termguicolors = true
  debug_log("Cleared existing highlights and set termguicolors")

  local colors = load_colors()
  if not colors then
    vim.notify("Matugen: Failed to load colors, aborting", vim.log.levels.ERROR)
    return false
  end

  -- Set Normal group first (essential for proper rendering)
  set_hl("Normal", {
    fg = colors.on_surface or "#ffffff",
    bg = colors.background or "#000000",
  })
  debug_log("Set Normal highlight group")

  -- Apply plugin highlights
  local modules_applied = 0
  for module_name in pairs(config.plugins) do
    apply_module(module_name, colors)
    modules_applied = modules_applied + 1
  end
  debug_log("Applied " .. modules_applied .. " highlight modules")

  -- Apply custom highlights
  local custom_count = 0
  for group, opts in pairs(config.custom_highlights) do
    set_hl(group, opts)
    custom_count = custom_count + 1
  end
  if custom_count > 0 then
    debug_log("Applied " .. custom_count .. " custom highlights")
  end

  -- Clear ignored groups
  for _, group in ipairs(config.ignore_groups) do
    local ok, err = pcall(vim.cmd, "highlight clear " .. group)
    if not ok then
      debug_log("Failed to clear group " .. group .. ": " .. err, vim.log.levels.WARN)
    end
  end

  if #config.ignore_groups > 0 then
    debug_log("Cleared " .. #config.ignore_groups .. " ignored groups")
  end

  debug_log("Colorscheme application completed successfully")
  return true
end

--- Force reload colors (clear cache and reapply)
function M.reload()
  debug_log("Force reloading colorscheme")
  colors_cache = nil
  return M.apply()
end

--- Setup function with enhanced validation
--- @param opts table|nil
function M.setup(opts)
  debug_log("Setting up Matugen colorscheme")

  -- Merge configuration
  config = vim.tbl_deep_extend("force", default_config, opts or {})

  -- Validate configuration
  if type(config.file) ~= "string" then
    vim.notify("Matugen: Invalid file path in config", vim.log.levels.ERROR)
    return false
  end

  if type(config.plugins) ~= "table" then
    vim.notify("Matugen: Invalid plugins config", vim.log.levels.ERROR)
    return false
  end

  debug_log("Configuration merged successfully")
  debug_log("Color file: " .. config.file)
  debug_log("Debug mode: " .. tostring(config.debug))

  -- Clear cache when config changes
  colors_cache = nil

  -- Create commands with better error handling
  vim.api.nvim_create_user_command("MatugenApply", function()
    local success = M.apply()
    if success then
      vim.notify("Matugen: Colorscheme applied successfully", vim.log.levels.INFO)
    end
  end, {
    desc = "Apply Matugen colorscheme",
  })

  vim.api.nvim_create_user_command("MatugenReload", function()
    local success = M.reload()
    if success then
      vim.notify("Matugen: Colorscheme reloaded successfully", vim.log.levels.INFO)
    end
  end, {
    desc = "Reload Matugen colorscheme (clear cache)",
  })

  vim.api.nvim_create_user_command("MatugenDebug", function()
    config.debug = not config.debug
    vim.notify("Matugen: Debug mode " .. (config.debug and "enabled" or "disabled"), vim.log.levels.INFO)
  end, {
    desc = "Toggle Matugen debug mode",
  })

  vim.api.nvim_create_user_command("MatugenApplyReload", function()
    local success = M.apply() and M.reload()
    if success then
      vim.notify("Matugen Colorscheme loaded and applied successfully", vim.log.levels.INFO)
    end
  end, {
    desc = "Apply and Load Matugen Colorscheme",
  })

  vim.api.nvim_create_user_command("MatugenStatus", function()
    local file_exists = vim.fn.filereadable(vim.fn.expand(config.file)) == 1
    local colors_loaded = colors_cache ~= nil

    print("Matugen Status:")
    print("  Color file: " .. config.file)
    print("  File exists: " .. tostring(file_exists))
    print("  Colors cached: " .. tostring(colors_loaded))
    print("  Debug mode: " .. tostring(config.debug))
    print("  Enabled plugins:")
    for plugin, enabled in pairs(config.plugins) do
      if enabled then
        print("    - " .. plugin)
      end
    end
  end, {
    desc = "Show Matugen status and configuration",
  })

  debug_log("Commands created successfully")

  -- Apply colorscheme
  local success = M.apply()
  if not success then
    vim.notify("Matugen: Initial setup failed", vim.log.levels.ERROR)
    return false
  end

  debug_log("Setup completed successfully")
  return true
end

--- Clear color cache (useful for development)
function M.clear_cache()
  colors_cache = nil
  debug_log("Color cache cleared")
end

--- Get current configuration (for debugging)
function M.get_config()
  return vim.deepcopy(config)
end

--- Get cached colors (for debugging)
function M.get_colors()
  return colors_cache and vim.deepcopy(colors_cache) or nil
end

return M
