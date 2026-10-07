require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Copilot bindings
map("n", "<leader>cp", "<cmd>Copilot panel<CR>", { desc = "Open Copilot panel" })
map("n", "<leader>cc", "<cmd>CopilotChatToggle<CR>", { desc = "Toggle Copilot Chat" })
map("n", "<leader>cq", function()
  local input = vim.fn.input("Quick Chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end, { desc = "Copilot Quick Chat" })
map("v", "<leader>ce", "<cmd>CopilotChatExplain<CR>", { desc = "Explain selection" })
map("v", "<leader>cr", "<cmd>CopilotChatReview<CR>", { desc = "Review selection" })
map("v", "<leader>cf", "<cmd>CopilotChatFix<CR>", { desc = "Fix selection" })
map("v", "<leader>co", "<cmd>CopilotChatOptimize<CR>", { desc = "Optimize selection" })
map("v", "<leader>ct", "<cmd>CopilotChatTests<CR>", { desc = "Generate tests" })

-- React Native / TypeScript workflow
-- LSP mappings
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "LSP rename symbol" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
map("n", "gd", vim.lsp.buf.definition, { desc = "LSP go to definition" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP go to implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "LSP go to references" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
