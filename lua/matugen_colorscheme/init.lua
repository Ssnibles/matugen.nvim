-- ~/projects/matugen.nvim/lua/matugen_colorscheme/init.lua

local M = {}

-- Utility to get a highlight module path
local function get_highlight_module_path(name)
  return "matugen_colorscheme.highlights." .. name
end

--- Helper function to set highlight groups.
--- @param group_name string The name of the highlight group.
--- @param fg_color string|nil Foreground color (e.g., "#RRGGBB" or "NONE").
--- @param bg_color string|nil Background color (e.g., "#RRGGBB" or "NONE").
--- @param gui_style string|nil GUI style attributes (e.g., "bold", "italic", "underline", "reverse", "strikethrough").
--- @param cterm_fg_color string|nil Cterm foreground color (optional, for 256-color terminals).
--- @param cterm_bg_color string|nil Cterm background color (optional, for 256-color terminals).
--- @param cterm_style string|nil Cterm style attributes (optional).
local function set_hl(group_name, fg_color, bg_color, gui_style, cterm_fg_color, cterm_bg_color, cterm_style)
  local cmd_parts = { "highlight", group_name }

  if fg_color then
    table.insert(cmd_parts, "guifg=" .. fg_color)
  end
  if bg_color then
    table.insert(cmd_parts, "guibg=" .. bg_color)
  end
  if gui_style then
    -- Ensure GUI styles are correctly formatted with 'gui='
    local styles = {}
    for style in string.gmatch(gui_style, "[^%s,]+") do -- Split by space or comma
      table.insert(styles, style)
    end
    if #styles > 0 then
      table.insert(cmd_parts, "gui=" .. table.concat(styles, ","))
    end
  end

  -- Cterm colors (for 256-color terminals, useful for fallback or specific terminal rendering)
  if cterm_fg_color then
    table.insert(cmd_parts, "ctermfg=" .. cterm_fg_color)
  end
  if cterm_bg_color then
    table.insert(cmd_parts, "ctermbg=" .. cterm_bg_color)
  end
  if cterm_style then
    local cterm_styles = {}
    for style in string.gmatch(cterm_style, "[^%s,]+") do
      table.insert(cterm_styles, style)
    end
    if #cterm_styles > 0 then
      table.insert(cmd_parts, "cterm=" .. table.concat(cterm_styles, ","))
    end
  end

  local command = table.concat(cmd_parts, " ")
  -- vim.notify("Setting HL: " .. command, vim.log.levels.DEBUG) -- Uncomment for debugging
  vim.cmd(command)
end

-- Default configuration
M.config = {
  file = vim.fn.stdpath("cache") .. "/matugen/colors.jsonc",
  plugins = {
    base = true,
    cmp = false,
    lualine = false, -- Make sure this is true if you want Lualine highlights applied
    gitsigns = false,
    telescope = false,
    treesitter = false,
  },
  ignore_groups = {},
  custom_highlights = {},
}

