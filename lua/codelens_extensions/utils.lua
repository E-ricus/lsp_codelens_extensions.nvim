local config = require "codelens_extensions.config"
local M = {}

function M.delete_buf(bufnr)
  if bufnr ~= nil then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

function M.split(bufnr)
  local cmd = config.split_vertical and "vsplit" or "split"

  vim.cmd(cmd)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)
end

function M.resize(amount)
  local cmd = config.split_vertical and "vertical resize " or "resize"
  cmd = cmd .. amount

  vim.cmd(cmd)
end
function M.scheduled_error(err)
  vim.schedule(function()
    vim.notify(err, vim.log.levels.ERROR)
  end)
end

return M
