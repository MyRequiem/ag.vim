" File:         ag.vim
" Type:         utility
" Version:      1.1
" Date:         20.08.19
" Author:       MyRequiem <mrvladislavovich@gmail.com>
" License:      MIT
" Description:  Allow you to run the_silver_searcher (ag) from Vim, and shows
" the results in a quickfix window

scriptencoding utf-8

if exists('g:loaded_ag') && g:loaded_ag
    finish
endif

let g:loaded_ag = 1

if !executable('ag')
    echoerr "Executable file 'ag' not found on your system"
    finish
endif

let g:ag_param = get(g:, 'ag_param',
                                    \ [
                                        \ '--nogroup',
                                        \ '--context=0',
                                        \ '--nocolor',
                                        \ '--filename',
                                        \ '--numbers',
                                        \ '--print-long-lines',
                                        \ '--silent',
                                        \ '--hidden',
                                        \ '--case-sensitive',
                                        \ '$*'
                                     \]
                    \)

let g:ag_hotkey                 = get(g:, 'ag_hotkey', '<leader>g')
let g:ag_quickfix_height        = get(g:, 'ag_quickfix_height', '10')
let g:ag_highlight_matches      = get(g:, 'ag_highlight_matches', 0)
let g:ag_err_format             = get(g:, 'ag_err_format', '%f:%l:%m')
let g:ag_quickfix_window_on_top = get(g:, 'ag_quickfix_window_on_top', 0)

if exists('g:ag_highlight_color') &&  !empty(g:ag_highlight_color)
    execute g:ag_highlight_color
else
    execute 'highlight AgMatches term=NONE cterm=NONE ctermfg=1 ' .
        \ 'ctermbg=NONE gui=NONE guisp=NONE guifg=#AA0000 guibg=NONE'
endif

execute 'noremap  <silent>' . g:ag_hotkey . ' :call ag#Ag(1)<cr>'
execute 'vnoremap <silent>' . g:ag_hotkey . ' :call ag#Ag(0)<cr>'

command -nargs=* Ag call ag#AgCommand(<f-args>)
