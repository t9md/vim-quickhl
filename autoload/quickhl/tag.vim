let s:tag = {
      \ "name": "QuickhlTag",
      \ "enable":   g:quickhl_tag_enable_at_startup,
      \ "priority": g:quickhl_tag_hl_priority,
      \ }

function! s:tag.set() "{{{
  call map(taglist('.*'), 'matchadd("'. self.name . '", v:val.name, self.priority)')
endfunction "}}}

function! s:tag.clear() "{{{
  call map(map(quickhl#our_match(self.name), 'v:val.id'), 'matchdelete(v:val)')
endfunction "}}}

function! s:tag.refresh() "{{{
  " only enable on normal(&buftype is empty) buffer.
  if !empty(&buftype) | return | endif
  call self.clear()
  if !self.enable | return | endif
  call self.set()
endfunction "}}}

function! quickhl#tag#enable() "{{{
  let s:tag.enable = 1
  augroup QuickhlTag
    autocmd!
    autocmd BufEnter,WinEnter * call quickhl#tag#refresh()
  augroup END
  call quickhl#tag#refresh()
endfunction "}}}

function! quickhl#tag#disable() "{{{
  let s:tag.enable = 0
  augroup QuickhlTag
    autocmd!
  augroup END
  augroup! QuickhlTag
  call quickhl#tag#refresh()
endfunction "}}}

function! quickhl#tag#toggle() "{{{
  let s:tag.enable = !s:tag.enable
  if s:cword.enable
    call quickhl#tag#enable()
  else
    call quickhl#tag#disable()
  endif
endfunction "}}}

function! quickhl#tag#refresh() "{{{
  call quickhl#windo(s:tag.refresh, s:tag)
endfunction "}}}

" vim: foldmethod=marker
