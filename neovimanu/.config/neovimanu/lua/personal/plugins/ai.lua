return {
	{
		"Exafunction/codeium.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({})
			vim.keymap.set("i", "<C-g>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true, silent = true, desc = "Accepter la suggestion Codeium" })
			vim.keymap.set("i", "<C-n>", function()
				return vim.fn
			end, { expr = true, silent = true, desc = "Prochaine suggestion Codeium" })
			vim.keymap.set("i", "<C-p>", function()
				return vim.fn["codeium#CycleCompletions"](-1)
			end, { expr = true, silent = true, desc = "Suggestion précédente Codeium" })
			vim.keymap.set("i", "<C-x>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true, silent = true, desc = "Effacer la suggestion Codeium" })
		end,
	},
}
