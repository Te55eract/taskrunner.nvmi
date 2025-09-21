local uv = vim.loop
local api = vim.api
local fn = vim.fn

local config = require('taskrunner.config')
local ui = require('taskrunner.ui')

local M = {
  state = {
    jobs = {},
    history = {},
    last_cmd = nil,
  }
}

local function add_history(cmd)
  local h = M.state.history
  table.insert(h, 1, cmd)
  if #h > (config.history_limit or 50) then
    for i = #h, (config.history_limit or 50) + 1, -1 do table.remove(h, i) end
  end
end

local function append_lines(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
end

function M.run(cmd, opts)
  opts = opts or {}
  local buf, win = ui.create_float(config.float)
  api.nvim_buf_set_option(buf, 'buftype', config.win_opts.scratch and 'nofile' or '')
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'filetype', config.win_opts.filetype or '')

  local jid = fn.jobstart(cmd, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if data and #data > 0 then append_lines(buf, data) end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then append_lines(buf, data) end
    end,
    on_exit = function(_, code)
      if api.nvim_buf_is_valid(buf) then
        append_lines(buf, {"", "Process exited with code " .. tostring(code)})
      end
      if M.state.jobs[jid] then M.state.jobs[jid].running = false end
    end,
  })

  if jid <= 0 then
    api.nvim_err_writeln('taskrunner: failed to start job: ' .. tostring(cmd))
    return nil
  end

  M.state.jobs[jid] = { buf = buf, win = win, job = jid, running = true }
  M.state.last_cmd = cmd
  add_history(cmd)
  return jid
end

function M.stop(jobid)
  local entry = M.state.jobs[jobid]
  if not entry then return false end
  if entry.running then
    pcall(fn.jobstop, jobid)
    entry.running = false
    if api.nvim_buf_is_valid(entry.buf) then
      append_lines(entry.buf, {"", "Process cancelled."})
    end
    return true
  end
  return false
end

function M.rerun_last()
  if not M.state.last_cmd then
    api.nvim_out_write('taskrunner: no last command\n')
    return
  end
  return M.run(M.state.last_cmd)
end

function M.setup(user_conf)
  if user_conf then
    config = vim.tbl_deep_extend('force', config, user_conf)
  end

  api.nvim_create_user_command('RunTask', function(opts)
    local args = opts.args
    if args == '' then
      api.nvim_err_writeln('RunTask: please pass a shell command')
      return
    end
    M.run(args)
  end, { nargs = '+', complete = 'shellcmd' })

  api.nvim_create_user_command('TaskStop', function(opts)
    local id = tonumber(opts.args)
    if not id then api.nvim_err_writeln('TaskStop: pass job id') return end
    M.stop(id)
  end, { nargs = 1 })

  api.nvim_create_user_command('TaskRerun', function()
    M.rerun_last()
  end, {})
end

return M
