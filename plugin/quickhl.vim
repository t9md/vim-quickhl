" GUARD: {{{
"============================================================
let g:quickhl_debug = 0

if exists('g:loaded_quickhl') && exists('g:quickhl_dev') && !g:quickhl_dev
  finish
endif
let g:loaded_quickhl = 1
"for line continuation - i.e dont want C in &cpo
let s:old_cpo = &cpo
set cpo&vim

"}}}

" ColorList: {{{
if !exists("g:quickhl_colors")
    let g:quickhl_colors = [
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
endif
"}}}

" Keymap: "{{{
nnoremap <silent> <Plug>(quickhl#toggle) :call quickhl#toggle('n')<CR>
vnoremap <silent> <Plug>(quickhl#toggle) :call quickhl#toggle('v')<CR>
nnoremap <silent> <Plug>(quickhl#reset)  :call quickhl#reset()<CR>
vnoremap <silent> <Plug>(quickhl#reset)  :call quickhl#reset()<CR>

nnoremap <silent> <Plug>(quickhl#match) :call quickhl#match('n','toggle')<CR>
vnoremap <silent> <Plug>(quickhl#match) :call quickhl#match('v','toggle')<CR>
"}}}

" Command: "{{{
command! QuickhlList          :call quickhl#list()
command! QuickhlReset         :call quickhl#reset()
command! QuickhlColors        :call quickhl#colors()
command! QuickhlRefresh       :call quickhl#refresh()
command! -nargs=1 QuickhlAdd  :call quickhl#add(<q-args>)
command! -nargs=1 QuickhlDel  :call quickhl#del(<q-args>)

command! QuickhlMatch         :call quickhl#match('n',"on")
command! QuickhlMatchClear    :call quickhl#match('n',"clear")
command! QuickhlMatchAuto     :call <SID>quickhl_match_auto()
command! QuickhlMatchManual   :call <SID>quickhl_match_manual()

"}}}

" AutoCmd: {{{
function! s:quickhl_match_auto()
  augroup QuickhlMatch
      autocmd CursorMoved <buffer> call quickhl#match('n',"on")
  augroup end
endfunction

function! s:quickhl_match_manual()
  augroup QuickhlMatch
      autocmd!
  augroup end
endfunction
"}}}
" FINISH: {{{
let &cpo = s:old_cpo
"}}}
" vim: set sw=4 sts=4 et fdm=marker:
