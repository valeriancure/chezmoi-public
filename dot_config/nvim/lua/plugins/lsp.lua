return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        vue_ls = {
          settings = {
            css = {
              validate = true,
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },
        vtsls = {
          -- settings = {
          --   typescript = {
          --     tsserver = {
          --       maxTsServerMemory = 8192,
          --     },
          --   },
          -- },
          settings = {
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                maxInlayHintLength = 30,
                completion = {
                  -- enableServerSideFuzzyMatch = true,
                  -- entriesLimit = 500,
                },
              },
            },
            typescript = {
              -- disableAutomaticTypeAcquisition = true,
              tsserver = {
                -- maxTsServerMemory = 8192,
                maxTsServerMemory = 12288,
                -- maxTsServerMemory = 16384,
                -- useSyntaxServer = "auto",
              },
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = false,
                -- enabled = false,
                -- autoImports = false,
                -- names = false,
                -- classMemberSnippets = { enabled = false },
                -- objectLiteralMethodSnippets = { enabled = false },
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
              preferences = {
                -- includePackageJsonAutoImports = "off",
              },
            },
          },
          -- root_dir = require("lspconfig").util.root_pattern("tsconfig.json"),
        },
      },
    },
  },
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = function(_, opts)
  --     local plugins = opts.servers.vtsls.settings.vtsls.tsserver.globalPlugins
  --     opts.servers.vtsls.settings.vtsls.tsserver.globalPlugins = vim.tbl_filter(function(plugin)
  --       return plugin.name ~= "@astrojs/ts-plugin" and plugin.name ~= "@vue/typescript-plugin"
  --     end, plugins)
  --   end,
  -- },
}
