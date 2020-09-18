# vim-js-logs

Minimal logger for js. 

Log the selected `text` or the `WORD` under the buffer as ``console.log(`name: `, name)``

## Commands:
1. LogSelection
2. LogWordUnderCursor

Has one config option: 
1. g:js_logging_string_format (default: `` ` `` )

## Config
Map the commands in visual and normal mode as
```vim
nnoremap <leader>l :LogWordUnderCursor<cr>
xnoremap <leader>l :LogSelection<cr>
```

logging string format as 
```
let g:js_logging_string_format = '"'
```

## Todos

- [x] Log visual selection (and join multiline to a single line)
- [x] Log the word under the cursor 
- [x] Config options for:
  - [x] String type to wrap the "label", i.e. `` ` ``, ` ' `, ` " `
  - [ ] Separator between the logged text and the end of the "label" string, i.e. `: `
- [ ] Ability to pass the console function to use as a parameter, i.e. "log", "warn", "err", "info"
