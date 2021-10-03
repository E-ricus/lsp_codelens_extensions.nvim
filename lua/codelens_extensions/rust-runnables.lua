-- The idea and code for this module was taken and modified from rust-tools.nvim: https://github.com/simrat39/rust-tools.nvim
local utils = require "codelens_extensions.utils"
local config = require "codelens_extensions.config"
local has_dap, dap = pcall(require, "dap")
local has_plenary, Job = pcall(require, "plenary.job")

local latest_buf_id = nil

local function get_command(args)
  local ret = " "

  local dir = args.workspaceRoot

  ret = string.format("cd '%s' && cargo ", dir)

  for _, value in ipairs(args.cargoArgs) do
    ret = ret .. value .. " "
  end

  for _, value in ipairs(args.cargoExtraArgs) do
    ret = ret .. value .. " "
  end

  if not vim.tbl_isempty(args.executableArgs) then
    ret = ret .. "-- "
    for _, value in ipairs(args.executableArgs) do
      ret = ret .. value .. " "
    end
  end
  return ret
end

local function create_debug_args(runnable_args)
  local cargo_args = runnable_args.cargoArgs

  table.insert(cargo_args, "--message-format=json")

  for _, value in ipairs(runnable_args.cargoExtraArgs) do
    table.insert(cargo_args, value)
  end
  local exec_args = {}
  if not vim.tbl_isempty(runnable_args.executableArgs) then
    table.insert(exec_args, "--")
    for _, value in ipairs(runnable_args.executableArgs) do
      table.insert(exec_args, value)
    end
  end
  cargo_args = vim.tbl_deep_extend("keep", cargo_args, exec_args)
  return cargo_args, exec_args
end

local function run_debug(executable, exec_args, rust_debug_adapter, cwd)
  local launch = {
    name = "Rust debug",
    type = rust_debug_adapter,
    request = "launch",
    program = executable,
    sourceLanguages = { "rust" },
    args = exec_args,
    cwd = cwd,
    stopOnEntry = false,
  }
  dap.run(launch)
end

local M = {}

function M.run_command(args)
  -- check if a buffer with the latest id is already open, if it is then
  -- delete it and continue
  utils.delete_buf(latest_buf_id)

  -- create the new buffer
  latest_buf_id = vim.api.nvim_create_buf(false, true)

  -- split the window to create a new buffer and set it to our window
  utils.split(latest_buf_id)

  utils.resize "-5"

  local command = get_command(args)

  -- run the command
  vim.fn.termopen(command)

  -- when the buffer is closed, set the latest buf id to nil else there are
  -- some edge cases with the id being sit but a buffer not being open
  local function onDetach(_, _)
    latest_buf_id = nil
  end
  vim.api.nvim_buf_attach(latest_buf_id, false, { on_detach = onDetach })
end

function M.debug_command(args, rust_debug_adapter)
  if not has_dap then
    utils.scheduled_error "nvim-dap not found."
    return
  end
  if not has_plenary then
    utils.scheduled_error "plenary not found."
    return
  end

  rust_debug_adapter = rust_debug_adapter or config.rust_debug_adapter

  local cargo_args, exec_args = create_debug_args(args)
  Job
    :new({
      command = "cargo",
      args = cargo_args,
      cwd = args.workspaceRoot,
      on_exit = function(j, code)
        if code and code > 0 then
          utils.scheduled_error "An error occured while compiling. Please fix all compilation issues and try again."
          return
        end
        vim.schedule(function()
          for _, value in pairs(j:result()) do
            local json = vim.fn.json_decode(value)
            if type(json) == "table" and json.executable ~= vim.NIL and json.executable ~= nil then
              run_debug(json.executable, exec_args, rust_debug_adapter, args.workspaceRoot)
              break
            end
          end
        end)
      end,
    })
    :start()
end

return M
