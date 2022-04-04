#!/usr/bin/env lua

-- Vimscript version
-- let s:chars = [ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '%', '`', '?' ]
-- for char in s:chars
--     for mode in [ 'xnoremap', 'onoremap' ]
--         execute printf('%s i%s :<C-u>silent normal! T%svt%s<CR>', mode, char, char, char)
--         execute printf('%s a%s :<C-u>normal! F%svf%s<CR>', mode, char, char, char)
--     endfor
-- endfor


function basic_text_objects()
    local chars = { '_', '.', ':', ',', ';', '|', '/', '\\', '*', '+', '%', '`', '?' }
    for _,char in ipairs(chars) do
        for _,mode in ipairs({ 'x', 'o' }) do
            nremap(mode, 'i'..char, string.format(':<C-u>silent! normal! f%sF%slvt%s<CR>', char, char, char))
            nremap(mode, 'a'..char, string.format(':<C-u>silent! normal! f%sF%svf%s<CR>', char, char, char))
        end
    end
end

function select_indent(around)
    if string.match(vim.fn.getline('.'), blank_line_pattern) then
        return
    end

    local start_indent = vim.fn.indent(vim.fn.line('.'))
    if vim.v.count > 0 then
        start_indent = start_indent - vim.o.shiftwidth * (vim.v.count - 1)
        if start_indent < 0 then
            start_indent = 0
        end
    end
    local blank_line_pattern = '^%s*$'

    local prev_line = vim.fn.line('.') - 1
    local prev_blank_line = function(line) return string.match(vim.fn.getline(line), blank_line_pattern) end
    while prev_line > 0 and (prev_blank_line(prev_line) or vim.fn.indent(prev_line) >= start_indent) do
        vim.cmd('-')
        prev_line = vim.fn.line('.') - 1
    end
    if around then
        vim.cmd('-')
    end

    vim.cmd('normal! 0V')

    local next_line = vim.fn.line('.') + 1
    local next_blank_line = function(line) return string.match(vim.fn.getline(line), blank_line_pattern) end
    local last_line = vim.fn.line('$')
    while next_line <= last_line and (next_blank_line(next_line) or vim.fn.indent(next_line) >= start_indent) do
        vim.cmd('+')
        next_line = vim.fn.line('.') + 1
    end
    if around then
        vim.cmd('+')
    end
end

function indent_text_objects()
    for _,mode in ipairs({ 'x', 'o' }) do
        nremap(mode, 'ii', ':<c-u>lua select_indent()<cr>')
        nremap(mode, 'ai', ':<c-u>lua select_indent(true)<cr>')
    end
end

return {
    basic_text_objects = basic_text_objects,
    indent_text_objects = indent_text_objects,
}