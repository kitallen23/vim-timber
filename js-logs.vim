" if exists("g:loaded_jslogs") || &cp
"     finish
" endif

let g:loaded_jslogs = 100   " version number
let s:global_cpo = &cpo     " store compatible-mode in local variable
set cpo&vim                 " go into nocompatible-mode

function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function s:get_word_under_cursor()
    return expand("<cWORD>")
endfunction

function s:LogWordUnderCursor()
    let l:initial_position = getpos(".")
    let l:marks = "`"
    let l:text = s:get_word_under_cursor()

    let l:trimmed_text = substitute(l:text, "\n *", " ", "g")
    let l:final_text = substitute(l:trimmed_text, "^ *", "", "g")

    let l:fulltext = "console.log(" . l:marks . l:final_text . ": " . l:marks . ", " . l:final_text . ");"

    exec "normal! o" . l:fulltext
    call setpos(".", l:initial_position)
endfunction

function s:LogVisualSelection()
    let l:initial_position = getpos("'<")
    let l:marks = "`"
    let l:text = s:get_visual_selection()

    let l:trimmed_text = substitute(l:text, "\n *", " ", "g")
    let l:final_text = substitute(l:trimmed_text, "^ *", "", "g")

    let l:fulltext = "console.log(" . l:marks . l:final_text . ": " . l:marks . ", " . l:final_text . ");"

    exec "normal! o" . l:fulltext
    call setpos(".", l:initial_position)
    echo mode()
endfunction

command! -range LogSelection call s:LogVisualSelection()
command! LogWordUnderCursor call s:LogWordUnderCursor()

let &cpo = s:global_cpo
unlet s:global_cpo
