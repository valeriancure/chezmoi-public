-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

vim.keymap.set("n", "n", "nzz", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>yp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p:."))
end, { noremap = true, silent = true, desc = "Copy file [p]ath" })

vim.keymap.set("n", "<leader>yd", function()
  vim.fn.setreg("+", vim.fn.expand("%:h"))
end, { noremap = true, silent = true, desc = "Copy [d]irectory path" })

vim.keymap.set("n", "<leader>yn", function()
  vim.fn.setreg("+", vim.fn.expand("%:t"))
end, { noremap = true, silent = true, desc = "Copy file [n]ame" })

vim.keymap.set("n", "<leader>gco", "<Plug>(git-conflict-ours)")
vim.keymap.set("n", "<leader>gct", "<Plug>(git-conflict-theirs)")
vim.keymap.set("n", "<leader>gcb", "<Plug>(git-conflict-both)")
vim.keymap.set("n", "<leader>gc0", "<Plug>(git-conflict-none)")
vim.keymap.set("n", "<leader>gc[", "<Plug>(git-conflict-prev-conflict)")
vim.keymap.set("n", "<leader>gc]", "<Plug>(git-conflict-next-conflict)")

-- AI : alt-q should go to previous quickfix item,  shift-q to the next quickfix item
vim.keymap.set("n", "<M-q>", "<cmd>cprev<cr>zz", { noremap = true, silent = true, desc = "Previous Quickfix Item" })
vim.keymap.set("n", "<S-q>", "<cmd>cnext<cr>zz", { noremap = true, silent = true, desc = "Next Quickfix Item" })

-- ALT+P → fuzzy path completion depuis la racine projet
vim.keymap.set("i", "<M-p>", function()
  require("fzf-lua").complete_path({
    cwd = require("lazyvim.util").root.get(),
    fd_opts = [[--color=never --type f --type d --hidden --follow --exclude .git]],
  })
end, { silent = true, desc = "Fuzzy path completion (project root)" })

