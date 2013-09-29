"=============================================================================
" File: quickhl.vim
" Author: t9md <taqumd@gmail.com>
" WebPage: http://github.com/t9md/vim-quickhl
" License: BSD
" Version: 0.5
"=============================================================================

" GUARD: {{{
"============================================================
" if exists('g:quickhl_dev')
  " unlet! g:loaded_quickhl
" endif

" if !exists('g:quickhl_debug')
  let g:quickhl_debug = 0
" endif

" if exists('g:loaded_quickhl')
  " finish
" endif
let g:loaded_quickhl = 1

let s:old_cpo = &cpo
set cpo&vim

if !hlexists("QuickhlTag")
  highlight QuickhlTag gui=underline cterm=underline term=underline
endif
if !hlexists("QuickhlCword")
  highlight link QuickhlCword Search
endif
"}}}

" GlobalVar: {{{
if !exists("g:quickhl_colors")
  let g:quickhl_colors = [
        \ "gui=bold ctermfg=16  ctermbg=153 guifg=#ffffff guibg=#0a7383",
        \ "gui=bold ctermfg=7   ctermbg=1   guibg=#a07040 guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=2   guibg=#4070a0 guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=3   guibg=#40a070 guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=4   guibg=#70a040 guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=5   guibg=#0070e0 guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=6   guibg=#007020 guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=21  guibg=#d4a00d guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=22  guibg=#06287e guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=45  guibg=#5b3674 guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=16  guibg=#4c8f2f guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=50  guibg=#1060a0 guifg=#ffffff",
        \ "gui=bold ctermfg=7   ctermbg=56  guibg=#a0b0c0 guifg=black",
        \ ]
  " let g:quickhl_match_color = "term=underline cterm=underline guibg=#293739"
endif

let s:default_settings = {
      \ "g:quickhltag_enable_at_startup": 0,
      \ "g:quickhltag_hl_priority": 9,
      \ "g:quickhlcword_enable_at_startup": 0,
      \ "g:quickhluser_enable_at_startup": 0,
      \ "g:quickhl_keywords": [],
      \ }

function! s:set_default(dict)
  for [var, val] in items(a:dict)
    if !exists(var)
      let {var} = val
    endif
    unlet! var val
  endfor
endfunction

call s:set_default(s:default_settings)

"}}}

" Keymap: {{{
nnoremap <silent> <Plug>(quickhl-user-toggle) :call quickhl#user_toggle('n')<CR>
vnoremap <silent> <Plug>(quickhl-user-toggle) :call quickhl#user_toggle('v')<CR>
nnoremap <silent> <Plug>(quickhl-user-reset)  :call quickhl#user_reset()<CR>
vnoremap <silent> <Plug>(quickhl-user-reset)  :call quickhl#user_reset()<CR>

command!                QuickhlList           :call quickhl#user_list()
command!                QuickhlDump           :call quickhl#user_dump()
command!                QuickhlReset          :call quickhl#user_reset()
command!                QuickhlColors         :call quickhl#user_colors()
command! -bang -nargs=1 QuickhlAdd            :call quickhl#user_add(<q-args>,<bang>0)
command! -bang -nargs=* QuickhlDel            :call quickhl#user_del(<q-args>,<bang>0)
command!                QuickhlUserEnable     :call quickhl#user_enable()
command!                QuickhlUserDisable    :call quickhl#user_disable()


nnoremap <silent> <Plug>(quickhl-cword-toggle)  :call quickhl#cword_toggle()<CR>
nnoremap <silent> <Plug>(quickhl-cword-enable)  :call quickhl#cword_enable()<CR>
nnoremap <silent> <Plug>(quickhl-cword-disable) :call quickhl#cword_disable()<CR>

command! QuickhlCwordToggle  :call quickhl#cword_toggle()
command! QuickhlCwordEnable  :call quickhl#cword_enable()
command! QuickhlCwordDisable :call quickhl#cword_disable()

nnoremap <silent> <Plug>(quickhl-tag-toggle)     :call quickhl#tag_toggle()<CR>
nnoremap <silent> <Plug>(quickhl-tag-enable)     :call quickhl#tag_enable()<CR>
nnoremap <silent> <Plug>(quickhl-tag-disable)    :call quickhl#tag_disable()<CR>

command! QuickhlTagToggle   :call quickhl#tag_toggle()
command! QuickhlTagEnable   :call quickhl#tag_enable()
command! QuickhlTagDisable  :call quickhl#tag_disable()

"}}}

" AutoCmd: {{{
augroup QuickhlHL
  autocmd!
  autocmd VimEnter,WinEnter * call quickhl#user_refresh()
  autocmd TabEnter *
        \   if exists(':Tcolorscheme')
        \ |   call quickhl#init_highlight()
        \ | endif
  autocmd! ColorScheme * call quickhl#user_init_highlight()
augroup END

if g:quickhlcword_enable_at_startup
  call quickhl#cword_enable()
endif
if g:quickhltag_enable_at_startup
  call quickhl#tag_enable()
endif
"}}}

" FINISH: {{{
let &cpo = s:old_cpo
"}}}
" vim: set fdm=marker:
