# lsp_codelens_extensions.nvim
Adds client-side code for codelenses commands that are not available in the language servers. 

## Motivation 
Some servers provide some codelenses that cannot be run by default on the server and need some client-code
like rust-analyzer's runnables. Neovim provides the option to add custom commands for the clients and
validates these before sending a command to a server.

This plugin intends to add that missing functionality.

## What this plugin is not?
- This plugin DOES NOT intend to give an out of the box experience for LSP or DAP. Other plugins already 
accomplish this for certain languages, like [rust-tools.nvim](https://github.com/simrat39/rust-tools.nvim),
or [go.nvim](https://github.com/ray-x/go.nvim).

- This plugin DOES NOT manage your LSP codelenses, not showing them, not refreshing them. It only adds the commands for executed lenses that are not supported by the server.

## Supported lenses
- `rust-analyzer.runSingle`
- `rust-analyzer.debugSingle`

## Requirements
- `neovim nightly` (or a version that includes this [commit](https://github.com/neovim/neovim/commit/19a77cd5a7cbd304e57118d6a09798223b6d2dbf)
- `plenary` (optional for rust-runnables debbug)
- `dap` (optional for rust-runnables debbug)
- for `rust-analyzer.debugSingle` command, a debug adapter configured for rust is required, [codelldb](https://github.com/vadimcn/vscode-lldb/) will be used by default to launch.
Instructions for this configuration can be found on the [dap wiki](https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#ccrust-via-codelldb)

## Installation
Use your favorite package manager.

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
  'E-ricus/lsp_codelens_extensions.nvim',
  -- Only required for debugging
  requires = { {"nvim-lua/plenary.nvim", "mfussenegger/nvim-dap"} }
}
```

## Usage
Using the defaults you just need to call this on any part of your init.lua:
```lua
require("codelens_extensions").setup()
```

Or directly on packer:
```lua
use {
  'E-ricus/lsp_codelens_extensions.nvim',
  -- Only required for debugging
  requires = { {"nvim-lua/plenary.nvim", "mfussenegger/nvim-dap"} }
  config = function ()
    require("codelens_extensions").setup()
  end,
}
```

## Setup
You can change either the split behavior or the debug_adapter used to run `dap`

Defaults:
```lua  
require("codelens_extensions").setup {
    vertical_split = false,
    rust_debug_adapter = "codelldb",
    init_rust_commands = true,
}
```

### init_rust_commands
By default, this plugin will add the handler to the lens command, and add this command to `vim.lsp`.
But you can change this flag and add the specific command on any part of your configuration, for example:
```lua
-- On your init.lua
require("codelens_extensions").setup {
    init_rust_commands = false,
}
-- On your lsp config
vim.lsp.commands["rust-analyzer.runSingle"] = function(command)
  require("codelens_extensions.rust-runnables").run_command(command.arguments[1].args)
end
```
## Example usage:
https://user-images.githubusercontent.com/18682359/135780475-14a037a0-c28f-4234-876b-6fe05e9f97aa.mov

Note: in this example you see [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) as this configuration opens the ui on `dap.start()`. This plugin will only start the debug adapter, not the ui.
