return {
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
		config = true,
	},
	{
		"NeogitOrg/neogit",
		cmd = "Neogit",
		opts = {
			integrations = { diffview = true },
			disable_commit_confirmation = true,
		},
		keys = {
			{ "<leader>gs", "<cmd>Neogit kind=tab<cr>", desc = "Status" },
		},
	},
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "GBrowse", "Gdiffsplit", "Gvdiffsplit" },
		dependencies = {
			"tpope/vim-rhubarb",
		},
	},
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Jump to next hunk" })

				map({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Jump to previous hunk" })

				-- Actions
				-- visual mode
				map("v", "<leader>ghs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "stage git hunk" })
				map("v", "<leader>ghr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "reset git hunk" })
				-- normal mode
				map("n", "<leader>ghs", gs.stage_hunk, { desc = "git stage hunk" })
				map("n", "<leader>ghr", gs.reset_hunk, { desc = "git reset hunk" })
				map("n", "<leader>ghS", gs.stage_buffer, { desc = "git Stage buffer" })
				map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
				map("n", "<leader>ghR", gs.reset_buffer, { desc = "git Reset buffer" })
				map("n", "<leader>ghp", gs.preview_hunk, { desc = "preview git hunk" })
				map("n", "<leader>ghb", function()
					gs.blame_line({ full = false })
				end, { desc = "git blame line" })
				map("n", "<leader>ghd", gs.diffthis, { desc = "git diff against index" })
				map("n", "<leader>ghD", function()
					gs.diffthis("~")
				end, { desc = "git diff against last commit" })

				-- Toggles
				map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
				map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

				-- Text object
				map({ "o", "x" }, "gih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
			end,
		},
	},
	{
		"aaronhallaert/advanced-git-search.nvim",
		config = function()
			require("telescope").load_extension("advanced_git_search")
		end,
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"tpope/vim-fugitive",
		},
	},
	{
		"ThePrimeagen/git-worktree.nvim",
		opts = {},
		config = function()
			require("telescope").load_extension("git_worktree")
		end,
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
    --stylua: ignore
    keys = {
      {"<leader>gwm", function() require("telescope").extensions.git_worktree.git_worktrees() end, desc = "Manage"},
      {"<leader>gwc", function() require("telescope").extensions.git_worktree.create_git_worktree() end, desc = "Create"},
    },
	},
	{
		"akinsho/git-conflict.nvim",
    --stylua: ignore
    keys = {
      {"<leader>gC", function() require("plugins.hydra.git-action").open_git_conflict_hydra() end, desc = "Conflict"},
      {"<leader>gS", function() require("plugins.hydra.git-action").open_git_signs_hydra() end, desc = "Signs"},
    },
		cmd = {
			"GitConflictChooseBoth",
			"GitConflictNextConflict",
			"GitConflictChooseOurs",
			"GitConflictPrevConflict",
			"GitConflictChooseTheirs",
			"GitConflictListQf",
			"GitConflictChooseNone",
			"GitConflictRefresh",
		},
		opts = {
			default_mappings = true,
			default_commands = true,
			disable_diagnostics = true,
		},
	},
}