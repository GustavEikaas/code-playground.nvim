local fileutils = require("code-playground.file-utils")
local root_path = vim.fs.joinpath(vim.fs.normalize(vim.fn.stdpath("data")), "code-playground")
local rust_folder = vim.fs.joinpath(root_path, "rust")
local cargo = vim.fs.joinpath(rust_folder, "Cargo.toml")
local main = vim.fs.joinpath(rust_folder, "src", "main.rs")

local M = {}

local function ensure_files()
	fileutils.ensure_directory_exists(rust_folder)
	fileutils.ensure_directory_exists(vim.fs.joinpath(rust_folder, "src"))
	fileutils.ensure_file_exists(cargo, "rust/Cargo.toml")
	fileutils.ensure_file_exists(main, "rust/src/main.rs")
end

---@return Run
M.run = function()
	ensure_files()
	return {
		file = main,
		command = string.format("cargo run --manifest-path %s", cargo),
	}
end

M.reset = function()
	vim.fn.delete(rust_folder, "rf")
end

return M
