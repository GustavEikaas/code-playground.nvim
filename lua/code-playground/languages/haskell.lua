local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
local haskell_folder = vim.fs.joinpath(root_path, "haskell")
local main_haskell = vim.fs.joinpath(haskell_folder, "main.hs")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(haskell_folder)
	fileutils.ensure_file_exists(main_haskell, "haskell/main.hs")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = main_haskell,
		command = string.format("runghc %s", main_haskell),
	}
end

M.reset = function()
	vim.fn.delete(haskell_folder, "rf")
end

return M
