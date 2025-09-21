local M = {
  float = {
    width = 0.8,
    height = 0.8,
    border = "rounded",
    enter = true,
  },
  mappings = {
    open = nil,
    stop = "<leader>c",
    rerun = "<leader>R",
  },
  win_opts = {
    scratch = true,
    filetype = "taskrunner-output",
  },
  history_limit = 50,
}

return M
