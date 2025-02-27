local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local python_folder = vim.fs.joinpath(root_path, "python")
local main_py = vim.fs.joinpath(python_folder, "main.py")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(python_folder)
	fileutils.ensure_file_exists(main_py, "python/main.py")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = main_py,
		command = string.format("python %s", main_py),
	}
end

M.reset = function()
	vim.fn.delete(python_folder, "rf")
end

return M
