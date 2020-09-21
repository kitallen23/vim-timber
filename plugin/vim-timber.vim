" if exists("g:loaded_jslogs") || &cp
"     finish
" endif

let g:loaded_jslogs = 100   " version number
let s:global_cpo = &cpo     " store compatible-mode in local variable
set cpo&vim                 " go into nocompatible-mode

" Language-specific template strings
let s:timber_lang_map = {
    \ "javascript":  {
        \ "default": get(g:, "timber_javascript_format",         "console.log(`{{value}}: `, {{value}});"),
        \ "info":    get(g:, "timber_javascript_format_info",    "console.info(`{{value}}: `, {{value}});"),
        \ "warning": get(g:, "timber_javascript_format_warning", "console.warn(`{{value}}: `, {{value}});"),
        \ "error":   get(g:, "timber_javascript_format_error",   "console.error(`{{value}}: `, {{value}});"),
        \ "custom":  get(g:, "timber_javascript_format_custom",  "console.log(`{{value}}: `, {{value}});"),
    \ },
    \ "vim": {
        \ "default": get(g:, "timber_vim_format",        "echo \"{{value}}: \" . {{value}}"),
        \ "info":    get(g:, "timber_vim_format_info",   "echom \"{{value}}: \" . {{value}}"),
        \ "custom":  get(g:, "timber_vim_format_custom", "echo \"{{value}}: \" . {{value}}"),
    \ }
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

" Collapse multiple lines into one, in preparation to be logged on one line
function s:format_logging_text(text)
    let l:trimmed_text = substitute(a:text, "\n *", " ", "g")
    let l:final_text = substitute(l:trimmed_text, "^ *", "", "g")
    return l:final_text
endfunction

" Get the language-specific log string and interpolate the value
function s:interpolate_text(value, key)
    let l:lang_group = get(s:timber_lang_map, &filetype, "")
    let l:template = get(l:lang_group, a:key, l:lang_group["default"])
    return substitute(l:template, "{{value}}", a:value, "g")
endfunction

" Log the word under the cursor
function s:LogWordUnderCursor(key)
    let l:initial_position = getpos(".")

    let l:cursor_word = s:get_word_under_cursor()
    let l:interpolated_text = s:interpolate_text(l:cursor_word, a:key)

    exec "normal! o" . l:interpolated_text
    call setpos(".", l:initial_position)
endfunction

" Log the user's visual selection
function s:LogVisualSelection(key)
    let l:initial_position = getpos("'<")
    let l:final_position = getpos("'>")

    let l:selected_text = s:get_visual_selection()
    let l:formatted_selection = s:format_logging_text(l:selected_text)
    let l:interpolated_text = s:interpolate_text(l:formatted_selection, a:key)

    call setpos(".", l:final_position)
    exec "normal! o" . l:interpolated_text
    call setpos(".", l:initial_position)
endfunction

function s:ClearLogs()
    %s/*console*/abc/gc
    " let l:initial_position = getpos("'<")
    " normal! gg
    " let l:current_search_res = search("console", "W")
    " let l:search_results = []
    " echo l:res


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

nnoremap <Plug>(TimberLog)        :call <SID>LogWordUnderCursor("default")<CR>
nnoremap <Plug>(TimberLogInfo)    :call <SID>LogWordUnderCursor("info")<CR>
nnoremap <Plug>(TimberLogWarning) :call <SID>LogWordUnderCursor("warning")<CR>
nnoremap <Plug>(TimberLogError)   :call <SID>LogWordUnderCursor("error")<CR>
nnoremap <Plug>(TimberLogCustom)  :call <SID>LogWordUnderCursor("custom")<CR>
xnoremap <Plug>(TimberLog)        :call <SID>LogVisualSelection("default")<CR>
xnoremap <Plug>(TimberLogInfo)    :call <SID>LogVisualSelection("info")<CR>
xnoremap <Plug>(TimberLogWarning) :call <SID>LogVisualSelection("warning")<CR>
xnoremap <Plug>(TimberLogError)   :call <SID>LogVisualSelection("error")<CR>
xnoremap <Plug>(TimberLogCustom)  :call <SID>LogVisualSelection("custom")<CR>

let &cpo = s:global_cpo
unlet s:global_cpo
