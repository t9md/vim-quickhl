let s:tag = {
      \ "name": "QuickhlTag",
      \ "enable":   g:quickhl_tag_enable_at_startup,
      \ }

function! s:tag.init() "{{{
  call self.init_highlight()
endfunction "}}}

function! s:tag.init_highlight() "{{{
  exe "highlight ". escape(g:quickhl_tag_hl_command, '!|')
  " highlight QuickhlTag gui=underline cterm=underline term=underline
endfunction "}}}

function! s:tag.set() "{{{
  let taglist = taglist('.*')
  call filter(taglist, 'len(v:val.name) >= g:quickhl_tag_minimum_identifier')
  for tag in taglist
     call matchadd(self.name, tag.name, g:quickhl_tag_hl_priority)
  endfor
endfunction "}}}

function! s:tag.clear() "{{{
  call map(map(quickhl#our_match(self.name), 'v:val.id'), 'matchdelete(v:val)')
endfunction "}}}

function! s:tag.refresh() "{{{
  " only enable on normal(&buftype is empty) buffer.
  call self.clear()
  if !empty(&buftype) | return | endif
  if !self.enable | return | endif
  call self.set()
endfunction "}}}

function! quickhl#tag#init_highlight() "{{{
  call s:tag.init_highlight()
endfunction "}}}

function! quickhl#tag#enable() "{{{
  let s:tag.enable = 1
  augroup QuickhlTag
    autocmd!
    autocmd! BufEnter,WinEnter * call quickhl#tag#refresh()
    autocmd! ColorScheme * call quickhl#tag#init_highlight()
  augroup END
  call quickhl#tag#init_highlight()
  call quickhl#tag#refresh()
endfunction "}}}

function! quickhl#tag#disable() "{{{
  let s:tag.enable = 0
  augroup QuickhlTag
    autocmd!
  augroup END
  autocmd! QuickhlTag
  call quickhl#tag#refresh()
endfunction "}}}

function! quickhl#tag#toggle() "{{{
  let s:tag.enable = !s:tag.enable
  if s:tag.enable
    call quickhl#tag#enable()
  else
    call quickhl#tag#disable()
  endif
endfunction "}}}

function! quickhl#tag#refresh() "{{{
  call quickhl#windo(s:tag.refresh, s:tag)
endfunction "}}}

call s:tag.init()
" vim: foldmethod=marker
