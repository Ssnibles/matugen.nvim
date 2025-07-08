-- ~/projects/matugen.nvim/lua/matugen_colorscheme/init.lua

local M = {}

-- User configuration (defaults)
M.config = {
  -- This path should point to the Matugen-generated Lua file in your nvim config
  colorscheme_file = vim.fn.stdpath("config") .. "/lua/matugen_colors/init.lua",
  -- You can add other configurations here if needed, e.g., default image path for Matugen
}

---Loads the Matugen-generated colorscheme.
function M.load_matugen_colorscheme()
  local colorscheme_path = M.config.colorscheme_file

  if vim.fn.filereadable(colorscheme_path) == 0 then
    vim.notify("Matugen colorscheme file not found: " .. colorscheme_path, vim.log.levels.ERROR)
    vim.notify(
      "Please generate the colorscheme first using Matugen. Run: matugen generate -i /path/to/your/image.jpg -t /path/to/your/matugen_nvim_template.lua -o "
        .. colorscheme_path,
      vim.log.levels.INFO
    )
    return
  end

  -- Load the generated Lua module
  -- It's important to clear package.loaded cache if you regenerate colors while Neovim is running
  package.loaded["matugen_colors"] = nil
  local status_ok, matugen_colors = pcall(require, "matugen_colors")

  if not status_ok then
    vim.notify("Error loading Matugen colors module: " .. matugen_colors, vim.log.levels.ERROR)
    return
  end

  if matugen_colors and type(matugen_colors.apply_highlights) == "function" then
    matugen_colors.apply_highlights()
    vim.cmd("colorscheme matugen_colors") -- Set the colorscheme name for display
    vim.notify("Matugen colorscheme loaded successfully!", vim.log.levels.INFO)
  else
    vim.notify("Failed to apply Matugen highlights. Check your Matugen template output.", vim.log.levels.ERROR)
  end
end

---Setup function for the plugin.
---@param opts table User configuration options.
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Define a user command to load the colorscheme
  vim.api.nvim_create_user_command("MatugenColorschemeLoad", function()
    M.load_matugen_colorscheme()
  end, {
    desc = "Load the Matugen-generated colorscheme",
  })

  -- Auto-load on VimEnter (optional, but good for initial setup)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("MatugenColorschemeAutoLoad", { clear = true }),
    callback = function()
      M.load_matugen_colorscheme()
    end,
  })
end

return M
