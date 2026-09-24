local fallback = {
  base00 = "#1c1c1c",
  base01 = "#2a2a2a",
  base02 = "#353535",
  base03 = "#919191",
  base04 = "#c7c7c7",
  base05 = "#e2e2e2",
  base06 = "#f0f0f0",
  base07 = "#fcfcfc",
  base08 = "#ffb1c1",
  base09 = "#ffb598",
  base0A = "#cfca74",
  base0B = "#91d5ad",
  base0C = "#82d3e2",
  base0D = "#a6c8ff",
  base0E = "#dbb9f9",
  base0F = "#9ccbfb",
}

local M = {}
local last_modified

local function modified()
  local stat = (vim.uv or vim.loop).fs_stat(vim.fn.stdpath("config") .. "/lua/config/generated_theme.lua")
  return stat and (stat.mtime.sec .. ":" .. stat.mtime.nsec) or nil
end

function M.setup()
  package.loaded["config.generated_theme"] = nil
  local ok, colors = pcall(require, "config.generated_theme")
  colors = ok and colors or fallback
  require("base16-colorscheme").setup(colors)
  -- base0F belongs to UI chrome; keep punctuation neutral and escapes semantic.
  for _, group in ipairs({ "Delimiter", "@punctuation.delimiter", "@punctuation.bracket", "@tag.delimiter" }) do
    vim.api.nvim_set_hl(0, group, { fg = colors.base05 })
  end
  for _, group in ipairs({ "SpecialChar", "@punctuation.special", "@string.escape" }) do
    vim.api.nvim_set_hl(0, group, { fg = colors.base0C })
  end
  vim.api.nvim_set_hl(0, "@attribute", { fg = colors.base0E })
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = colors.base0F })
  last_modified = modified()
end

function M.reload()
  if modified() ~= last_modified then
    M.setup()
  end
end

return M
