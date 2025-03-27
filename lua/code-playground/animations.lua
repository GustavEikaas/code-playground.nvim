local M = {}

--- Timer object with a stop function
---@class AnimTimer
---@field stop fun(self: AnimTimer) Stops the animation timer

--- Creates an animated loading effect
---@param frames string[] The frames for the animation
---@return fun(cb: fun(frame: string)) : AnimTimer Function that starts the animation and returns an AnimTimer
local function base(frames)
	---@param cb fun(frame: string) Callback function invoked for each frame
	---@return AnimTimer
	return function(cb)
		local frame_count = #frames
		local frame = 1
		local timer = vim.loop.new_timer()

		timer:start(
			0,
			100,
			vim.schedule_wrap(function()
				if frame > frame_count then
					frame = 1
				end
				cb(frames[frame])
				frame = frame + 1
			end)
		)

		local anim_timer = {
			stop = function()
				timer:stop()
			end,
		}
		return anim_timer
	end
end

local wave_frames = {
	" ▂▃▄▅▆▇█▇▆▅▄▃▂ ",
	" ▃▄▅▆▇█▇▆▅▄▃▂▃ ",
	" ▄▅▆▇█▇▆▅▄▃▂▃▄ ",
	" ▅▆▇█▇▆▅▄▃▂▃▄▅ ",
	" ▆▇█▇▆▅▄▃▂▃▄▅▆ ",
	" ▇█▇▆▅▄▃▂▃▄▅▆▇ ",
	" █▇▆▅▄▃▂▃▄▅▆▇█ ",
	" ▇▆▅▄▃▂▃▄▅▆▇█▇ ",
	" ▆▅▄▃▂▃▄▅▆▇█▇▆ ",
	" ▅▄▃▂▃▄▅▆▇█▇▆▅ ",
	" ▄▃▂▃▄▅▆▇█▇▆▅▄ ",
	" ▃▂▃▄▅▆▇█▇▆▅▄▃ ",
}

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

M.wave = base(wave_frames)
M.spinner = base(vim.tbl_map(function(value)
	return value .. " running"
end, spinner_frames))

return M
