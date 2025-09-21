# taskrunner.nvmi

Run shell tasks asynchronously in Neovim and view output in a floating window.

## Features
- Run commands with `:RunTask <cmd>`
- Stop jobs (`:TaskStop <jobid>`)
- Rerun last command (`:TaskRerun`)
- History + simple UI

## Install
Using lazy.nvim

```lua
{ 'te55eract/taskrunner.nvim', config = function() require('taskrunner').setup() end }
