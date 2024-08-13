local M = {}

local function createStdoutBuf()
  local outBuf = vim.api.nvim_create_buf(false, true) -- false for not listing, true for scratch
  vim.api.nvim_win_set_buf(0, outBuf)
  vim.api.nvim_set_current_buf(outBuf)
  vim.api.nvim_win_set_width(0, 30)
  vim.api.nvim_buf_set_option(outBuf, 'modifiable', false)
  vim.api.nvim_buf_set_option(outBuf, "filetype", "TS-stdout")
  vim.api.nvim_buf_set_name(outBuf, 'TS-stdout')
  return {
    write = function(lines)
      vim.api.nvim_buf_set_option(outBuf, 'modifiable', true)
      vim.api.nvim_buf_set_lines(outBuf, 0, -1, true, lines)
      vim.api.nvim_buf_set_option(outBuf, 'modifiable', false)
    end
  }
end


local function ensureFilesPresent()
  local fileutils = require("ts-playground.file-utils")
  local folder = vim.fs.joinpath(vim.fn.stdpath("data"), "ts-playground/")
  fileutils.ensure_directory_exists(folder)
  local index = vim.fs.joinpath(vim.fn.stdpath("data"), "ts-playground", "index.ts")
  local tsconfig = vim.fs.joinpath(vim.fn.stdpath("data"), "ts-playground", "tsconfig.json")
  fileutils.ensure_file_exists(index, "index.ts")
  fileutils.ensure_file_exists(tsconfig, "tsconfig.json")

  return index
end

M.setup = function()
  local indexPath = ensureFilesPresent()

  vim.api.nvim_create_user_command('TS', function()
    vim.cmd("edit! " .. indexPath)
    local buf = vim.api.nvim_get_current_buf()
    vim.cmd("vsplit")
    local stdout = createStdoutBuf()

    vim.keymap.set('n', '<leader>r', function()
      vim.fn.jobstart(string.format("bun %s", indexPath), {
        stdout_buffered = true,
        on_stdout = function(_, data)
          stdout.write(data)
        end
      })

      stdout.write({ "Executing..." })
    end, { buffer = buf, noremap = true, silent = true })

    vim.cmd("wincmd h")
  end, {})
end

return M
