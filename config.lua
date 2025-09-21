local M = {
float = {
width = 0.8, -- fraction of editor width
height = 0.8, -- fraction of editor height
border = "rounded",
enter = true,
},
mappings = {
open = nil, -- e.g. "<leader>r"
stop = "<leader>c",
rerun = "<leader>R",
},
win_opts = {
scratch = true, -- use scratch buffer
filetype = "taskrunner-output",
},
history_limit = 50,
}


return M
