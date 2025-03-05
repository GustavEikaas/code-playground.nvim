local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fs.normalize(vim.fn.stdpath("data")), "code-playground")
local zig_folder = vim.fs.joinpath(root_path, "zig")
local main_zig = vim.fs.joinpath(zig_folder, "main.zig")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(zig_folder)
	fileutils.ensure_file_exists(main_zig, "zig/main.zig")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = main_zig,
		command = string.format("zig run %s", main_zig),
	}
end

M.reset = function()
	vim.fn.delete(zig_folder, "rf")
end

return M
