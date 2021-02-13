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
        \ "delete":  get(g:, "timber_javascript_formats_delete", ["console.log", "//\\s*console.log"]),
    \ },
    \ "typescript":  {
        \ "default": get(g:, "timber_typescript_format",         "console.log(`{{value}}: `, {{value}});"),
        \ "info":    get(g:, "timber_typescript_format_info",    "console.info(`{{value}}: `, {{value}});"),
        \ "warning": get(g:, "timber_typescript_format_warning", "console.warn(`{{value}}: `, {{value}});"),
        \ "error":   get(g:, "timber_typescript_format_error",   "console.error(`{{value}}: `, {{value}});"),
        \ "custom":  get(g:, "timber_typescript_format_custom",  "console.log(`{{value}}: `, {{value}});"),
        \ "delete":  get(g:, "timber_typescript_formats_delete", ["console.log", "//\\s*console.log"]),
    \ },
    \ "vim": {
        \ "default": get(g:, "timber_vim_format",         "echo \"{{value}}: \" . {{value}}"),
        \ "info":    get(g:, "timber_vim_format_info",    "echom \"{{value}}: \" . {{value}}"),
        \ "custom":  get(g:, "timber_vim_format_custom",  "echo \"{{value}}: \" . {{value}}"),
        \ "delete":  get(g:, "timber_vim_formats_delete", ["echo", "\"\\s*echo"]),
    \ },
    \ "dart": {
        \ "default": get(g:, "timber_dart_format",         "print(\"{{value}}: ${{{value}}}\")"),
        \ "custom":  get(g:, "timber_dart_format_custom",  "print(\"{{value}}: ${{{value}}}\")"),
        \ "delete":  get(g:, "timber_dart_formats_delete", ["print("]),
    \ },
    \ "python": {
        \ "default": get(g:, "timber_python_format",         "print \"{{value}}: \", {{value}}"),
        \ "custom":  get(g:, "timber_python_format_custom",  "print \"{{value}}: \", {{value}}"),
        \ "delete":  get(g:, "timber_python_formats_delete", ["print "]),
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

" Get the language-specific string and interpolate the value
function s:get_delete_formats()
    let l:lang_group = get(s:timber_lang_map, &filetype, "")
    let l:formats = get(l:lang_group, "delete", [])
    let l:interpolated_formats = []

    for format in l:formats
        let l:interpolated_formats = add(l:interpolated_formats, "^\\s*" . format . "*")
    endfor

    return l:interpolated_formats
endfunction

function! s:ClearLogs() abort
    " Store our initial position
    let l:initial_position = getpos(".")

    let l:search_terms = s:get_delete_formats()
    let l:search_results = {}

    " Loop over each search term
    for search_term in l:search_terms
        " Go to start of file, do a full search for each search term
        normal! gg

        let l:current_search_res = -1
        " Loop over each result and add it to a map
        while l:current_search_res != 0
            let l:current_search_res = search(search_term, "W")
            if l:current_search_res != 0
                let l:search_results[l:current_search_res] = 1
            endif
        endwhile
        let l:current_search_res = -1
    endfor

    " Sort result map into a list
    let l:result_list = sort(keys(l:search_results))
    let l:user_input = confirm("This is a test. Yes?", "&yes, &no, &cancel")
    echo l:user_input

    " for result in l:result_list
    "     call setpos(".", [l:initial_position[0], result, l:initial_position[2], l:initial_position[3]])
    "     let l:choice = confirm("Delete line?", "&yes, &no, &cancel", 1)
    "     echo l:choice
    " endfor

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
    call setpos(".", l:initial_position)
endfunction

command! -range TimberLogWordDefault      :call s:LogWordUnderCursor("default")
command! -range TimberLogWordInfo         :call s:LogWordUnderCursor("info")
command! -range TimberLogWordWarning      :call s:LogWordUnderCursor("warning")
command! -range TimberLogWordError        :call s:LogWordUnderCursor("error")
command! -range TimberLogWordCustom       :call s:LogWordUnderCursor("custom")

command! -range TimberLogSelectionDefault :call s:LogVisualSelection("default")
command! -range TimberLogSelectionInfo    :call s:LogVisualSelection("info")
command! -range TimberLogSelectionWarning :call s:LogVisualSelection("warning")
command! -range TimberLogSelectionError   :call s:LogVisualSelection("error")
command! -range TimberLogSelectionCustom  :call s:LogVisualSelection("custom")

nnoremap <Plug>(TimberLog)        :TimberLogWordDefault<CR>
nnoremap <Plug>(TimberLogInfo)    :TimberLogWordInfo<CR>
nnoremap <Plug>(TimberLogWarning) :TimberLogWordWarning<CR>
nnoremap <Plug>(TimberLogError)   :TimberLogWordError<CR>
nnoremap <Plug>(TimberLogCustom)  :TimberLogWordCustom<CR>
xnoremap <Plug>(TimberLog)        :TimberLogSelectionDefault<CR>
xnoremap <Plug>(TimberLogInfo)    :TimberLogSelectionInfo<CR>
xnoremap <Plug>(TimberLogWarning) :TimberLogSelectionWarning<CR>
xnoremap <Plug>(TimberLogError)   :TimberLogSelectionError<CR>
xnoremap <Plug>(TimberLogCustom)  :TimberLogSelectionCustom<CR>

command! -range TimberClear :call s:ClearLogs()
let &cpo = s:global_cpo
unlet s:global_cpo
