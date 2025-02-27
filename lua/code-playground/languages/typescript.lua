local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local ts_folder = vim.fs.joinpath(root_path, "typescript")
local index = vim.fs.joinpath(ts_folder, "index.ts")

local M = {}

local function ensure_files()
	local tsconfig = vim.fs.joinpath(ts_folder, "tsconfig.json")
	fileutils.ensure_directory_exists(ts_folder)
	fileutils.ensure_file_exists(index, "typescript/index.ts")
	fileutils.ensure_file_exists(tsconfig, "typescript/tsconfig.json")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = index,
		command = string.format("bun %s", index),
	}
end

M.reset = function()
	vim.fn.delete(ts_folder, "rf")
end

return M
