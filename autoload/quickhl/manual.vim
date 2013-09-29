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
      \ "name": 'Quickhl\d',
      \ "idx": 0,
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
  let  self.colors = self.read_colors(g:quickhl_manual_colors)
  call self.init_highlight()
  call self.inject_keywords()
  call self.refresh()
endfunction "}}}

function! s:manual.read_colors(list) "{{{
  return map(copy(a:list), '{
        \ "name": "Quickhl" . v:key,
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
  let self.idx = 0
  call self.inject_keywords()
endfunction "}}}

function! s:manual_refresh() "{{{
  call s:manual.refresh()
endfunction "}}}

function! s:manual.refresh() "{{{
  call self.clear()
  " if ! self.enable | return | endif
  call self.set()
endfunction "}}}

function! s:manual.show_colors() "{{{
  for color in self.colors
    call s:exe("highlight " . color.name)
  endfor
endfunction "}}}

function! s:manual.has_match(pattern) "{{{
  for m in quickhl#our_match(self.name)
    if m.pattern == a:pattern
      return 1
    endif
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
  let self.colors[self.idx].pattern = pattern
  let self.colors[self.idx].regexp  = a:regexp
  let self.idx = (self.idx + 1) % len(self.colors)
endfunction "}}}

function! s:manual.del(pattern, regexp) "{{{
  let pattern = a:regexp ? a:pattern : quickhl#escape(a:pattern)
  if self.has_match(pattern)
    call s:decho("del: " . pattern)
    for color in self.colors
      if color.pattern == pattern
        let color.pattern = ""
      endif
    endfor
  else
    call quickhl#warn("pattern not found: " . string(pattern))
  endif
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
    if color.pattern == ""
      continue
    endif
    echo printf("%2d: ", idx)
    exe "echohl " . color.name
    let cmd = "echon " . string(color.pattern)
    exe cmd
    echohl None
  endfor
endfunction "}}}

call s:manual.init()

function! quickhl#manual#toggle(mode) "{{{
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

function! quickhl#manual#enable() "{{{
  let s:manual.enable = 1
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#disable() "{{{
  let s:manual.enable = 0
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#dump() "{{{
  call s:manual.dump()
endfunction "}}}

function! quickhl#manual#add(pattern, regexp) "{{{
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

function! quickhl#manual#refresh() "{{{
  call quickhl#windo(function('s:manual_refresh'))
endfunction "}}}

function! quickhl#manual#init_highlight() "{{{
  call s:manual.init_highlight()
endfunction "}}}

" vim: foldmethod=marker
