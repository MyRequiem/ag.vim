" s:showError() - error message output {{{1
function! s:showError(str)
    echohl SpecialKey | echo a:str | echohl NONE
endfunction " 1}}}

" s:showQuickFixWindow(str) - display quickfix window and highlight matches {{{1
function! s:showQuickFixWindow(str)
    execute 'copen ' . g:ag_quickfix_height
    " clear and redraw the screen after running 'ag' with the command 'silent'
    execute ':redraw!'

    " if the windows on the screen are divided vertically, then after opening
    " quickfix window with the command ':copen', it is placed by default at the
    " bottom of the rightmost window. Move it up or down full width:
    execute "normal! \<C-w>" . (g:ag_quickfix_window_on_top ? 'K' : 'J')

    " highlight matches
    if g:ag_highlight_matches
        let l:matchstr = substitute(a:str, '\', '\\\\', 'g')
        let l:matchstr = substitute(l:matchstr, ']', '\\]', 'g')
        if exists('g:ag_highlight_color') &&  !empty(g:ag_highlight_color)
            execute g:ag_highlight_color
        endif
        call matchadd('AgMatches', l:matchstr, -1)
    endif
endfunction " 1}}}

" s:execAg(pattern) - launch 'ag' {{{1
function! s:execAg(pattern)
    let l:grepprg_save     = &grepprg
    let l:errorformat_save = &errorformat

    let &grepprg = 'ag ' . join(g:ag_param)
    let &errorformat = g:ag_err_format

    try
        execute 'normal! :silent grep! -R ' . a:pattern . "\<cr>"
    catch
    endtry

    let &grepprg     = l:grepprg_save
    let &errorformat = l:errorformat_save
endfunction " 1}}}

" s:substitute_param(str) - processing selected text {{{1
function! s:substitute_param(str)
        let l:str = substitute(a:str, '\', '\\\', 'g')
        let l:str = substitute(l:str, "\\.", '\\.', 'g')
        let l:str = substitute(l:str, '(', '\\(', 'g')
        let l:str = substitute(l:str, ')', '\\)', 'g')
        let l:str = substitute(l:str, '[', '\\[', 'g')
        let l:str = substitute(l:str, '#', '\\#', 'g')
        let l:str = substitute(l:str, '%', '\\%', 'g')
        let l:str = substitute(l:str, '-', '\\-', 'g')

        return l:str
endfunction " 1}}}

function! s:findMathesAndShowResults(pattern, str)
    call <SID>execAg(a:pattern)
    call <SID>showQuickFixWindow(a:str)
endfunction

" ag#Ag(nmode) {{{1
function! ag#Ag(nmode) range
    " selection text should be on only one line
    if a:firstline !=# a:lastline
        call <SID>showError("Selection for 'ag' should be only on one line")
        return
    endif

    if a:nmode
        let l:param = expand('<cword>')
        let l:pattern = <SID>substitute_param(shellescape(l:param))
    elseif visualmode() =~# "^[v\<C-v>]"
        " save the value of unnamed register '@'
        " and copy the selected text into it
        let l:saved_unnamed_register = @@
        normal! `<v`>y
        let l:param = @@
        " restore register '@'
        let @@ = l:saved_unnamed_register

        let l:pattern = <SID>substitute_param(shellescape(l:param))
    else
        call <SID>showError("Visual line-wise mode is not allowed for 'ag'")
        return
    endif

    call <SID>findMathesAndShowResults(l:pattern, l:param)
endfunction " 1}}}

" ag#AgCommand(...) - launch 'ag' from command line {{{1
function! ag#AgCommand(...)
    if !len(a:000)
        call <SID>showError("'ag' parameters not found")
        return
    endif

    let l:param = join(a:000)
    let l:pattern = <SID>substitute_param(shellescape(l:param))
    call <SID>findMathesAndShowResults(l:pattern, l:param)
endfunction " 1}}}
