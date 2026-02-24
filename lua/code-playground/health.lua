--checkhealth code-playground
local M = {}

---@param command  table<string>
---@param advice  string | nil
local function ensure_dep_installed(command, advice)
  local exec = command
  advice = advice or ""
  local success = pcall(function() vim.fn.system(exec) end)
  local cmd_name = table.concat(vim.tbl_filter(function(item) return type(item) == "string" and not item:match("^%-") end, exec), " ")
  if success and vim.v.shell_error == 0 then
    vim.health.ok(cmd_name .. " is installed")
  else
    print("" .. vim.v.shell_error)
    vim.health.error(cmd_name .. " is not installed", { advice })
  end
end

local function os_info()
  local platform = vim.loop.os_uname()
  local sysname = platform.sysname
  local release = platform.release

  if release:lower():match("arch") then release = release .. " btw" end

  vim.health.info(string.format("%s (%s)", sysname, release))
end

local function print_nvim_version()
  local v = vim.version()
  local version_str = string.format("Neovim version: %d.%d.%d", v.major, v.minor, v.patch)
  vim.health.info(version_str)
end

local function get_shell_info()
  local shell = vim.o.shell
  vim.health.info("Shell: " .. shell)
end

local function get_commit_info()
  local source = debug.getinfo(1, "S").source:sub(2)
  local dir = vim.fn.fnamemodify(source, ":h")
  local sha = vim.fn.system({ "git", "-C", dir, "rev-parse", "HEAD" })
  vim.health.info("Commit: " .. vim.trim(sha or ""))
end

M.check = function()
  vim.health.start("General information")
  os_info()
  print_nvim_version()
  get_shell_info()
  pcall(get_commit_info)
  vim.health.start("CLI dependencies")
  ensure_dep_installed({ "cargo", "-h" }, "https://doc.rust-lang.org/cargo/getting-started/installation.html")
  ensure_dep_installed({ "odin", "-h" }, "https://odin-lang.org/docs/install/")
  ensure_dep_installed({ "go", "-h" }, "https://go.dev/doc/install")
  ensure_dep_installed({ "bun", "-h" }, "npm i -g bun")
  ensure_dep_installed({ "dotnet", "-h" }, "https://dotnet.microsoft.com/en-us/download")
  ensure_dep_installed({ "python", "-h" }, "https://www.python.org/downloads/")
  ensure_dep_installed({ "runghc", "-h" }, "https://www.haskell.org/get-started/")
  ensure_dep_installed({ "java", "-h" }, "https://www.java.com/en/download/manual.jsp")
  ensure_dep_installed({ "zig", "-h" }, "https://ziglang.org/learn/getting-started/")
  vim.health.start("Plugin information")
  vim.health.info("Playground path: " .. vim.fs.joinpath(vim.fs.normalize(vim.fn.stdpath("data")), "code-playground"))
end

return M
