return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = function(_, keys)
			local function toggleterm()
				local venv = vim.b["virtual_env"]
				local term = require("toggleterm.terminal").Terminal:new({
					env = venv and { VIRTUAL_ENV = venv } or nil,
					count = vim.v.count > 0 and vim.v.count or 1,
				})
				term:toggle()
			end
			local mappings = {
				{ "<leader>tt", mode = { "n", "t" }, toggleterm, desc = "[T]oggle [T]erminal" },
				{
					"<leader>tf",
					mode = { "n", "t" },
					"<cmd>ToggleTerm direction=float<cr>",
					desc = "Toggle [T]erminal [F]loat",
				},
				{ "<C-_>", mode = { "n", "t" }, toggleterm, desc = "which_key_ignore" },
			}
			return vim.list_extend(mappings, keys)
		end,
		opts = {
			open_mapping = false,
			float_opts = {
				border = "curved",
			},
		},
	},
}
