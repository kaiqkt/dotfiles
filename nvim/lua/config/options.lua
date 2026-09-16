-- LazyVim loads its default options before plugin startup. Keep only local
-- overrides here.
local rustup_bin = "/opt/homebrew/opt/rustup/bin"
local path = vim.split(vim.env.PATH or "", ":", { plain = true })

if vim.fn.isdirectory(rustup_bin) == 1 and not vim.tbl_contains(path, rustup_bin) then
  table.insert(path, 1, rustup_bin)
  vim.env.PATH = table.concat(path, ":")
end

vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.g.markdown_recommended_style = 0
