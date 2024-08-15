vim = vim

local M = {}

local function validate_scheme(scheme)
    local schemes = vim.fn.getcompletion('', 'color')
    return vim.tbl_contains(schemes, scheme) and scheme
end

local function validate_background(background)
    local backgrounds = { 'dark', 'light' }
    return vim.tbl_contains(backgrounds, background) and background
end

local function apply_settings(scheme, background)
    vim.cmd('colorscheme ' .. scheme)
    vim.o.background = background
end

local function load_settings(file_path)
    if vim.fn.filereadable(file_path) == 1 then
        local ok, err = pcall(dofile, file_path)
        if not ok then
            print("Error loading settings: " .. err)
        end
    end
end

function M.init(config)
    config = config or {}

    config.file_path = config.file_path or vim.fn.stdpath('data') .. '/switchcolor.lua'

    load_settings(config.file_path)

    config.scheme = validate_scheme(config.scheme or vim.g.colors_name or 'default')
    config.background = validate_background(config.background or vim.o.background or 'dark')

    apply_settings(config.scheme, config.background)

    return config
end

function M.save_color(config)
    local file = io.open(config.file_path, 'w')
    if file then
        local content_table = {
            string.format('vim.cmd.colorscheme %s', config.scheme),
            string.format('vim.o.background = "%s"', config.background),
        }
        local content = table.concat(content_table, '\n') .. '\n'
        file:write(content)
        file:close()
    else
        print("Failed to open file for writing:", config.file_path)
    end
end

function M.fuzzy_match(str, pattern)
    pattern = pattern:lower():gsub(".", function(c)
        return string.format("%s.*", vim.pesc(c))
    end)
    return str:lower():match(pattern) ~= nil
end

function M.get_schemes(prefix)
    local all_schemes = vim.fn.getcompletion('', 'color')
    local filtered_schemes = {}
    for _, scheme in ipairs(all_schemes) do
        if M.fuzzy_match(scheme, prefix) then
            table.insert(filtered_schemes, scheme)
        end
    end
    return filtered_schemes
end

function M.get_backgrounds(prefix)
    local backgrounds = { 'dark', 'light' }
    local filtered_backgrounds = {}
    for _, bg in ipairs(backgrounds) do
        if M.fuzzy_match(bg, prefix) then
            table.insert(filtered_backgrounds, bg)
        end
    end
    return filtered_backgrounds
end

function M.set_color(scheme, background, config)
    scheme = (scheme and validate_scheme(scheme)) or config.scheme
    background = (background and validate_background(background)) or config.background
    apply_settings(scheme, background)
end

function M.run(config)
    config = M.init(config)

    vim.api.nvim_create_user_command('SwitchScheme', function(opts)
        local scheme = opts.args
        config.scheme = validate_scheme(scheme) or config.scheme
        M.save_color(config)
        M.set_color(config.scheme, config.background, config)
    end, {
        nargs = 1,
        complete = function(arg_lead)
            return M.get_schemes(arg_lead)
        end,
    })

    vim.api.nvim_create_user_command('SwitchBackground', function(opts)
        local background = opts.args
        config.background = validate_background(background) or config.background
        M.save_color(config)
        M.set_color(config.scheme, config.background, config)
    end, {
        nargs = 1,
        complete = function(arg_lead)
            return M.get_backgrounds(arg_lead)
        end,
    })

    vim.api.nvim_create_autocmd('CmdlineChanged', {
        pattern = '*',
        callback = function()
            local cmd_line = vim.fn.getcmdline()
            if cmd_line:match('^SwitchScheme%s+%S+') then
                local args = cmd_line:match('^SwitchScheme%s+(%S+)')
                M.set_color(args, config.background, config)
            elseif cmd_line:match('^SwitchBackground%s+%S+') then
                local args = cmd_line:match('^SwitchBackground%s+(%S+)')
                M.set_color(config.scheme, args, config)
            end
        end,
    })

    vim.api.nvim_create_autocmd('CmdlineLeave', {
        pattern = '*',
        callback = function()
            local cmd_line = vim.fn.getcmdline()
            if cmd_line:match('^SwitchScheme%s+%S+') then
                M.set_color(config.scheme, config.background, config)
            end
            if cmd_line:match('^SwitchBackground%s+%S+') then
                M.set_color(config.scheme, config.background, config)
            end
        end,
    })
end

function M.setup(config)
    vim.schedule(function()
        M.run(config)
    end)
end

return M
