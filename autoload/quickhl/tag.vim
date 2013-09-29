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

function! s:tag_refresh() "{{{
  call s:tag.refresh()
endfunction "}}}

function! quickhl#tag#enable() "{{{
  let s:tag.enable = 1
  call quickhl#tag#do()
endfunction "}}}

function! quickhl#tag#disable() "{{{
  let s:tag.enable = 0
  call quickhl#tag#do()
endfunction "}}}

function! quickhl#tag#toggle() "{{{
  let s:tag.enable = !s:tag.enable
  call quickhl#tag#do()
endfunction "}}}

function! quickhl#tag#do() "{{{
  augroup QuickhlTag
    autocmd!
    if s:tag.enable
      " autocmd VimEnter,WinEnter * call quickhl#tag#refresh()
      autocmd BufEnter,WinEnter * call quickhl#tag#refresh()
    endif
  augroup END
  call quickhl#tag#refresh()
endfunction "}}}

function! quickhl#tag#refresh() "{{{
  " echo "called 1"
  " echo "called 2"
  call quickhl#windo(function('s:tag_refresh'))
endfunction "}}}
" vim: foldmethod=marker
