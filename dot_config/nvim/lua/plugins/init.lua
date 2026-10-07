return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require "configs.conform"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        "prettierd",
        "mdx-analyzer",
        "typescript-language-server",
        "gopls",
        "swiftlint",
        "clangd",
        "ts_ls",
        "sourcekit",
        "clang-format",
        "codelldb",
        "eslint_d",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "jsx",
        "json",
        "gitignore",
        "go",
        "graphql",
        "http",
        "c",
        "zig",
        "swift",
        "cpp",
        "markdown",
        "markdown_inline",
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
  },
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-tree.lua", -- (optional) to manage project files
      "stevearc/oil.nvim", -- (optional) to manage project files
      "nvim-treesitter/nvim-treesitter", -- (optional) for Quick tests support (required Swift parser)
    },
    config = function()
      require("xcodebuild").setup {
        -- put some options here or leave it empty to use default settings
      }
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "wojciech-kulik/xcodebuild.nvim",
    },
    config = function()
      local xcodebuild = require "xcodebuild.integrations.dap"
      require "nvchad.mappings"

      local codelldbPath = vim.fn.exepath "codelldb"
      if codelldbPath == "" then
        codelldbPath = vim.fn.stdpath "data" .. "/mason/bin/codelldb"
      end

      if vim.fn.executable(codelldbPath) == 1 then
        xcodebuild.setup(codelldbPath)
      else
        vim.notify("codelldb not found; Xcode debugging disabled", vim.log.levels.WARN)
      end

      vim.keymap.set("n", "<leader>dd", xcodebuild.build_and_debug, { desc = "Build & Debug" })
      vim.keymap.set("n", "<leader>dr", xcodebuild.debug_without_build, { desc = "Debug Without Building" })
      vim.keymap.set("n", "<leader>dt", xcodebuild.debug_tests, { desc = "Debug Tests" })
      vim.keymap.set("n", "<leader>dT", xcodebuild.debug_class_tests, { desc = "Debug Class Tests" })
      vim.keymap.set("n", "<leader>b", xcodebuild.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>B", xcodebuild.toggle_message_breakpoint, { desc = "Toggle Message Breakpoint" })
      vim.keymap.set("n", "<leader>dx", xcodebuild.terminate_session, { desc = "Terminate Debugger" })
    end,
  },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    event = "VeryLazy",
    opts = {
      model = "claude-opus-4.5",
      auto_insert_mode = true,
      window = {
        layout = "vertical",
        width = 0.4,
      },
      chat_autocomplete = true,
      highlight_headers = true,
      separator = "───",
      show_folds = true,
      headers = {
        user = "👤 You",
        assistant = "🤖 Copilot",
        tool = "🔧 Tool",
      },
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)
      -- Enable treesitter highlighting for CopilotChat buffers
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        tsx = { "eslint_d" },
        jsx = { "eslint_d" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