--- Reads the colors from the specified JSON file.
local function read_colors(file_path)
  local expanded_file_path = vim.fn.expand(file_path)
  vim.notify("MatugenColorscheme: Attempting to read file: " .. expanded_file_path, vim.log.levels.INFO)

  local f, open_err = io.open(expanded_file_path, "r")
  if not f then
    vim.notify(
      "MatugenColorscheme: Could not open file: " .. expanded_file_path .. ". Error: " .. (open_err or "Unknown"),
      vim.log.levels.ERROR
    )
    return nil
  end

  local content = f:read("*all")
  f:close()
  vim.notify(
    "MatugenColorscheme: File content read (first 50 chars): " .. content:sub(1, 50) .. (#content > 50 and "..." or ""),
    vim.log.levels.DEBUG
  )

  -- Remove JSONC comments before decoding
  local cleaned_content = content:gsub("//.-\n", "\n")
  vim.notify(
    "MatugenColorscheme: Cleaned content (first 50 chars): "
      .. cleaned_content:sub(1, 50)
      .. (#cleaned_content > 50 and "..." or ""),
    vim.log.levels.DEBUG
  )

  local ok, colors_or_err = pcall(vim.json.decode, cleaned_content)
  if not ok then
    vim.notify(
      "MatugenColorscheme: Error decoding JSON from " .. expanded_file_path .. ": " .. colors_or_err,
      vim.log.levels.ERROR
    )
    return nil
  end
  vim.notify("MatugenColorscheme: JSON decoded successfully.", vim.log.levels.DEBUG)

  return colors_or_err
end

--- Sets up the plugin with user configuration.
function M.setup(opts)
  if opts then
    if opts.transparent_background ~= nil then
      vim.notify(
        "MatugenColorscheme: 'transparent_background' option is deprecated and will be ignored.",
        vim.log.levels.WARN
      )
      opts.transparent_background = nil
    end
    if opts.background_style ~= nil then
      vim.notify(
        "MatugenColorscheme: 'background_style' option is deprecated and will be ignored.",
        vim.log.levels.WARN
      )
      opts.background_style = nil
    end
  end

  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  vim.notify("MatugenColorscheme: Configuration loaded. Color file: " .. M.config.file, vim.log.levels.INFO)

  -- Immediately apply colors after setup, as is common for colorschemes
  M.apply_colors()
end

--- Applies the Matugen colors to Neovim.
function M.apply_colors()
  local colors = read_colors(M.config.file)
  if not colors then
    vim.notify("MatugenColorscheme: Failed to read colors. No highlights applied.", vim.log.levels.ERROR)
    return
  end

  -- Clear all existing highlight groups to ensure a clean slate
  vim.cmd("highlight clear")
  -- Reset default Neovim highlight settings (important for new colorschemes)
  vim.cmd("syntax reset")

  -- Set the Normal background first
  if colors.background then
    set_hl("Normal", nil, colors.background)
  else
    vim.notify(
      "MatugenColorscheme: 'background' color not found in Matugen output. Normal background might be incorrect.",
      vim.log.levels.WARN
    )
  end

  -- Apply base highlights first
  local status_ok, base_module = pcall(require, get_highlight_module_path("base"))
  if status_ok and base_module and base_module.apply then
    vim.notify("MatugenColorscheme: Applying 'base' highlights.", vim.log.levels.INFO)
    base_module.apply(colors, M.config, set_hl)
  else
    vim.notify(
      string.format(
        "MatugenColorscheme: Failed to load or apply 'base' highlight module. Error: %s",
        tostring(base_module)
      ),
      vim.log.levels.ERROR
    )
  end

  -- Iterate through other enabled highlight modules (excluding base, treesitter, and lualine)
  for name, enabled in pairs(M.config.plugins) do
    if enabled and name ~= "base" and name ~= "treesitter" and name ~= "lualine" then -- Exclude these
      local status_ok, highlight_module = pcall(require, get_highlight_module_path(name))
      if status_ok and highlight_module and highlight_module.apply then
        vim.notify(string.format("MatugenColorscheme: Applying '%s' highlights.", name), vim.log.levels.INFO)
        highlight_module.apply(colors, M.config, set_hl)
      else
        vim.notify(
          string.format(
            "MatugenColorscheme: Failed to load or apply highlight module '%s'. Error: %s",
            name,
            tostring(highlight_module)
          ),
          vim.log.levels.WARN
        )
      end
    end
  end

  -- Handle Lualine highlights via an autocommand, if enabled
  if M.config.plugins.lualine then
    vim.api.nvim_create_autocmd("User", {
      pattern = "LualineReady", -- Lualine's signal that it's ready
      once = true, -- Ensure it runs only once per session per buffer
      callback = function()
        local ll_colors = read_colors(M.config.file) -- Re-read colors if necessary, or pass from outer scope
        if ll_colors then
          local status_ok, ll_module = pcall(require, get_highlight_module_path("lualine"))
          if status_ok and ll_module and ll_module.apply then
            vim.notify("MatugenColorscheme: Applying 'lualine' highlights via autocommand.", vim.log.levels.INFO)
            ll_module.apply(ll_colors, M.config, set_hl)
          else
            vim.notify(
              string.format(
                "MatugenColorscheme: Failed to load or apply 'lualine' highlight module during autocommand. Error: %s",
                tostring(ll_module)
              ),
              vim.log.levels.WARN
            )
          end
        end
      end,
    })
    -- If Lualine is already ready when this is called (e.g., after a theme switch in an already open session)
    -- check `vim.b.lualine_setup` which Lualine sets when it initializes in a buffer.
    if vim.b.lualine_setup then
      vim.cmd("doautocmd User LualineReady")
    end
  end

  -- Handle Treesitter highlights via an autocommand, if enabled
  if M.config.plugins.treesitter then
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "matugen_colorscheme", -- Trigger when your colorscheme is set
      callback = function()
        vim.api.nvim_create_autocmd("User", {
          pattern = "TreesitterHighlightsReady", -- This event is emitted by nvim-treesitter
          once = true, -- Ensure it runs only once per session
          callback = function()
            local ts_colors = read_colors(M.config.file) -- Re-read colors if necessary, or pass from outer scope
            if ts_colors then
              local status_ok, ts_module = pcall(require, get_highlight_module_path("treesitter"))
              if status_ok and ts_module and ts_module.apply then
                vim.notify("MatugenColorscheme: Applying 'treesitter' highlights via autocommand.", vim.log.levels.INFO)
                ts_module.apply(ts_colors, M.config, set_hl)
              else
                vim.notify(
                  string.format(
                    "MatugenColorscheme: Failed to load or apply 'treesitter' highlight module during autocommand. Error: %s",
                    tostring(ts_module)
                  ),
                  vim.log.levels.WARN
                )
              end
            end
          end,
        })
      end,
    })
    -- If the colorscheme is already active when this is run (e.g., from :MatugenColorschemeApply)
    -- and treesitter is ready, trigger it immediately.
    if vim.g.colors_name == "matugen_colorscheme" then
      vim.cmd("doautocmd User TreesitterHighlightsReady")
    end
  end

  vim.notify("MatugenColorscheme: All enabled highlights applied.", vim.log.levels.INFO)
end

-- Expose a user command for convenience
vim.api.nvim_create_user_command("MatugenColorschemeApply", M.apply_colors, {
  desc = "Apply colors from Matugen JSONC file",
})

return M
