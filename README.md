# SwitchColor.nvim

A simply Neovim plugin for switching, previewing, and saving colorschemes and backgrounds.

## Features

- **Switch & Preview**: Easily switch and preview colorschemes and backgrounds.
- **Save & Restore**: Automatically save and restore your configuration.

## QuickStart

### Installation

With [Lazy.nvim](https://github.com/folke/lazy.nvim), add the following to your configuration:

```lua
return {
    "liiuhaao/switchcolor",
    config = function()
        require("switchcolor").setup({
            -- The plugin will use the configuration from the file by default.
            -- Specify the colorscheme and background here if you want to override the saved settings.
            scheme = "default",
            background = "dark",
            -- Path to save the configuration.
            -- If not specified, the plugin will use the default location: vim.fn.stdpath('data') .. '/switchcolor.lua'.
            file_path = vim.fn.stdpath('config') .. '/color.lua'
        })
    end
}
```

### Usage

After installation, use these commands to switch and save:

```
:SwitchScheme <scheme_name>
:SwitchBackground <background_name>
```
