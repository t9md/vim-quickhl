"=============================================================================
" File: quickhl.vim
" Author: t9md <taqumd@gmail.com>
" WebPage: http://github.com/t9md/vim-quickhl
" License: BSD
" Version: 1.0
"=============================================================================
" GUARD: {{{
if !exists('g:quickhl_debug')
  let g:quickhl_debug = 0
endif

if exists('g:loaded_quickhl')
  finish
endif
let g:loaded_quickhl = 1

let s:old_cpo = &cpo
set cpo&vim
" }}}

" GlobalVar: {{{
if !exists("g:quickhl_manual_colors")
  let g:quickhl_manual_colors = [
        \ "cterm=bold ctermfg=16 ctermbg=153 gui=bold guifg=#ffffff guibg=#0a7383",
        \ "cterm=bold ctermfg=7  ctermbg=1   gui=bold guibg=#a07040 guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=2   gui=bold guibg=#4070a0 guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=3   gui=bold guibg=#40a070 guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=4   gui=bold guibg=#70a040 guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=5   gui=bold guibg=#0070e0 guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=6   gui=bold guibg=#007020 guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=21  gui=bold guibg=#d4a00d guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=22  gui=bold guibg=#06287e guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=45  gui=bold guibg=#5b3674 guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=16  gui=bold guibg=#4c8f2f guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=50  gui=bold guibg=#1060a0 guifg=#ffffff",
        \ "cterm=bold ctermfg=7  ctermbg=56  gui=bold guibg=#a0b0c0 guifg=black",
        \ ]
endif

let s:default_settings = {
      \ "g:quickhl_manual_enable_at_startup": 0,
      \ "g:quickhl_manual_keywords": [],
      \ "g:quickhl_manual_hl_priority": 10,
      \ "g:quickhl_tag_enable_at_startup": 0,
      \ "g:quickhl_tag_hl_command": 'QuickhlTag gui=underline cterm=underline term=underline',
      \ "g:quickhl_tag_hl_priority": 9,
      \ "g:quickhl_tag_minimum_identifier": 4,
      \ "g:quickhl_cword_enable_at_startup": 0,
      \ "g:quickhl_cword_hl_command": 'link QuickhlCword Search',
      \ }

function! s:set_default(dict) "{{{
  for [var, val] in items(a:dict)
    if !exists(var) | let {var} = val | endif
    unlet! var val
  endfor
endfunction "}}}

call s:set_default(s:default_settings)

"}}}

" Keymap: {{{
nnoremap <silent> <Plug>(quickhl-manual-this) :call quickhl#manual#this('n')<CR>
vnoremap <silent> <Plug>(quickhl-manual-this) :call quickhl#manual#this('v')<CR>
nnoremap <silent> <Plug>(quickhl-manual-this-whole-word) :call quickhl#manual#this_whole_word('n')<CR>
vnoremap <silent> <Plug>(quickhl-manual-this-whole-word) :call quickhl#manual#this_whole_word('v')<CR>
nnoremap <silent> <Plug>(quickhl-manual-reset)  :call quickhl#manual#reset()<CR>
vnoremap <silent> <Plug>(quickhl-manual-reset)  :call quickhl#manual#reset()<CR>
nnoremap <silent> <Plug>(quickhl-manual-clear)  :call quickhl#manual#clear_this('n')<CR>
vnoremap <silent> <Plug>(quickhl-manual-clear)  :call quickhl#manual#clear_this('v')<CR>
nnoremap <silent> <Plug>(quickhl-manual-toggle) :call quickhl#manual#lock_toggle()<CR>
vnoremap <silent> <Plug>(quickhl-manual-toggle) :call quickhl#manual#lock_toggle()<CR>
nnoremap <silent> <Plug>(quickhl-manual-go-to-next) :call quickhl#manual#go_to_next('s')<CR>
nnoremap <silent> <Plug>(quickhl-manual-go-to-prev) :call quickhl#manual#go_to_prev('s')<CR>

nnoremap <silent> <Plug>(quickhl-cword-toggle)  :call quickhl#cword#toggle()<CR>
nnoremap <silent> <Plug>(quickhl-cword-enable)  :call quickhl#cword#enable()<CR>
nnoremap <silent> <Plug>(quickhl-cword-disable) :call quickhl#cword#disable()<CR>

nnoremap <silent> <Plug>(quickhl-tag-enable)     :call quickhl#tag#enable()<CR>
nnoremap <silent> <Plug>(quickhl-tag-disable)    :call quickhl#tag#disable()<CR>
nnoremap <silent> <Plug>(quickhl-tag-toggle)     :call quickhl#tag#toggle()<CR>

command!                QuickhlManualEnable       :call quickhl#manual#enable()
command!                QuickhlManualDisable       :call quickhl#manual#disable()

command!                QuickhlManualList    :call quickhl#manual#list()
"command!                QuickhlManualDump    :call quickhl#manual#dump()
command!                QuickhlManualReset   :call quickhl#manual#reset()
command!                QuickhlManualColors  :call quickhl#manual#colors()
command! -bang -nargs=1 QuickhlManualAdd     :call quickhl#manual#add(<q-args>,<bang>0)
command! -bang -nargs=* QuickhlManualDelete  :call quickhl#manual#del(<q-args>,<bang>0)
command!                QuickhlManualLock    :call quickhl#manual#lock()

command!       -nargs=? QuickhlManualGoToNext :call quickhl#manual#go_to_next(<f-args>)
command!       -nargs=? QuickhlManualGoToPrev :call quickhl#manual#go_to_prev(<f-args>)

command! QuickhlManualUnlock            :call quickhl#manual#unlock()
command! QuickhlManualLockToggle        :call quickhl#manual#lock_toggle()
command! QuickhlManualLockWindow        :call quickhl#manual#lock_window()
command! QuickhlManualUnlockWindow      :call quickhl#manual#unlock_window()
command! QuickhlManualLockWindowToggle  :call quickhl#manual#lock_window_toggle()

command! QuickhlCwordEnable  :call quickhl#cword#enable()
command! QuickhlCwordDisable :call quickhl#cword#disable()
command! QuickhlCwordToggle  :call quickhl#cword#toggle()

command! QuickhlTagEnable   :call quickhl#tag#enable()
command! QuickhlTagDisable  :call quickhl#tag#disable()
command! QuickhlTagToggle   :call quickhl#tag#toggle()
"}}}

try
  call operator#user#define('quickhl-manual-this-motion', 'quickhl#manual#this_motion')
catch /E117:/
endtry

if g:quickhl_cword_enable_at_startup
  call quickhl#cword#enable()
endif
if g:quickhl_tag_enable_at_startup
  call quickhl#tag#enable()
endif
if g:quickhl_manual_enable_at_startup
  call quickhl#manual#enable()
endif
"}}}

" FINISH: {{{
let &cpo = s:old_cpo
"}}}
" vim: set fdm=marker:
