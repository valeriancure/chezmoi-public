-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.env.TMUX then
  local osc52 = require("vim.ui.clipboard.osc52")

  local function tmux_paste()
    local previous = vim.fn.systemlist({ "tmux", "list-buffers", "-F", "#{buffer_name}" })[1]

    vim.fn.system({ "tmux", "refresh-client", "-l" })
    if vim.v.shell_error ~= 0 then
      return { {}, "v" }
    end

    local buffer
    vim.wait(1500, function()
      buffer = vim.fn.systemlist({ "tmux", "list-buffers", "-F", "#{buffer_name}" })[1]
      return buffer ~= nil and buffer ~= "" and buffer ~= previous
    end, 50)

    if buffer == nil or buffer == "" or buffer == previous then
      return { {}, "v" }
    end

    local text = vim.fn.system({ "tmux", "save-buffer", "-b", buffer, "-" })
    if vim.v.shell_error ~= 0 then
      return { {}, "v" }
    end

    local regtype = text:sub(-1) == "\n" and "V" or "v"
    local lines = vim.split(text, "\n", { plain = true })
    if lines[#lines] == "" then
      table.remove(lines)
    end

    return { lines, regtype }
  end

  vim.g.clipboard = {
    name = "tmux-osc52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = tmux_paste,
      ["*"] = tmux_paste,
    },
  }
elseif vim.env.TERM == "xterm-kitty" or vim.env.KITTY_WINDOW_ID then
  vim.g.clipboard = "osc52"
end

if vim.env.TERM == "xterm-kitty" or vim.env.KITTY_WINDOW_ID or vim.env.TMUX then
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      vim.schedule(function()
        vim.opt.clipboard = "unnamedplus"
      end)
    end,
  })
end
