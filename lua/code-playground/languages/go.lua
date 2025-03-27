local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local go_folder = vim.fs.joinpath(root_path, "go")
local main_go = vim.fs.joinpath(go_folder, "main.go")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(go_folder)
	fileutils.ensure_file_exists(main_go, "go/main.go")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = main_go,
		command = string.format("go run %s", main_go),
	}
end

M.reset = function()
	vim.fn.delete(go_folder, "rf")
end

return M
