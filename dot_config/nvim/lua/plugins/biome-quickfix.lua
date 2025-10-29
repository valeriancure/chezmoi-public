return {

  {
    "AlexBeauchemin/biome-lint.nvim",
    dir = "~/work/opensource/biome-lint.nvim",
    opts = {
      severity = "warn", -- "error", "warn", "info". Default is "error"
    },
    keys = {
      {
        "<leader>cb",
        "<cmd>BiomeLint<cr>",
        desc = "Run Biome Check",
      },
    },
  },
}
