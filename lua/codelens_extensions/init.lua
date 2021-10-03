local rr = require "codelens_extensions.rust-runnables"
local config = require "codelens_extensions.config"

local M = {}

M.setup = function(opts)
  opts = opts or {}
  if opts.vertical_split ~= nil then
    config.vertical_split = opts.vertical_split
  end
  if opts.rust_debug_adapter ~= nil then
    config.rust_debug_adapter = opts.rust_debug_adapter
  end

  local init_rust_commands = opts.init_rust_commands or config.init_rust_commands
  if init_rust_commands then
    vim.lsp.commands["rust-analyzer.runSingle"] = function(command)
      rr.run_command(command.arguments[1].args)
    end
    vim.lsp.commands["rust-analyzer.debugSingle"] = function(command)
      rr.debug_command(command.arguments[1].args)
    end
  end
end

return M
