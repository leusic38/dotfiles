local M = {}

local indent = 2
local g = vim.g
local cmd = vim.cmd
local opt = vim.opt
-- local o = vim.o
-- local wo = vim.wo
-- local bo = vim.bo
local options = {
	backup = false,                          -- creates a backup file
  clipboard = "unnamedplus",               -- allows neovim to access the system clipboard
  cmdheight = 2,                           -- more space in the neovim command line for displaying messages
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  conceallevel = 0,                        -- so that `` is visible in markdown files
  fileencoding = "utf-8",                  -- the encoding written to a file
  hlsearch = true,                         -- highlight all matches on previous search pattern
  ignorecase = true,                       -- ignore case in search patterns
  mouse = "a",                             -- allow the mouse to be used in neovim
  pumheight = 10,                          -- pop up menu height
  showmode = false,                        -- we don't need to see things like -- INSERT -- anymore
  showtabline = 2,                         -- always show tabs
  smartcase = true,                        -- smart case
  smartindent = true,                      -- make indenting smarter again
  splitbelow = true,                       -- force all horizontal splits to go below current window
  splitright = true,                       -- force all vertical splits to go to the right of current window
  swapfile = false,                        -- creates a swapfile
  -- termguicolors = true,                    -- set term gui colors (most terminals support this)
  timeoutlen = 1000,                        -- time to wait for a mapped sequence to complete (in milliseconds)
  undofile = true,                         -- enable persistent undo
  updatetime = 300,                        -- faster completion (4000ms default)
  writebackup = false,                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true,                        -- convert tabs to spaces
  shiftwidth = 2,                          -- the number of spaces inserted for each indentation
  tabstop = 2,                             -- insert 2 spaces for a tab
  cursorline = true,                       -- highlight the current line
  number = true,                           -- set numbered lines
  relativenumber = false,                  -- set relative numbered lines
  numberwidth = 4,                         -- set number column width to 2 {default 4}
  signcolumn = "yes",                      -- always show the sign column, otherwise it would shift the text each time
  wrap = false,                            -- display lines as one long line
  scrolloff = 8,                           -- is one of my fav
  sidescrolloff = 8,
  guifont = "monospace:h17",               -- the font used in graphical neovim applicationsi
}
function M.setup()
  cmd [[filetype plugin indent on]]
  cmd [[syntax enable]]

  vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
  g.mapleader = " "
  g.maplocalleader = ","
  opt.shortmess:append "c"
  
  for k, v in pairs(options) do
    opt[k] = v
  end
--  opt.autoindent = true
--  opt.breakindent = true
--  opt.clipboard = "unnamed,unnamedplus"
--  opt.cmdheight = 1
--  opt.cursorline = true
--  opt.expandtab = true
--  opt.hidden = true
--  opt.history = 100
--  opt.ignorecase = true
--  opt.inccommand = "split"
--  opt.lazyredraw = true
--  opt.mouse = "a"
--  opt.number = true
--  opt.pumblend = 17
--  opt.relativenumber = true
--  opt.scrolloff = 999
--  opt.scrolloff = 999
--  opt.sessionoptions = "blank,buffers,curdir,folds,help,options,tabpages,winsize,resize,winpos,terminal"
--  opt.shiftround = true
--  opt.shiftwidth = indent
--  opt.sidescrolloff = 999
--  opt.sidescrolloff = 999
--  opt.smartcase = true
--  opt.smartindent = true
--  opt.smarttab = true
--  opt.softtabstop = indent
--  opt.splitbelow = true
--  opt.splitright = true
--  opt.synmaxcol = 240
--  opt.tabstop = indent
--  opt.termguicolors = true
--  opt.timeoutlen = 300
--  opt.updatetime = 300
--  opt.path:append "**"

  -- opt.formatoptions:append "cqnj"
  -- opt.formatoptions:remove "ator2"

  opt.formatoptions = opt.formatoptions
    - "a" -- Auto formatting is BAD.
    - "t" -- Don't auto format my code. I got linters for that.
    + "c" -- In general, I like it when comments respect textwidth
    + "q" -- Allow formatting comments w/ gq
    - "o" -- O and o, don't continue comments
    - "r" -- Don't insert comment after <Enter>
    + "n" -- Indent past the formatlistpat, not underneath it.
    + "j" -- Auto-remove comments if possible.
    - "2" -- I'm not in gradeschool anymore

  -- g.virtualedit = "all"
  g.python3_host_prog = "~/miniconda3/bin/python3"
  g.vim_markdown_fenced_languages = { "html", "javascript", "typescript", "css", "python", "lua", "vim" }
end

M.setup()
