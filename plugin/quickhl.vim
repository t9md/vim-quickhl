" GUARD: {{{
"============================================================
" if exists('g:loaded_quickhl')
  " finish
" endif
let g:loaded_quickhl = 1
"for line continuation - i.e dont want C in &cpo
let s:old_cpo = &cpo
set cpo&vim

"}}}

" ColorList: {{{
let g:quick_hl_colors = [
      \ "gui=bold ctermfg=255 ctermbg=153 guifg=#ffffff guibg=#0a7383",
      \ "gui=bold guibg=#a07040 guifg=#ffffff",
      \ "gui=bold guibg=#4070a0 guifg=#ffffff",
      \ "gui=bold guibg=#40a070 guifg=#ffffff",
      \ "gui=bold guibg=#70a040 guifg=#ffffff",
      \ "gui=bold guibg=#0070e0 guifg=#ffffff",
      \ "gui=bold guibg=#007020 guifg=#ffffff",
      \ "gui=bold guibg=#d4a00d guifg=#ffffff",
      \ "gui=bold guibg=#06287e guifg=#ffffff",
      \ "gui=bold guibg=#5b3674 guifg=#ffffff",
      \ "gui=bold guibg=#4c8f2f guifg=#ffffff",
      \ "gui=bold guibg=#1060a0 guifg=#ffffff",
      \ "gui=bold guibg=#a0b0c0 guifg=black",
      \ ]
"}}}

if !exists("g:quick_hl_colors")
    let g:quick_hl_colors = s:colors_default
endif

" Keymap: "{{{
nnoremap <silent> <Plug>(quickhl#toggle)    :call quickhl#toggle('n')<CR>
vnoremap <silent> <Plug>(quickhl#toggle)    :call quickhl#toggle('v')<CR>
nnoremap <silent> <Plug>(quickhl#clear_all) :call quickhl#clear_all()<CR>
vnoremap <silent> <Plug>(quickhl#clear_all) :call quickhl#clear_all()<CR>
"}}}

" Command: "{{{
command! QuickHLList          :call quickhl#list()
command! QuickHLClear         :call quickhl#clear_all()
command! QuickHLShowColors    :call quickhl#show_colors()
command! QuickHLRenewColors   :call quickhl#renew_colors()
command! -nargs=1 QuickHLAdd  :call quickhl#add(<q-args>)
command! -nargs=1 QuickHLDel  :call quickhl#delete(<q-args>)
"}}}

let g:quick_hl_debug = 0

" FINISH: {{{
let &cpo = s:old_cpo
"}}}
" vim: set sw=4 sts=4 et fdm=marker:
