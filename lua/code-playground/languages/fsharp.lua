local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local fsharp_folder = vim.fs.joinpath(root_path, "fsharp")
local fsproj = vim.fs.joinpath(fsharp_folder, "fsharp.fsproj")
local program_f = vim.fs.joinpath(fsharp_folder, "Program.fs")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(fsharp_folder)
	fileutils.ensure_file_exists(fsproj, "fsharp/fsharp.fsproj")
	fileutils.ensure_file_exists(program_f, "fsharp/Program.fs")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = program_f,
		command = string.format("dotnet run --project %s", fsproj),
	}
end

M.reset = function()
	vim.fn.delete(fsharp_folder, "rf")
end

return M
