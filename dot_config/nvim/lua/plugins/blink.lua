return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "mikavilpas/blink-ripgrep.nvim",
      -- 👆🏻👆🏻 add the dependency here
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- completion = {
      --   -- menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } } } },
      --   -- menu = { draw = { columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } } } },
      --   menu = { auto_show = true },
      -- },
      sources = {
        default = {
          -- "copilot",
          -- "lsp",
          -- "buffer",
          "ripgrep", -- 👈🏻 add "ripgrep" here
        },
        providers = {
          -- copilot = {
          --   name = "copilot",
          --   module = "blink-copilot",
          --   score_offset = 100,
          --   async = true,
          --   opts = {
          --     -- Local options override global ones
          --     max_completions = 3,
          --     max_attempts = 4,
          --   },
          -- },
          -- 👇🏻👇🏻 add the ripgrep provider config below
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            -- the options below are optional, some default values are shown
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              -- the minimum length of the current word to start searching
              -- (if the word is shorter than this, the search will not start)
              prefix_min_len = 3,

              -- Specifies how to find the root of the project where the ripgrep
              -- search will start from. Accepts the same options as the marker
              -- given to `:h vim.fs.root()` which offers many possibilities for
              -- configuration. If none can be found, defaults to Neovim's cwd.
              --
              -- Examples:
              -- - ".git" (default)
              -- - { ".git", "package.json", ".root" }
              project_root_marker = ".git",

              -- When a result is found for a file whose filetype does not have a
              -- treesitter parser installed, fall back to regex based highlighting
              -- that is bundled in Neovim.
              fallback_to_regex_highlighting = true,

              -- Keymaps to toggle features on/off. This can be used to alter
              -- the behavior of the plugin without restarting Neovim. Nothing
              -- is enabled by default. Requires folke/snacks.nvim.
              toggles = {
                -- The keymap to toggle the plugin on and off from blink
                -- completion results. Example: "<leader>tg" ("toggle grep")
                on_off = nil,

                -- The keymap to toggle debug mode on/off. Example: "<leader>td" ("toggle debug")
                debug = nil,
              },

              backend = {
                -- The backend to use for searching. Defaults to "ripgrep".
                -- Available options:
                -- - "ripgrep", always use ripgrep
                -- - "gitgrep", always use git grep
                -- - "gitgrep-or-ripgrep", use git grep if possible, otherwise
                --   use ripgrep. Uses the same options as the gitgrep backend
                use = "ripgrep",

                -- Whether to set up custom highlight-groups for the icons used
                -- in the completion items. Defaults to `true`, which means this
                -- is enabled.
                customize_icon_highlight = true,

                ripgrep = {
                  -- For many options, see `rg --help` for an exact description of
                  -- the values that ripgrep expects.

                  -- The number of lines to show around each match in the preview
                  -- (documentation) window. For example, 5 means to show 5 lines
                  -- before, then the match, and another 5 lines after the match.
                  context_size = 5,

                  -- The maximum file size of a file that ripgrep should include
                  -- in its search. Useful when your project contains large files
                  -- that might cause performance issues.
                  -- Examples:
                  -- "1024" (bytes by default), "200K", "1M", "1G", which will
                  -- exclude files larger than that size.
                  max_filesize = "1M",

                  -- Enable fallback to neovim cwd if project_root_marker is not
                  -- found. Default: `true`, which means to use the cwd.
                  project_root_fallback = true,

                  -- The casing to use for the search in a format that ripgrep
                  -- accepts. Defaults to "--ignore-case". See `rg --help` for
                  -- all the available options ripgrep supports, but you can try
                  -- "--case-sensitive" or "--smart-case".
                  search_casing = "--ignore-case",

                  -- (advanced) Any additional options you want to give to
                  -- ripgrep. See `rg -h` for a list of all available options.
                  -- Might be helpful in adjusting performance in specific
                  -- situations. If you have an idea for a default, please open
                  -- an issue!
                  --
                  -- Not everything will work (obviously).
                  additional_rg_options = {},

                  -- Absolute root paths where the rg command will not be
                  -- executed. Usually you want to exclude paths using gitignore
                  -- files or ripgrep specific ignore files, but this can be used
                  -- to only ignore the paths in blink-ripgrep.nvim, maintaining
                  -- the ability to use ripgrep for those paths on the command
                  -- line. If you need to find out where the searches are
                  -- executed, enable `debug` and look at `:messages`.
                  ignore_paths = {},

                  -- Any additional paths to search in, in addition to the
                  -- project root. This can be useful if you want to include
                  -- dictionary files (/usr/share/dict/words), framework
                  -- documentation, or any other reference material that is not
                  -- available within the project root.
                  additional_paths = {},
                },
              },

              gitgrep = {
                -- no options are currently available
              },

              -- Show debug information in `:messages` that can help in
              -- diagnosing issues with the plugin.
              debug = false,
            },
            -- (optional) customize how the results are displayed. Many options
            -- are available - make sure your lua LSP is set up so you get
            -- autocompletion help
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                -- example: append a description to easily distinguish rg results
                item.labelDetails = {
                  description = "(rg)",
                }
              end
              return items
            end,
          },
        },
      },

      completion = { list = { selection = { preselect = false, auto_insert = false } } },

      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-y>"] = { "accept", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        -- ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        -- ["<C-e>"] = { "hide", "fallback" },
        --
        -- ["<Tab>"] = {
        --   function(cmp)
        --     if cmp.snippet_active() then
        --       return cmp.accept()
        --     else
        --       return cmp.select_and_accept()
        --     end
        --   end,
        --   "snippet_forward",
        --   "fallback",
        -- },
        -- ["<S-Tab>"] = { "snippet_backward", "fallback" },
        --
        -- ["<Up>"] = { "select_prev", "fallback" },
        -- ["<Down>"] = { "select_next", "fallback" },
        -- ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        -- ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        --
        -- ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        -- ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        --
        -- ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        --
        -- preset = "super-tab",
        --
        -- ["<Tab>"] = {
        --   LazyVim.cmp.map({ "snippet_forward", "ai_accept" }),
        --   "fallback",
        -- },
        -- ["<Tab>"] = {
        --   function(cmp)
        --     if cmp.snippet_active() then
        --       return cmp.accept()
        --     else
        --       return cmp.select_and_accept()
        --     end
        --   end,
        --   "snippet_forward",
        --   "fallback",
        -- },
        -- -- 👇🏻👇🏻 (optional) add a keymap to invoke the search manually
        -- ["<C-M>"] = {
        --   function()
        --     -- invoke manually, requires blink >v0.8.0
        --     require("blink-cmp").show({ providers = { "ripgrep" } })
        --   end,
        -- },
      },
    },
  },
}
