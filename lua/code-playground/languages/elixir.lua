local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local elixir_folder = vim.fs.joinpath(root_path, "elixir")
local main_exs = vim.fs.joinpath(elixir_folder, "main.exs")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(elixir_folder)
	fileutils.ensure_file_exists(main_exs, "elixir/main.exs")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = main_exs,
		command = string.format("elixir %s", main_exs),
	}
end

M.reset = function()
	vim.fn.delete(elixir_folder, "rf")
end

return M
