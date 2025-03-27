local M = {}

M.ensure_directory_exists = function(path)
	local uv = vim.loop

	local stat = uv.fs_stat(path)
	if not stat then
		local success, err = uv.fs_mkdir(path, 511) -- 511 is 0777 in octal
		if not success then
			print("Failed to create directory: " .. err)
		end
	elseif stat.type ~= "directory" then
		print(path .. " exists but is not a directory!")
	end
end

M.get_script_directory = function()
	local info = debug.getinfo(1, "S")
	local script_path = info.source:match("@(.*)")
	return script_path:match("(.*[\\/])")
end

M.open_file_in_same_directory = function(filename)
	local script_dir = M.get_script_directory()
	local full_path = script_dir .. filename

	local file, err = io.open(full_path, "r")
	if not file then
		print("Failed to open file: " .. err)
		return nil
	end

	local content = file:read("*all")
	file:close()

	return content
end

M.ensure_file_exists = function(filepath, templateName)
	local file = io.open(filepath, "r")
	if file then
		file:close()
	else
		file = io.open(filepath, "w")
		if file == nil then
			print("Failed to create the file: " .. filepath)
			return
		end
		local content = M.open_file_in_same_directory("templates/" .. templateName)
		if content then
			file:write(content)
		end

		file:close()
	end
end

return M
