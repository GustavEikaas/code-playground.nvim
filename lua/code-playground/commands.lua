local haskell = require("code-playground.languages.haskell")
local odin = require("code-playground.languages.odin")
local python = require("code-playground.languages.python")
local java = require("code-playground.languages.java")
local zig = require("code-playground.languages.zig")
local typescript = require("code-playground.languages.typescript")
local fsharp = require("code-playground.languages.fsharp")
local options = require("code-playground.options")
---@class Command
---@field subcommands table<string,Command> | nil
---@field handle nil | fun(args: table<string>|string, options: table): nil
---@field passthrough boolean | nil

---@type table<string,Command>
local M = {}

local function createStdoutBuf()
	local outBuf = vim.api.nvim_create_buf(false, true) -- false for not listing, true for scratch
	vim.api.nvim_win_set_buf(0, outBuf)
	vim.api.nvim_set_current_buf(outBuf)
	if options.options.split_direction == "vsplit" then
		vim.api.nvim_win_set_width(0, 30)
		vim.cmd("wincmd h")
	else
		local ui = vim.api.nvim_list_uis()[1]
		local height = math.floor(ui.height * 0.2)
		vim.api.nvim_win_set_height(0, height)
		vim.cmd("wincmd k")
	end
	vim.api.nvim_buf_set_option(outBuf, "modifiable", false)
	vim.api.nvim_buf_set_option(outBuf, "filetype", "code-stdout")
	return {
		write = function(lines, failed)
			vim.api.nvim_buf_set_option(outBuf, "modifiable", true)
			vim.api.nvim_buf_set_lines(outBuf, 0, -1, true, lines)
			if failed == true then
				for i, _ in ipairs(lines) do
					vim.api.nvim_buf_add_highlight(outBuf, 99, "ErrorMsg", i - 1, 0, -1)
				end
			end
			vim.api.nvim_buf_set_option(outBuf, "modifiable", false)
		end,
	}
end

local function open_workspace(file, command)
	vim.cmd("edit! " .. file)
	local buf = vim.api.nvim_get_current_buf()
	vim.cmd(options.options.split_direction)
	local stdout = createStdoutBuf()

	local function run()
		local lines = {}
		vim.fn.jobstart(command, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				for _, value in ipairs(data) do
					table.insert(lines, value)
				end
			end,
			on_stderr = function(_, data)
				for _, value in ipairs(data) do
					table.insert(lines, value)
				end
			end,
			on_exit = function(_, code)
				if code ~= 0 then
					table.insert(lines, "CODE: " .. code)
				end
				stdout.write(lines, code ~= 0)
				lines = {}
			end,
		})
		stdout.write({ "Executing..." })
	end

	vim.keymap.set("n", "<leader>r", run, { buffer = buf, noremap = true, silent = true })

	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = buf,
		callback = run,
	})
end

local dotnet = require("code-playground.languages.dotnet")
local rust = require("code-playground.languages.rust")
local go = require("code-playground.languages.go")

---@type Command
M.dotnet = {
	handle = function()
		local def = dotnet.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				dotnet.reset()
				M.dotnet.handle("", {})
			end,
		},
	},
}

M.go = {
	handle = function()
		local def = go.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				go.reset()
				M.go.handle("", {})
			end,
		},
	},
}

M.rust = {
	handle = function()
		local def = rust.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				rust.reset()
				M.rust.handle("", {})
			end,
		},
	},
}

M.haskell = {
	handle = function()
		local def = haskell.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				haskell.reset()
				M.haskell.handle("", {})
			end,
		},
	},
}

M.odin = {
	handle = function()
		local def = odin.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				odin.reset()
				M.odin.handle("", {})
			end,
		},
	},
}

M.python = {
	handle = function()
		local def = python.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				python.reset()
				M.python.handle("", {})
			end,
		},
	},
}

M.java = {
	handle = function()
		local def = java.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				java.reset()
				M.java.handle("", {})
			end,
		},
	},
}

M.typescript = {
	handle = function()
		local def = typescript.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				typescript.reset()
				M.typescript.handle("", {})
			end,
		},
	},
}

M.fsharp = {
	handle = function()
		local def = fsharp.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				fsharp.reset()
				M.fsharp.handle("", {})
			end,
		},
	},
}

M.zig = {
	handle = function()
		local def = zig.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				zig.reset()
				M.zig.handle("", {})
			end,
		},
	},
}

return M
