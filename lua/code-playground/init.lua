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

local function collect_commands_with_handles(parent, prefix)
	return vim.iter(parent):fold({}, function(command_handles, name, command)
		local full_command = prefix and (prefix .. "_" .. name) or name

		if command.handle then
			command_handles[full_command] = command.handle
		end

		if command.subcommands then
			vim.iter(collect_commands_with_handles(command.subcommands, full_command))
				:each(function(sub_name, sub_handle)
					command_handles[sub_name] = sub_handle
				end)
		end

		return command_handles
	end)
end

local function collect_commands(parent, prefix)
	return vim.iter(parent):fold({}, function(commands, name, command)
		local full_command = prefix and (prefix .. " " .. name) or name

		if command.handle then
			table.insert(commands, full_command)
		end

		if command.subcommands then
			vim.iter(collect_commands(command.subcommands, full_command)):each(function(sub)
				table.insert(commands, sub)
			end)
		end

		return commands
	end)
end

local function traverse_subcommands(args, parent)
	if next(args) then
		local subcommand = parent.subcommands and parent.subcommands[args[1]]
		if subcommand then
			traverse_subcommands(vim.list_slice(args, 2, #args), subcommand)
		elseif parent.passthrough then
			parent.handle(args, require("easy-dotnet.options").options)
		else
			print("Invalid subcommand:", args[1])
		end
	elseif parent.handle then
		parent.handle(args, require("easy-dotnet.options").options)
	else
		local required = vim.tbl_keys(parent.subcommands)
		print("Missing required argument " .. vim.inspect(required))
	end
end

local function split_by_whitespace(str)
	return str and vim.iter(str:gmatch("%S+")):totable() or {}
end

M.setup = function(options)
	require("code-playground.options").set_options(options)
	vim.api.nvim_create_user_command("Code", function(commandOpts)
		local args = split_by_whitespace(commandOpts.fargs[1])
		local command = args[1]
		if not command then
			return
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
