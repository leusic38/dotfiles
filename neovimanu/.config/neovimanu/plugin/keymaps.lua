local keymap = vim.keymap.set
-- Move to window using the <ctrl> hjkl keys
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
-- New tab
keymap("n", "te", ":tabedit", {desc=""})
keymap("n", "<tab>", ":tabnext<Return>", {desc=""})
keymap("n", "<s-tab>", ":tabprev<Return>",{desc=""})
-- Split window
keymap("n", "ss", ":split<Return>", {desc=""})
keymap("n", "sv", ":vsplit<Return>", {desc=""})
-- Move window
keymap("n", "sh", "<C-w>h", {desc=""})
keymap("n", "sk", "<C-w>k", {desc=""})
keymap("n", "sj", "<C-w>j", {desc=""})
keymap("n", "sl", "<C-w>l", {desc=""})

-- Resize window
keymap("n", "<C-w><left>", "<C-w><", {desc=""})
keymap("n", "<C-w><right>", "<C-w>>", {desc=""})
keymap("n", "<C-w><up>", "<C-w>+", {desc=""})
keymap("n", "<C-w><down>", "<C-w>-", {desc=""})

-- Move Lines
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Better indent
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Paste over currently selected text without yanking it
keymap("v", "p", '"_dp')

keymap("n", "<CR>", "o<ESC>")
keymap("n", "<S-Enter>", "O<ESC>")
keymap("n", "<C-a>", "gg<S-v>G")
-- Diagnostic
keymap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
keymap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
keymap('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
keymap('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- lazy
keymap("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy" })
keymap("n", "<leader>lu", "<cmd>Lazy update<cr>", { desc = "Lazy update" })
