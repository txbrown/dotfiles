-- Neovim 0.11+ native LSP config
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local servers = { "html", "cssls", "gopls", "sourcekit" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  vim.lsp.config[lsp] = {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- Enhanced TypeScript/TSX config for React Native
vim.lsp.config.ts_ls = {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
  },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "tsx", "jsx" },
}

-- Enable configured servers
vim.lsp.enable(servers)
vim.lsp.enable("ts_ls")
