local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettierd" },
    html = { "prettierd" },
    ts = { "prettierd" },
    tsx = { "prettierd" },
    js = { "prettierd" },
    jsx = { "prettierd" },
    json = { "prettierd" },
    swift = { "swiftformat" },
    cpp = { "clang-format" },
    c = { "clang-format" },
  },

  formatters = {
    ["clang-format"] = {
      prepend_args = { "--style=file" },
    },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

require("conform").setup(options)
