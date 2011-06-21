Screen capture
-----------------------------------------------------------------
![quickhl.png](https://github.com/t9md/t9md/raw/master/img/quickhl.png)

Command
-----------------------------------------------------------------
* QuickhlList           
    Show registerd keyword list with color.
* QuickhlReset
    Reset all.
* QuickhlShowColors
    Check colors.
* QuickhlAdd  word
    Add word.
* QuickhlDel  word
    Delete word.

KeyMap Example
-----------------------------------------------------------------
    nmap <Space>m <Plug>(quickhl#toggle)
    vmap <Space>m <Plug>(quickhl#toggle)
    nmap <Space>M <Plug>(quickhl#reset)

Highlight 't9md' on all buffers.
-----------------------------------------------------------------
    augroup Quickhl
      autocmd!
      autocmd! BufEnter * call s:init_quickhl()
    augroup END

    function! s:init_quickhl()
        QuickhlAdd t9md
        QuickhlRefresh
    endfunction

Change Colors
-----------------------------------------------------------------
If you want to change default color, set `g:quickhl_colors` array like following in your `.vimrc`.

    let g:quickhl_colors = [
          \ "gui=bold ctermfg=255 ctermbg=153 guifg=#ffffff guibg=#0a7383",
          \ "gui=bold guibg=#a07040 guifg=#ffffff",
          \ "gui=bold guibg=#4070a0 guifg=#ffffff",
          \ ]

