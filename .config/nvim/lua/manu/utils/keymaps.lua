-- my custom keymaps
-- https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/ for help


local default_opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, expr = true, silent = true }
local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Use space as leader key
keymap("", "<Space>", "<Nop>", default_opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes for 
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   select mode = "s"
--   terminal_mode = "t",
--   command_mode = "c",
--   insert and command_mode = "!",

-- C for ControlKey
-- S for ShiftKey
-- A fo AltKey
-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", default_opts)
keymap("n", "<C-j>", "<C-w>j", default_opts)
keymap("n", "<C-k>", "<C-w>k", default_opts)
keymap("n", "<C-l>", "<C-w>l", default_opts)

-- Resize windows with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", default_opts)
keymap("n", "<C-Down>", ":resize -2<CR>", default_opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", default_opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", default_opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", default_opts)
keymap("n", "<S-h>", ":bprevious<CR>", default_opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", default_opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", default_opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", default_opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", default_opts)
keymap("v", ">", ">gv", default_opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", default_opts)
keymap("v", "<A-k>", ":m .-2<CR>==", default_opts)
keymap("v", "p", '"_dP', default_opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", default_opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", default_opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", default_opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", default_opts)


-- Tree keymap
keymap("n", "<C-n>",":NvimTreeToggle<CR>", default_opts)

-- Refactoring keymap
keymap("v","<leader>rr","<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>", default_opts)