let s:cword = {
      \ "enable": g:quickhl_cword_enable_at_startup,
      \ }

function! s:cword.init() "{{{
  call self.init_highlight()
endfunction "}}}

function! s:cword.init_highlight() "{{{
  exe "highlight ". escape(g:quickhl_cword_hl_command, '!|')
  " highlight link QuickhlCword Search
endfunction "}}}

function! s:cword.set() "{{{
  let pattern = quickhl#escape(expand('<cword>'))
  exe "2match QuickhlCword /\\\<". pattern . "\\\>/"
endfunction "}}}

function! s:cword.clear() "{{{
  silent! 2match none
endfunction "}}}

function! s:cword.refresh() "{{{
  call self.clear()
  if !self.enable | return | endif
  call self.set()
endfunction "}}}

function! quickhl#cword#init_highlight() "{{{
  call s:cword.init_highlight()
endfunction "}}}

function! quickhl#cword#enable() "{{{
  let s:cword.enable = 1
  augroup QuickhlCword
    autocmd!
    autocmd! CursorMoved <buffer> call quickhl#cword#refresh()
    autocmd! ColorScheme * call quickhl#cword#init_highlight()
  augroup END
  call quickhl#cword#init_highlight()
  call quickhl#cword#refresh()
endfunction "}}}

function! quickhl#cword#disable() "{{{
  let s:cword.enable = 0
  augroup QuickhlCword
    autocmd!
  augroup END
  autocmd! QuickhlCword
  call quickhl#cword#refresh()
endfunction "}}}

function! quickhl#cword#refresh() "{{{
  call s:cword.refresh()
endfunction "}}}

function! quickhl#cword#toggle() "{{{
  let s:cword.enable = !s:cword.enable
  if s:cword.enable
    call quickhl#cword#enable()
  else
    call quickhl#cword#disable()
  endif
endfunction "}}}

call s:cword.init()
" vim: foldmethod=marker
