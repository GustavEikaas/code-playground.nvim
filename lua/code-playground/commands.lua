local haskell = require("code-playground.languages.haskell")
local odin = require("code-playground.languages.odin")
local python = require("code-playground.languages.python")
local java = require("code-playground.languages.java")
local zig = require("code-playground.languages.zig")
local typescript = require("code-playground.languages.typescript")
local fsharp = require("code-playground.languages.fsharp")
local elixir = require("code-playground.languages.elixir")
local options_manager = require("code-playground.options")
local animation = require("code-playground.animations")

---@class Command
---@field subcommands table<string,Command> | nil
---@field handle nil | fun(args: table<string>|string, options: table): nil
---@field passthrough boolean | nil

---@type table<string,Command>
local M = {}

local function spawn_buf(stdoutBuf)
	if options_manager.options.split_direction == "vsplit" then
		vim.cmd("vsplit")
		local win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_width(win, 30)
		vim.api.nvim_win_set_buf(win, stdoutBuf)
		vim.cmd("wincmd h")
	else
		local ui = vim.api.nvim_list_uis()[1]
		local height = math.floor(ui.height * 0.2)
		vim.cmd("split")
		local win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_height(win, height)
		vim.api.nvim_win_set_buf(win, stdoutBuf)
		vim.cmd("wincmd k")
	end
end

local function create_buf()
	local stdoutBuf = vim.api.nvim_create_buf(false, true)
	vim.bo[stdoutBuf].modifiable = false
	vim.bo[stdoutBuf].filetype = "code-stdout"
	return stdoutBuf
end

local function is_buf_visible(buf)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			return true
		end
	end
	return false
end

local function createStdoutBuf(buf)
	local stdoutBuf = create_buf()
	spawn_buf(stdoutBuf)

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		callback = function()
			vim.defer_fn(function()
				local curr_buf = vim.api.nvim_get_current_buf()
				if curr_buf ~= stdoutBuf and vim.api.nvim_buf_is_valid(stdoutBuf) and curr_buf ~= buf then
					vim.api.nvim_buf_delete(stdoutBuf, { force = true })
				end
			end, 10)
		end,
	})

	return {
		write = function(lines, failed)
			if not vim.api.nvim_buf_is_valid(stdoutBuf) or not is_buf_visible(stdoutBuf) then
				if vim.api.nvim_buf_is_valid(stdoutBuf) then
					vim.api.nvim_buf_delete(stdoutBuf, { force = true })
				end
				stdoutBuf = create_buf()
				spawn_buf(stdoutBuf)
			end

			vim.bo[stdoutBuf].modifiable = true
			vim.api.nvim_buf_set_lines(stdoutBuf, 0, -1, true, lines)
			if failed == true then
				for i, _ in ipairs(lines) do
					vim.api.nvim_buf_add_highlight(stdoutBuf, 99, "ErrorMsg", i - 1, 0, -1)
				end
			end
			vim.bo[stdoutBuf].modifiable = false
		end,
	}
end

local function open_workspace(file, command)
	local previous_cwd = vim.fn.getcwd()
	vim.cmd("edit! " .. file)
	local buf = vim.api.nvim_get_current_buf()
	local stdout = createStdoutBuf(buf)

	local function run()
		vim.cmd("w!")
		local lines = {}

		local anim_timer = animation[options_manager.options.animation](function(frame)
			stdout.write({ frame }, false)
		end)

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
				anim_timer:stop()

				if code ~= 0 then
					table.insert(lines, "CODE: " .. code)
				end
				stdout.write(lines, code ~= 0)
				lines = {}
			end,
		})
	end

	vim.keymap.set("n", "<leader>r", run, { buffer = buf, noremap = true, silent = true })

	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = buf,
		callback = run,
	})

	if options_manager.options.auto_change_cwd then
		vim.api.nvim_create_autocmd("BufEnter", {
			buffer = buf,
			callback = function()
				vim.cmd("cd " .. vim.fs.dirname(file))
			end,
		})

		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = buf,
			callback = function()
				vim.cmd("cd " .. previous_cwd)
			end,
		})
	end
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

M.elixir = {
	handle = function()
		local def = elixir.run()
		open_workspace(def.file, def.command)
	end,
	subcommands = {
		reset = {
			handle = function()
				elixir.reset()
				M.elixir.handle("", {})
			end,
		},
	},
}

return M
