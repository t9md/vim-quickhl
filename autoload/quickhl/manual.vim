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
      \ "idx": 0,
      \ "history": [],
      \ "enable": g:quickhl_manual_enable_at_startup,
      \ }

function! s:manual_clear() "{{{
  call s:manual.clear()
endfunction "}}}

function! s:manual.dump() "{{{
  if !exists("*PP")
    echoerr "need prettyprint.vim"
    return
  endif
  echo PP(self)
endfunction "}}}

function! s:manual.init() "{{{
  " let  self.idx = 0
  let  self.colors = self.read_colors(g:quickhl_manual_colors)
  call self.init_highlight()
  call self.inject_keywords()
endfunction "}}}

function! s:manual.read_colors(list) "{{{
  return map(copy(a:list), '{
        \ "name": "QuickhlManual" . v:key,
        \ "val": v:val,
        \ "pattern": "",
        \ "regexp": 0,
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
  for keyword in g:quickhl_manual_keywords
    if type(keyword) == type("")
      call self.add(keyword, 0)
    elseif type(keyword) == type({})
      call self.add(keyword.pattern, get(keyword, "regexp", 0))
    endif
    unlet keyword
  endfor
endfunction "}}}

function! s:manual.set() "{{{
  for color in self.colors
    call matchadd(color.name, color.pattern)
  endfor
endfunction "}}}

function! s:manual.clear() "{{{
  call map(map(quickhl#our_match(self.name), 'v:val.id'), 'matchdelete(v:val)')
endfunction "}}}

function! s:manual.reset() "{{{
  for color in self.colors
    let color.pattern = ""
  endfor
  let self.history = []
  call quickhl#manual#refresh()
  " let self.idx = 0
  if self.enable
    call self.inject_keywords()
  endif
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

function! s:manual.has_match(pattern) "{{{
  for m in quickhl#our_match(self.name)
    if m.pattern == a:pattern | return 1 | endif
  endfor
  return 0
endfunction "}}}

function! s:manual.add(pattern, regexp) "{{{
  let pattern = a:regexp ? a:pattern : quickhl#escape(a:pattern)
  if self.has_match(pattern)
    call s:decho("duplicate: " . pattern)
    return
  endif
  call s:decho("new: " . pattern)
  let idx = self.next_index()
  let self.colors[idx].pattern = pattern
  let self.colors[idx].regexp  = a:regexp
  call add(self.history, idx)
endfunction "}}}

function! s:manual.next_index() "{{{
  let index = self.index_of('')
  return index != -1 ? index : remove(self.history, 0)
endfunction "}}}

function! s:manual.index_of(pattern) "{{{
  for n in range(len(self.colors))
    if self.colors[n].pattern ==# a:pattern
      return n
    endif
  endfor
  return -1
endfunction "}}}

function! s:manual.del(pattern, regexp) "{{{
  let pattern = a:regexp ? a:pattern : quickhl#escape(a:pattern)

  let index = self.index_of(pattern)
  if index < 0
    call s:decho("Can't find for '" . a:val . "'" )
    return
  endif
  call self.del_by_index(index)
  call remove(self.history, index(self.history, index))
  " if self.has_match(pattern) "{{{
    " call s:decho("del: " . pattern)
    " for color in self.colors
      " if color.pattern == pattern
        " let color.pattern = ""
      " endif
    " endfor
  " else
    " call quickhl#warn("pattern not found: " . string(pattern))
  " endif "}}}
endfunction "}}}

function! s:manual.del_by_index(idx) "{{{
  let color = get(self.colors, a:idx, {})
  if !empty(color) && !empty(color.pattern)
    let self.colors[a:idx].pattern = ""
  else
    call quickhl#warn("index not found: " . a:idx)
  endif
endfunction "}}}

function! s:manual.list() "{{{
  for idx in range(len(self.colors))
    let color = self.colors[idx]
    " if color.pattern == ""
      " continue
    " endif
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
  if !s:manual.has_match(quickhl#escape(pattern))
    call s:manual.add(pattern, 0)
  else
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
  " call s:manual.dump()
  echo s:manual.history
endfunction "}}}

function! quickhl#manual#add(pattern, regexp) "{{{
  if !s:manual.enable
    call quickhl#manual#enable()
  endif
  call s:manual.add(a:pattern, a:regexp)
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#del(pattern, regexp) "{{{
  if empty(a:pattern)
    call s:manual.list()
    let index = input("index to delete: ")
    if empty(index)
      return
    endif
    call s:manual.del_by_index(index)
  else
    call s:manual.del(a:pattern, a:regexp)
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
  " call s:manual.init()
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
