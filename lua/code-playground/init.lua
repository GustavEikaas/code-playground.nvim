---@class Run
---@field file string - The file to open
---@field command string - The command to run

local M = {}
local commands = require("code-playground.commands")
local function wrap(callback)
	return function(...)
		if coroutine.running() then
			callback(...)
		else
			local co = coroutine.create(callback)
			local s = ...
			local handle = function()
				local success, err = coroutine.resume(co, s)
				if not success then
					print("Coroutine failed: " .. err)
				end
			end
			handle()
		end
	end
end

local function collect_commands(parent, prefix)
	return vim.iter(parent):fold({}, function(cmds, name, command)
		local full_command = prefix and (prefix .. " " .. name) or name

		if command.handle then
			table.insert(cmds, full_command)
		end

		if command.subcommands then
			vim.iter(collect_commands(command.subcommands, full_command)):each(function(sub)
				table.insert(cmds, sub)
			end)
		end

		return cmds
	end)
end

local function traverse_subcommands(args, parent)
	if next(args) then
		local subcommand = parent.subcommands and parent.subcommands[args[1]]
		if subcommand then
			traverse_subcommands(vim.list_slice(args, 2, #args), subcommand)
		elseif parent.passthrough then
			parent.handle(args, require("code-playground.options").options)
		else
			print("Invalid subcommand:", args[1])
		end
	elseif parent.handle then
		parent.handle(args, require("code-playground.options").options)
	else
		local required = vim.tbl_keys(parent.subcommands)
		print("Missing required argument " .. vim.inspect(required))
	end
end

local function split_by_whitespace(str)
	return str and vim.iter(str:gmatch("%S+")):totable() or {}
end

local function present_command_picker()
	local all_commands = collect_commands(commands)
	local options = vim.tbl_map(function(i)
		return i
	end, all_commands)

	vim.ui.select(options, { prompt = "Select language" }, function(choice)
		if not choice then
			return
		end
		vim.cmd("Code " .. choice)
	end)
end

M.setup = function(options)
	require("code-playground.options").set_options(options)
	vim.api.nvim_create_user_command("Code", function(commandOpts)
		local args = split_by_whitespace(commandOpts.fargs[1])
		local command = args[1]
		if not command then
			present_command_picker()
		end
		local subcommand = commands[command]
		if subcommand then
			wrap(function()
				traverse_subcommands(vim.list_slice(args, 2, #args), subcommand)
			end)()
		else
			print("Invalid subcommand:", command)
		end
	end, { nargs = "?" })
end

return M
