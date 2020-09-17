# vim-js-logs

Minimal logger for js. Log the selected text or the `WORD` under the buffer as ``console.log(`name :`, name)``

## Commands:
1. LogSelection
2. LogWordUnderCursor

Has one config option: 
1. js_logging_string_format (default: `` `...` `` )

## Config
Map the commands in visual and normal mode as
```
nnoremap <leader>l :LogWordUnderCursor<cr>
xnoremap <leader>l :LogSelection<cr>
```

logging string format as 
```
let js_logging_string_format = '"'
```