-- -- utils: robust relative path (handles ../ properly)
-- local function split(p)
--   local t = {}
--   for s in p:gsub("^/*", ""):gmatch("[^/]+") do
--     t[#t + 1] = s
--   end
--   return t
-- end
--
-- local function relative_path(abs, from)
--   abs = vim.fs.normalize(abs)
--   from = vim.fs.normalize(from)
--   if abs:sub(1, 1) ~= "/" or from:sub(1, 1) ~= "/" then
--     return abs
--   end
--
--   local A, B = split(abs), split(from)
--   local i = 1
--   while i <= math.min(#A, #B) and A[i] == B[i] do
--     i = i + 1
--   end
--   local ups = {}
--   for _ = i, #B do
--     ups[#ups + 1] = ".."
--   end
--   local downs = {}
--   for j = i, #A do
--     downs[#downs + 1] = A[j]
--   end
--   local rel = table.concat(vim.list_extend(ups, downs), "/")
--   if rel == "" then
--     rel = "."
--   end
--   return rel
-- end
--
-- vim.keymap.set("i", "<M-r>", function()
--   local fzf = require("fzf-lua")
--   local path = require("fzf-lua.path")
--   local root = require("lazyvim.util").root.get()
--   local bufdir = vim.fn.expand("%:p:h")
--
--   fzf.files({
--     cwd = root,
--     file_icons = false,
--     fd_opts = [[--color=never --hidden --type f --type l --follow --exclude .git]],
--     complete = function(selected, opts, line, col)
--       local s = selected and selected[1]
--       if not s then
--         return line, col
--       end
--       local e = path.entry_to_file(s, opts) or {}
--       local abs = e.path or s
--       if abs:sub(1, 1) ~= "/" then
--         abs = vim.fs.joinpath(root, abs)
--       end
--       abs = vim.fs.normalize(abs)
--
--       -- stay inside project root
--       local norm_root = vim.fs.normalize(root)
--       if abs:sub(1, #norm_root) ~= norm_root then
--         return line, col
--       end
--
--       local rel = relative_path(abs, bufdir)
--       if rel:sub(1, 1) ~= "." then
--         rel = "./" .. rel
--       end
--
--       local left, right = line:sub(1, col), line:sub(col + 1)
--       local newline = left .. rel .. right
--       return newline, #left + #rel
--     end,
--   })
-- end, { silent = true, desc = "Fuzzy pick → insert path (relative to buffer)" })

-- <M-r>: FZF pick → insert buffer-relative path
-- ───────────────────────────────────────────────────────────────
-- Spec summary:
-- • Opens fzf-lua file picker from insert mode.
-- • Inserts the selected file path relative to the current buffer.
-- • Automatically decides starting directory:
--     - Token starts with './' → start in buffer directory.
--     - Token starts with '../' → start in project/git root.
--     - Else → start in project/git root.
-- • Alt-C toggles base between root ↔ buffer directory.
-- • Token before cursor is used as initial fuzzy query.
-- • Strips leading './' or '../' for search.
-- • Gracefully handles empty query (no crash, popup still opens).
-- • Detects unclosed quotes before cursor and auto-adds a closing one.
-- • Works cleanly in insert mode (no mode switching).
-- • No dependency on cmp or telescope; pure fzf-lua.
-- • Compatible with LazyVim util.root.git()/get().

vim.keymap.set("i", "<M-r>", function()
  local fzf = require("fzf-lua")
  local path = require("fzf-lua.path")
  local util = require("lazyvim.util")
  local root = util.root.git() or util.root.get()
  local bufdir = vim.fn.expand("%:p:h")

  local function split(p)
    local t = {}
    for s in vim.fs.normalize(p):gmatch("[^/]+") do
      t[#t + 1] = s
    end
    return t
  end

  local function rel_from(abs, from)
    abs, from = vim.fs.normalize(abs), vim.fs.normalize(from)
    local A, B = split(abs), split(from)
    local i = 1
    while i <= math.min(#A, #B) and A[i] == B[i] do
      i = i + 1
    end
    local ups, downs = {}, {}
    for _ = i, #B do
      ups[#ups + 1] = ".."
    end
    for j = i, #A do
      downs[#downs + 1] = A[j]
    end
    local rel = table.concat(vim.list_extend(ups, downs), "/")
    return rel == "" and "." or rel
  end

  local function strip_rel_prefix(s)
    local r = s
    while true do
      if r:sub(1, 2) == "./" then
        r = r:sub(3)
      elseif r:sub(1, 3) == "../" then
        r = r:sub(4)
      else
        break
      end
    end
    return r
  end

  local function has_open_quote(b, a)
    local open = b:match("[\"']%s*[^\"']*$")
    local close = a:match("^[^\"']*[\"']")
    if open and not close then
      return open:sub(1, 1)
    end
    return nil
  end

  local col = vim.fn.col(".")
  local line = vim.fn.getline(".")
  local before, after = line:sub(1, col - 1), line:sub(col)
  local token = before:match("([%w%._%-%/%~]+)$") or ""
  local token_start = #before - #token + 1

  local starts_dot = token:sub(1, 2) == "./"
  local starts_dotdot = token:sub(1, 3) == "../"

  -- rule: './' → bufdir ; '../' → root ; else → root
  local use_root = not starts_dot
  local base_query = strip_rel_prefix(token)

  local function open_picker()
    local cwd = use_root and root or bufdir

    local opts = {
      cwd = cwd,
      file_icons = false,
      fd_opts = [[--color=never --hidden --type f --type l --follow --exclude .git]],
      actions = {
        ["default"] = function(sel)
          local s = sel and sel[1]
          if not s then
            return
          end

          local e = path.entry_to_file(s, { cwd = cwd }) or {}
          local abs = e.path or s
          if abs:sub(1, 1) ~= "/" then
            abs = vim.fs.joinpath(cwd, abs)
          end
          abs = vim.fs.normalize(abs)

          local rel = rel_from(abs, bufdir)
          if rel:sub(1, 1) ~= "." then
            rel = "./" .. rel
          end

          local quote = has_open_quote(before, after)
          local left = line:sub(1, token_start - 1)
          local newline = left .. rel .. (quote or "") .. after
          local newcol = #left + #rel + (quote and 1 or 0)

          vim.api.nvim_set_current_line(newline)
          vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), newcol })
        end,
        ["alt-c"] = function()
          use_root = not use_root
          open_picker()
        end,
      },
    }

    -- only set --query when non-empty to avoid fzf "unknown option" errors
    if base_query ~= "" then
      opts.fzf_opts = { ["--query"] = base_query }
    end

    fzf.files(opts)
  end

  open_picker()
end, {
  silent = true,
  desc = "FZF pick → insert path (smart ./../, safe empty, auto-quote, Alt-C toggle)",
})
