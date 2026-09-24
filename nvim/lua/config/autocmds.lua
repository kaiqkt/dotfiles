-- LazyVim provides the default autocommands. Add local autocommands here.
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("wallpaper_theme", { clear = true }),
  callback = function()
    require("config.theme").reload()
  end,
})

vim.api.nvim_create_user_command("ThemeReload", function()
  require("config.theme").setup()
end, { desc = "Reload the generated wallpaper palette", force = true })
