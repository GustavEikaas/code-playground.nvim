---@class Options
---@field split_direction "vsplit" | "split"
---@field auto_change_cwd boolean

local M = {}

---@type Options
M.options = {
	split_direction = "vsplit",
	auto_change_cwd = false,
}

local function merge_tables(default_options, user_options)
	return vim.tbl_deep_extend("keep", user_options, default_options)
end

M.set_options = function(a)
	a = a or {}
	M.options = merge_tables(M.options, a)
	return M.options
end

return M
