return {
	{
		"nvim-neotest/nvim-nio",
	},
	{
		"mfussenegger/nvim-dap",
		requires = { "nvim-neotest/nvim-nio" },
		config = function()
			local dap = require("dap")
			dap.adapters.php = {
				type = "executable",
				command = "php-debug-adaptor",
			}
			dap.configurations.php = {
				{
					type = "php",
					request = "launch",
					name = "Xdebug",
					port = 9003,
					pathMappings = {},
					xdebugSettings = {
						max_children = 100,
					},
					-- stopOnEntry
					-- ignore: An optional array of glob patterns that errors should be ignored from (for example **/vendor/**/*.php)
				},
			}

			-- Example:
			-- -- code-dap-local.lua for ar3
			-- local dap = require "dap"
			-- dap.configurations.php[1].pathMappings = {
			--   ['/buildkit/build/'] = '/var/www/adyen.artfulrobot.uk/civicrm-buildkit-docker/build/'
			-- }
			pcall(require, "code-dap-local")
			-- require 'code-dap-local'

			vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		requires = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup({
				icons = { expanded = "▾", collapsed = "▸", current_frame = "»" },
				mappings = {
					-- Use a table to apply multiple mappings
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				layouts = {
					{
						elements = {
							"scopes",
							-- 'breakpoints',
							"stacks",
							-- 'watches',
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							"repl",
							--    'console',
						},
						size = 10,
						position = "bottom",
					},
				},
				floating = {
					max_height = nil, -- These can be integers or a float between 0 and 1.
					max_width = nil, -- Floats will be treated as percentage of your screen.
					border = "rounded", -- Border style. Can be "single", "double" or "rounded"
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
				controls = {
					-- Requires Neovim nightly (or 0.8 when released)
					enabled = false, -- because the icons don't work
					-- Display controls in this element
					element = "repl",
					icons = {
						pause = "",
						play = "",
						step_into = "",
						step_over = "",
						step_out = "",
						step_back = "",
						run_last = "",
						terminate = "",
					},
				},
				windows = { indent = 1 },
				element_mappings = {},
				expand_lines = true,
				force_buffers = true,
				render = {
					indent = 2,
					max_value_lines = 100,
				},
			})

			-- add listeners to auto open DAP UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.keymap.set("n", "<leader>xb", function()
				require("dap").toggle_breakpoint()
			end, { desc = "Toggle Breakpoints" })
			vim.keymap.set("n", "<leader>xB", function()
				require("dap").clear_breakpoints()
			end, { desc = "Clear Breakpoints" })
			vim.keymap.set("n", "<leader>xc", function()
				require("dap").continue()
			end, { desc = "Continue" })
			vim.keymap.set("n", "<F5>", function()
				require("dap").continue()
			end, { desc = "Continue2" })
			vim.keymap.set("n", "<leader>xi", function()
				require("dap").step_into()
			end, { desc = "Step Into" })
			vim.keymap.set("n", "<F3>", function()
				require("dap").step_into()
			end, { desc = "Step Into2" })
			vim.keymap.set("n", "<leader>xl", function()
				require("dapui").float_element("breakpoints")
			end, { desc = "List Breakpoints" })
			vim.keymap.set("n", "<leader>xo", function()
				require("dap").step_over()
			end, { desc = "Step Over" })
			vim.keymap.set("n", "<F2>", function()
				require("dap").step_over()
			end, { desc = "Step Over2 " })
			vim.keymap.set("n", "<leader>xO", function()
				require("dap").step_out()
			end, { desc = "Step Out" })
			vim.keymap.set("n", "<F4>", function()
				require("dap").step_out()
			end, { desc = "Step Out2" })
			-- gives error, but docs say it's ok?
			-- vim.keymap.set('n', {'<leader>xq', '<F7>'}, function() require("dap").close() dapui.close() end, { desc = "Close Session" })
			vim.keymap.set("n", "<leader>xq", function()
				require("dap").close()
				dapui.close()
			end, { desc = "Close Session" })
			vim.keymap.set("n", "<F7>", function()
				require("dap").close()
				dapui.close()
			end, { desc = "Close Session" })

			vim.keymap.set("n", "<leader>xQ", function()
				dap = require("dap")
				dap.terminate()
				dap.close()
				dapui.close()
			end)
			vim.keymap.set("n", "<F6>", function()
				dap = require("dap")
				dap.terminate()
				dap.close()
				dapui.close()
			end, { desc = "Terminate" })

			vim.keymap.set("n", "<leader>xr", function()
				require("dap").repl.toggle()
			end, { desc = "REPL" })
			vim.keymap.set("n", "<leader>xs", function()
				require("dapui").float_element("scopes")
			end, { desc = "Scopes" })
			vim.keymap.set("n", "<leader>xt", function()
				require("dapui").float_element("stacks")
			end, { desc = "Threads" })
			vim.keymap.set("n", "<leader>xu", function()
				require("dapui").toggle()
			end, { desc = "Toggle Debugger UI" })
			vim.keymap.set("n", "<leader>xw", function()
				require("dapui").float_element("watches")
			end, { desc = "Watches" })
			vim.keymap.set("n", "<leader>xx", function()
				require("dap.ui.widgets").hover()
			end, { desc = "Inspect" })
		end,
	},
	-- virtual text for the debugger
	{
		"theHamsta/nvim-dap-virtual-text",
		opts = {},
	},

	-- mason.nvim integration
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = "mason.nvim",
		-- cmd = { "DapInstall", "DapUninstall" },
		opts = {
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {
				function(config)
					-- all sources with no handler get passed here

					-- Keep original functionality
					require("mason-nvim-dap").default_setup(config)
				end,
				php = function(config)
					config.configurations = {
						-- {
						--   type = 'php',
						--   request = 'launch',
						--   name = 'My Xdebug',
						--   port = 9003,
						--   -- program = "${file}", -- This configuration will launch the current file if used.
						-- },
					}
					-- config.adapters = {
					--   type = "executable",
					--   command = "...",
					--   args = {
					--     "-m",
					--   },
					-- }
					require("mason-nvim-dap").default_setup(config) -- don't forget this!
				end,
			},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				"php-debug-adaptor",
			},
		},
	},
}
