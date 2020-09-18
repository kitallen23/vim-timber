" if exists("g:loaded_jslogs") || &cp
"     finish
" endif

let g:loaded_jslogs = 100   " version number
let s:global_cpo = &cpo     " store compatible-mode in local variable
set cpo&vim                 " go into nocompatible-mode

let s:timber_logging_string_format = get(g:, "timber_logging_string_format", "`")

" Language-specific format strings
let s:timber_lang_map = {
    \ "javascript": get(g:, "timber_javascript_format", "console.log(`{{value}}: `, {{value}});"),
    \ "vim": "echo {{value}}"
\ }

function! s:get_visual_selection()
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
    return expand("<cexpr>")
endfunction

function s:format_logging_text(text)
    let l:trimmed_text = substitute(a:text, "\n *", " ", "g")
    let l:final_text = substitute(l:trimmed_text, "^ *", "", "g")
    return l:final_text
endfunction

" Get the language-specific log string and interpolate the value
function s:interpolate_text(value)
    let l:template = get(s:timber_lang_map, &filetype, "")
    return substitute(l:template, "{{value}}", a:value, "g")
endfunction

function s:LogWordUnderCursor()
    let l:initial_position = getpos(".")

    let l:cursor_word = s:get_word_under_cursor()
    let l:interpolated_text = s:interpolate_text(l:cursor_word)

    exec "normal! o" . l:interpolated_text
    call setpos(".", l:initial_position)
endfunction

function s:LogVisualSelection()
    let l:initial_position = getpos("'<")
    let l:final_position = getpos("'>")

    let l:selected_text = s:get_visual_selection()
    let l:formatted_selection = s:format_logging_text(l:selected_text)
    let l:interpolated_text = s:interpolate_text(l:formatted_selection)

    call setpos(".", l:final_position)
    exec "normal! o" . l:interpolated_text
    call setpos(".", l:initial_position)
endfunction

function s:ClearLogs()
    let l:initial_position = getpos("'<")
    normal! gg
    let l:current_search_res = search("console", "W")
    let l:search_results = []
    echo l:res


    " PLAN:
    " 1. Store initial position
    " 2. Go to start of file
    " 3. Create array of all search results
    " 4. Loop over each search results, go to that line, ask for delete
    " confirmation
    " 5. Return cursor to previous pos


    " let choice = confirm("Delete line?", "&yes, &no, &cancel")
    " echo choice
    " %substitute/console/abc/gc
endfunction

command! -range TimberLogSelection call s:LogVisualSelection()
command! TimberLogWordUnderCursor call s:LogWordUnderCursor()
command! TimberClearLogs call s:ClearLogs()

let &cpo = s:global_cpo
unlet s:global_cpo
