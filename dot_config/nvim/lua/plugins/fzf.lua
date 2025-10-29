return {
  "ibhagwan/fzf-lua",
  opts = {
    fzf_opts = {
      ["--history"] = vim.fn.stdpath("data") .. "/fzf-history",
    },
  },
}
