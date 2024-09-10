return {
	"stevearc/conform.nvim",
	enabled = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				php = { "php-cs-fixer" },
				javascript = { "pretterd", "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "jq" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				sql = { "sql_formatter" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
			notify_on_error = true,
			formatters = {
				sql_formatter = {
					prepend_args = { "-c", vim.fn.expand("~/.config/sql_formatter.json") },
				},
				["php-cs-fixer"] = {
					command = "php-cs-fixer",
					args = {
						"fix",
						"$FILENAME",
						"--config=/your/path/to/config/file/[filename].php",
						"--allow-risky=yes", -- if you have risky stuff in config, if not you dont need it.
					},
					stdin = false,
				},
				prettier = {
					prepend_args = { "-c", vim.fn.expand("../utils/formatters/prettier.json") },
				},
			},
		})
		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
