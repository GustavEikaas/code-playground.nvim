local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local odin_folder = vim.fs.joinpath(root_path, "odin")
local main_odin = vim.fs.joinpath(odin_folder, "main.odin")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(odin_folder)
	fileutils.ensure_file_exists(main_odin, "odin/main.odin")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = main_odin,
		command = string.format("odin run %s -file", main_odin),
	}
end

M.reset = function()
	vim.fn.delete(odin_folder, "rf")
end

return M
