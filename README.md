## vim-timber: minimal logger.

In normal mode, log the word (cexpr) under the cursor.
For more information on cexpr, see `:help <cexpr>`

In visual mode, the selection is stripped of whitespace and logged. This can turn a multiline object into a single line that can be logged.

Consider the below javascript example:
```javascript
function someFunc({
    hello,
    world
}) { ... }
```
If we select the arguments of the function `someFunc` and log it with timber, we would get the following:
```javascript
console.log(`{ hello, world }: `, { hello, world });
```

### Mappings

By default, vim-timber doesn't create any mappings.

Mappings can be done however you would like. Please see config below for more information on how mappings can be modified to your liking.

A basic mapping can look like the following:
```vim
nmap <leader>ll <Plug>(TimberLog)
nmap <leader>li <Plug>(TimberLogInfo)
nmap <leader>lw <Plug>(TimberLogWarning)
nmap <leader>le <Plug>(TimberLogError)
nmap <leader>lc <Plug>(TimberLogCustom)
xmap <leader>ll <Plug>(TimberLog)
xmap <leader>li <Plug>(TimberLogInfo)
xmap <leader>lw <Plug>(TimberLogWarning)
xmap <leader>le <Plug>(TimberLogError)
xmap <leader>lc <Plug>(TimberLogCustom)
```

### Config

All "template strings" can be overwritten using configuration, which is placed in your `.vimrc` / `init.vim`.
Here's an example of how we could change the "custom" javascript log:

```vim
let g:timber_javascript_format_custom = "console.log(`This is a custom log: `, {{value}})"
```

For each language supported, there will be a minimum of two options available to you; the default log, and the custom log.

Note that the string `{{value}}` will be replaced with either the visual selection, or the word under the cursor.

Below is an exhaustive list of options you can set via global variables in your vim config. These are the defaults, and all can be overwritten.
```vim
" javascript
let g:timber_javascript_format         = "console.log(`{{value}}: `, {{value}});"
let g:timber_javascript_format_info    = "console.info(`{{value}}: `, {{value}});"
let g:timber_javascript_format_warning = "console.warn(`{{value}}: `, {{value}});"
let g:timber_javascript_format_error   = "console.error(`{{value}}: `, {{value}});"
let g:timber_javascript_format_custom  = "console.log(`{{value}}: `, {{value}});"

" vim
let g:timber_vim_format                = "echo \"{{value}}: \" . {{value}}"
let g:timber_vim_format_info           = "echom \"{{value}}: \" . {{value}}"
let g:timber_vim_format_custom         = "echo \"{{value}}: \" . {{value}}"

" python
let g:timber_python_format             = "print \"{{value}}: \", {{value}}"
let g:timber_python_format_custom      = "print \"{{value}}: \", {{value}}"

" dart
let g:timber_dart_format               = "print(\"{{value}}: ${{{value}}}\")"
let g:timber_dart_format_custom        = "print(\"{{value}}: ${{{value}}}\")"
```

### Todos

- [x] Log visual selection (and join multiline to a single line)
- [x] Log the word under the cursor 
- [x] Ability to customise the template string
- [x] Ability to use various logging methods, i.e. "log", "warn", "err", "info", "echo", "echom"
- [ ] Support for languages:
  - [x] javascript
  - [x] vim
  - [x] python
  - [x] dart
  - [ ] c
  - [ ] c++
  - [ ] java
  - [ ] ...
