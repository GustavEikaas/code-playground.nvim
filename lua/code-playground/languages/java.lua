local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local java_folder = vim.fs.joinpath(root_path, "java")
local main_java = vim.fs.joinpath(java_folder, "Main.java")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(java_folder)
	fileutils.ensure_file_exists(main_java, "java/Main.java")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = main_java,
		command = string.format("java %s", main_java),
	}
end

M.reset = function()
	vim.fn.delete(java_folder, "rf")
end

return M
