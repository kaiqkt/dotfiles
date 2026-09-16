return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("config.theme").setup()
      end,
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "gofumpt",
        "goimports",
        "google-java-format",
        "ktlint",
        "shfmt",
        "stylua",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
        java = { "google-java-format" },
        kotlin = { "ktlint" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        zsh = { "shfmt" },
      },
    },
  },
}
