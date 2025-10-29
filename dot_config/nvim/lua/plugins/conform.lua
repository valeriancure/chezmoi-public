return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      -- for language support
      -- @see https://biomejs.dev/internals/language-support/
      formatters_by_ft = {
        -- ["javascript"] = { "biome" },
        -- ["javascriptreact"] = { "biome" },
        -- ["typescript"] = { "biome" },
        -- ["typescriptreact"] = { "biome" },
        -- ["json"] = { "biome" },
        -- ["jsonc"] = { "biome" },
        ["vue"] = { "biome", "dprint" },
        -- ["css"] = { "biome" },
        -- ["scss"] = { "biome" },
        -- ["less"] = { "biome" },
        ["html"] = { "dprint" },
        ["astro"] = { "biome", "dprint" },
      },
    },
  },
}
