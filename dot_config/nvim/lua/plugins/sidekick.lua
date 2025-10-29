return {
  "folke/sidekick.nvim",
  opts = {
    cli = {
      win = {
        keys = {
          -- override the default hide keymap
          win_n = { "<c-Space>", "blur", mode = "t" },
          -- add a new keymap to say hi
          -- say_hi = {
          --   "<c-h>",
          --   function(t)
          --     t:send("hi!")
          --   end,
          -- },
        },
      },
      mux = {
        enabled = true,
        backend = "tmux", -- or "zellij"
      },
      prompts = {
        refactor = "Please refactor {this} to be more maintainable",
        security = "Review {file} for security vulnerabilities",
        custom = function(ctx)
          return "Current file: " .. ctx.buf .. " at line " .. ctx.row
        end,
      },
    },
  },
}
