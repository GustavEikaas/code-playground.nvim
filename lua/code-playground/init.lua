local M = {}

local function createStdoutBuf()
  local outBuf = vim.api.nvim_create_buf(false, true) -- false for not listing, true for scratch
  vim.api.nvim_win_set_buf(0, outBuf)
  vim.api.nvim_set_current_buf(outBuf)
  vim.api.nvim_win_set_width(0, 30)
  vim.api.nvim_buf_set_option(outBuf, 'modifiable', false)
  vim.api.nvim_buf_set_option(outBuf, "filetype", "code-stdout")
  return {
    write = function(lines)
      vim.api.nvim_buf_set_option(outBuf, 'modifiable', true)
      vim.api.nvim_buf_set_lines(outBuf, 0, -1, true, lines)
      vim.api.nvim_buf_set_option(outBuf, 'modifiable', false)
    end
  }
end

local function ensureTemplateFilesCreated()
  local fileutils = require("code-playground.file-utils")
  local root = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground")
  fileutils.ensure_directory_exists(root)

  local ts_folder = vim.fs.joinpath(root, "typescript")
  fileutils.ensure_directory_exists(ts_folder)
  local index = vim.fs.joinpath(ts_folder, "index.ts")
  local tsconfig = vim.fs.joinpath(ts_folder, "tsconfig.json")
  fileutils.ensure_file_exists(index, "typescript/index.ts")
  fileutils.ensure_file_exists(tsconfig, "typescript/tsconfig.json")

  local dotnet_folder = vim.fs.joinpath(root, "dotnet")
  fileutils.ensure_directory_exists(dotnet_folder)
  local csproj = vim.fs.joinpath(dotnet_folder, "dotnet.csproj")
  local program = vim.fs.joinpath(dotnet_folder, "Program.cs")
  fileutils.ensure_file_exists(csproj, "dotnet/dotnet.csproj")
  fileutils.ensure_file_exists(program, "dotnet/Program.cs")

  local rust_folder = vim.fs.joinpath(root, "rust")
  fileutils.ensure_directory_exists(rust_folder)
  local cargo = vim.fs.joinpath(rust_folder, "Cargo.toml")
  fileutils.ensure_directory_exists(vim.fs.joinpath(rust_folder, "src"))
  local main = vim.fs.joinpath(rust_folder, "src", "main.rs")
  fileutils.ensure_file_exists(cargo, "rust/Cargo.toml")
  fileutils.ensure_file_exists(main, "rust/src/main.rs")

  local python_folder = vim.fs.joinpath(root, "python")
  fileutils.ensure_directory_exists(python_folder)
  local main_py = vim.fs.joinpath(python_folder, "main.py")
  fileutils.ensure_file_exists(main_py, "python/main.py")

  local zig_folder = vim.fs.joinpath(root, "zig")
  fileutils.ensure_directory_exists(zig_folder)
  local main_zig = vim.fs.joinpath(zig_folder, "main.zig")
  fileutils.ensure_file_exists(main_zig, "zig/main.zig")

  return index
end

local function open_workspace(file, command)
  vim.cmd("edit! " .. file)
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd("vsplit")
  local stdout = createStdoutBuf()

  local function run()
    local lines = {}
    vim.fn.jobstart(command, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        for _, value in ipairs(data) do
          table.insert(lines, value)
        end
      end,
      on_stderr = function(_, data)
        for _, value in ipairs(data) do
          table.insert(lines, value)
        end
      end,
      on_exit = function(_, b)
        stdout.write(lines)
        lines = {}
      end
    })
    stdout.write({ "Executing..." })
  end

  vim.keymap.set('n', '<leader>r', run, { buffer = buf, noremap = true, silent = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = buf,
    callback = run,
  })

  vim.cmd("wincmd h")
end


M.setup = function()
  ensureTemplateFilesCreated()
  local commands = {
    dotnet = function()
      local project = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground", "dotnet", "dotnet.csproj")
      local program = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground", "dotnet", "Program.cs")
      open_workspace(program, string.format("dotnet run --project %s", project))
    end,
    typescript = function()
      local indexPath = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground", "typescript", "index.ts")
      open_workspace(indexPath, string.format("bun %s", indexPath))
    end,
    rust = function()
      local indexPath = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground", "rust", "src", "main.rs")
      local cargo = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground", "rust", "Cargo.toml")
      open_workspace(indexPath, string.format("cargo run --manifest-path %s", cargo))
    end,
    python = function()
      local main = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground", "python", "main.py")
      open_workspace(main, string.format("python %s", main))
    end,
    zig = function()
      local main = vim.fs.joinpath(vim.fn.stdpath("data"), "code-playground", "zig", "main.zig")
      open_workspace(main, string.format("zig run %s", main))
    end
  }

  vim.api.nvim_create_user_command('Code',
    function(commandOpts)
      local subcommand = commandOpts.fargs[1]
      local func = commands[subcommand]
      if func then
        func()
      else
        print("Invalid subcommand:", subcommand)
      end
    end, {
      nargs = 1,
      complete = function()
        local completion = {}
        for key, _ in pairs(commands) do
          table.insert(completion, key)
        end
        return completion
      end,

    })
end

return M
