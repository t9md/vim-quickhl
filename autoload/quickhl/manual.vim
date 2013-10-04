function! s:decho(msg) "{{{
  if g:quickhl_debug
    echo "[debug] ". a:msg
  endif
endfunction "}}}

function! s:exe(cmd) "{{{
  call s:decho("[cmd] " . a:cmd)
  exe a:cmd
endfunction "}}}

let s:manual = {
      \ "name": 'QuickhlManual\d',
      \ "history": [],
      \ "idx": 0,
      \ "enable": g:quickhl_manual_enable_at_startup,
      \ }

function! s:manual.dump() "{{{
  if !exists("*PP")
    echoerr "need prettyprint.vim"
    return
  endif
  echo PP(self)
endfunction "}}}

function! s:manual.init() "{{{
  let  self.colors = self.read_colors(g:quickhl_manual_colors)
  call self.init_highlight()
  call self.inject_keywords()
  let self.history = []
endfunction "}}}

function! s:manual.read_colors(list) "{{{
  return map(copy(a:list), '{
        \ "name": "QuickhlManual" . v:key,
        \ "val": v:val,
        \ "pattern": "",
        \ "escaped": 0,
        \ }')
endfunction "}}}

function! s:manual.init_highlight() "{{{
  " [TODO] should update(extend()) with new color but don't change other
  " fields.
  for color in self.colors
    let cmd = 'highlight ' . color.name . ' ' . color.val
    call s:exe(cmd)
  endfor
endfunction "}}}

function! s:manual.inject_keywords() "{{{
  call self._inject_keywords( g:quickhl_manual_keywords )
endfunction "}}}

function! s:manual._inject_keywords(keywords) "{{{
  for keyword in a:keywords
    if type(keyword) == type("")
      call self.add(keyword, 0)
    elseif type(keyword) == type({})
      call self.add(keyword.pattern, get(keyword, "regexp", 0))
    endif
    unlet keyword
  endfor
endfunction "}}}

function! s:manual.set() "{{{
  " call map(copy(self.colors), 'matchadd(v:val.name, v:val.pattern)')
  for color in self.colors | call matchadd(color.name, color.pattern) | endfor
endfunction "}}}

function! s:manual.clear() "{{{
  call map(map(quickhl#our_match(self.name), 'v:val.id'), 'matchdelete(v:val)')
endfunction "}}}

function! s:manual.reset() "{{{
  for color in self.colors | let color.pattern = "" | endfor
  call quickhl#manual#refresh()
  if self.enable | call self.inject_keywords() | endif
  let self.history = []
endfunction "}}}

function! s:manual.refresh() "{{{
  call self.clear()
  if exists("b:quickhl_manual_lock") | return | endif
  call self.set()
endfunction "}}}

function! s:manual.show_colors() "{{{
  for color in self.colors
    call s:exe("highlight " . color.name)
  endfor
endfunction "}}}

function! s:manual.add(pattern, escaped) "{{{
  let pattern = a:escaped ? a:pattern : quickhl#escape(a:pattern)
  if ( s:manual.index_of(pattern) >= 0 )
    call s:decho("duplicate: " . pattern)
    return
  endif
  call s:decho("new: " . pattern)
  let i = self.next_index()
  let self.colors[i].pattern = pattern
  call add(self.history, i)
endfunction "}}}

function! s:manual.next_index() "{{{
  let index = self.index_of('')
  return ( index != -1 ? index : remove(self.history, 0) )
endfunction "}}}

function! s:manual.index_of(pattern) "{{{
  for n in range(len(self.colors))
    if self.colors[n].pattern ==# a:pattern
      return n
    endif
  endfor
  return -1
endfunction "}}}

function! s:manual.del(pattern, escaped) "{{{
  let pattern = a:escaped ? a:pattern : quickhl#escape(a:pattern)

  let index = self.index_of(pattern)
  call s:decho("[del ]: " . index)
  if index < 0
    call s:decho("Can't find for '" . a:val . "'" )
    return
  endif
  call self.del_by_index(index)
  if empty(self.history) | return | endif
  call remove(self.history, index(self.history, index))
endfunction "}}}

function! s:manual.del_by_index(idx) "{{{
  if a:idx >= len(self.colors) | return | endif
  let self.colors[a:idx].pattern = ''
endfunction "}}}

function! s:manual.list() "{{{
  for idx in range(len(self.colors))
    let color = self.colors[idx]
    exe "echohl " . color.name
    echo printf("%2d: ", idx)
    let cmd = "echon " . string(color.pattern)
    exe cmd
    echohl None
  endfor
endfunction "}}}

call s:manual.init()

function! quickhl#manual#toggle(mode) "{{{
  if !s:manual.enable
    call quickhl#manual#enable()
  endif
  let pattern = 
        \ a:mode == 'n' ? expand('<cword>') :
        \ a:mode == 'v' ? quickhl#get_selected_text() :
        \ ""
  if pattern == '' | return | endif
  call s:decho("[toggle] " . pattern)
  if s:manual.index_of(quickhl#escape(pattern)) == -1
    call s:decho("[toggle add]:" . pattern)
    call s:manual.add(pattern, 0)
  else
    call s:decho("[toggle del]:" . pattern)
    call s:manual.del(pattern, 0)
  endif
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#reset() "{{{
  call s:manual.reset()
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#list() "{{{
  call s:manual.list()
endfunction "}}}

function! quickhl#manual#lock() "{{{
  let b:quickhl_manual_lock = 1
  call s:manual.clear()
endfunction "}}}

function! quickhl#manual#unlock() "{{{
  unlet! b:quickhl_manual_lock
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#dump() "{{{
  call s:manual.dump()
  " echo s:manual.history
endfunction "}}}

function! quickhl#manual#add(pattern, escaped) "{{{
  if !s:manual.enable
    call quickhl#manual#enable()
  endif
  call s:manual.add(a:pattern, a:escaped)
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#del(pattern, escaped) "{{{
  if empty(a:pattern)
    call s:manual.list()
    let index = input("index to delete: ")
    if empty(index) | return | endif
    call s:manual.del_by_index(index)
  else
    call s:manual.del(a:pattern, a:escaped)
  endif
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#colors() "{{{
  call s:manual.show_colors()
endfunction "}}}

function! quickhl#manual#enable() "{{{
  let s:manual.enable = 1
  augroup QuickhlManual
    autocmd!
    autocmd VimEnter,WinEnter * call quickhl#manual#refresh()
    autocmd TabEnter *
          \   if exists(':Tcolorscheme')
          \ |   call quickhl#manual#init_highlight()
          \ | endif
    autocmd! ColorScheme * call quickhl#manual#init_highlight()
  augroup END
  call s:manual.init()
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#disable() "{{{
  let s:manual.enable = 0
  augroup QuickhlManual
    autocmd!
  augroup END
  augroup! QuickhlManual
  call quickhl#manual#reset()
endfunction "}}}

function! quickhl#manual#refresh() "{{{
  call quickhl#windo(s:manual.refresh, s:manual)
endfunction "}}}

function! quickhl#manual#status() "{{{
  echo s:manual.enable
  " call quickhl#windo(s:manual.refresh, s:manual)
endfunction "}}}

function! quickhl#manual#init_highlight() "{{{
  call s:manual.init_highlight()
endfunction "}}}

" vim: foldmethod=marker
