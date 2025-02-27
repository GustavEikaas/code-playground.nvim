local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local dotnet_folder = vim.fs.joinpath(root_path, "dotnet")
local csproj = vim.fs.joinpath(dotnet_folder, "dotnet.csproj")
local program = vim.fs.joinpath(dotnet_folder, "Program.cs")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(root_path)
	fileutils.ensure_directory_exists(dotnet_folder)
	fileutils.ensure_file_exists(csproj, "dotnet/dotnet.csproj")
	fileutils.ensure_file_exists(program, "dotnet/Program.cs")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = program,
		command = string.format("dotnet run --project %s", csproj),
	}
end

M.reset = function()
	vim.fn.delete(dotnet_folder, "rf")
end

return M
