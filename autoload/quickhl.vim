" Utility: {{{
"copy & paste from tyru's open-browser.vim
function! s:get_selected_text() "{{{
  let save_z = getreg('z', 1)
  let save_z_type = getregtype('z')
  try
    silent normal! gv"zy
    return substitute(@z,"\n.*",'','')
  finally
    call setreg('z', save_z, save_z_type)
  endtry
endfunction "}}}

function! s:report_error(error)
	echohl WarningMsg
  echomsg 'quickhl:  ' . a:error
  echohl None
endfunction

let s:metachar = '\/~ .*^[''$'
function! s:escape(pattern) "{{{
  return escape(a:pattern, s:metachar)
endfunction "}}}

function! s:read_colors(list) "{{{
  let colors = []
  let index = 0
  while index < len(a:list)
    call add(colors, {
          \ "name": "Quickhl" . index,
          \ "val": a:list[index],
          \ "pattern": "",
          \ "regexp": 0,
          \ })
    let index += 1
  endwhile
  return colors
endfunction "}}}

function! s:decho(msg) "{{{
  if g:quickhl_debug
    echo "[debug] ". a:msg
  endif
endfunction "}}}

function! s:exe(cmd) "{{{
  call s:decho("[cmd] " . a:cmd)
  exe a:cmd
endfunction "}}}
" }}}

" MAIN: {{{
let s:o = {}
function! s:o.dump() "{{{
  if !exists("*PP")
    echoerr "need prettyprint.vim"
    return
  endif
  echo PP(self)
endfunction "}}}

function! s:o.init() "{{{
  let self.idx = 0
  let self.colors = s:read_colors(g:quickhl_colors)
  call self.init_highlight()
  call self.inject_keywords()
endfunction "}}}

function! s:o.init_highlight() "{{{
  for color in self.colors
    let cmd = 'highlight ' . color.name . ' ' . color.val
    call s:exe(cmd)
  endfor
  " call self.inject_keywords()
endfunction "}}}

function! s:o.inject_keywords() "{{{
  for keyword in g:quickhl_keywords
    if type(keyword) == type("")
      call self.add(keyword, 0)
    elseif type(keyword) == type({})
      call self.add(keyword.pattern, get(keyword, "regexp", 0))
    endif
    unlet keyword
  endfor
endfunction "}}}

function! s:our_match() "{{{
  return filter(getmatches(), 'v:val.group =~# "Quickhl\\d"')
endfunction "}}}

function! s:clear_match() "{{{
  for id in map(s:our_match(), 'v:val.id')
    call matchdelete(id)
  endfor
endfunction "}}}

function! s:o.reset() "{{{
  for color in self.colors
    let color.pattern = ""
  endfor
  let self.idx = 0
  let winnum = winnr()
  exe "windo call <SID>clear_match()"
  exe winnum . "wincmd w"
  call self.inject_keywords()
endfunction "}}}

function! s:o.refresh() "{{{
  let winnum = winnr()
  exe "windo call <SID>refresh_match()"
  exe winnum . "wincmd w"
endfunction "}}}

function! s:refresh_match() "{{{
  if exists("b:quickhl_lock")
    return
  endif
  call s:clear_match()
  for color in s:o.colors
    if !empty(color.pattern)
      call s:decho(color.pattern)
    endif
    try
      call matchadd(color.name, color.pattern)
    catch
      call s:report_error(v:exception)
      call s:report_error("delete pattern " . string(color.pattern))
      let color.pattern = ""
    endtry
  endfor
endfunction "}}}

function! s:o.inc_idx() "{{{
  let self.idx = (self.idx + 1) % len(self.colors)
endfunction "}}}

function! s:o.show_colors() "{{{
  for color in self.colors
    call s:exe("highlight " . color.name)
  endfor
endfunction "}}}

function! s:has_match(pattern) "{{{
  for m in s:our_match()
    if m.pattern == a:pattern
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:o.add(pattern, regexp) "{{{
  let pattern = a:regexp ? a:pattern : s:escape(a:pattern)
  if s:has_match(pattern)
    call s:decho("duplicate: " . pattern)
    return
  endif
  call s:decho("new: " . pattern)
  let self.colors[self.idx].pattern = pattern
  let self.colors[self.idx].regexp  = a:regexp
  call self.inc_idx()
  call self.refresh()
endfunction "}}}

function! s:o.del(pattern, regexp) "{{{
  let pattern = a:regexp ? a:pattern : s:escape(a:pattern)
  if s:has_match(pattern)
    call s:decho("del: " . pattern)
    for color in self.colors
      if color.pattern == pattern
        let color.pattern = ""
      endif
    endfor
  else
    call s:report_error("pattern not found: " . string(pattern))
  endif
  call self.refresh()
endfunction "}}}

function! s:o.del_by_index(idx) "{{{
  let color = get(self.colors, a:idx, {})
  if !empty(color) && !empty(color.pattern)
    let self.colors[a:idx].pattern = ""
  else
    call s:report_error("index not found: " . a:idx)
  endif
  call self.refresh()
endfunction "}}}

function! s:o.list() "{{{
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

function! s:o.toggle(pattern) "{{{
  if !s:has_match(s:escape(a:pattern))
    call self.add(a:pattern, 0)
  else
    call self.del(a:pattern, 0)
  endif
endfunction "}}}

call s:o.init()
"}}}

" PublicInterface: {{{
function! quickhl#toggle(mode) "{{{
  let pattern = 
        \ a:mode == 'n' ? expand('<cword>') :
        \ a:mode == 'v' ? s:get_selected_text() :
        \ ""
  if pattern == ''
    return
  endif
  call s:decho("[toggle] " . pattern)
  call s:o.toggle(pattern)
endfunction "}}}

function! quickhl#match(action) "{{{
  if a:action == 'clear'
    silent! match none
    unlet b:quickhlmatch_pattern
    return
  endif

  let pattern = expand('<cword>')
  if a:action == 'toggle'
    if exists('b:quickhlmatch_pattern')
          \ && b:quickhlmatch_pattern == pattern
      silent! match none
      unlet b:quickhlmatch_pattern
      return
    endif
  endif

  let b:quickhlmatch_pattern = pattern
  highlight QuickhlMatch gui=undercurl guisp=Cyan
  exe "match QuickhlMatch /". b:quickhlmatch_pattern . "/"
endfunction "}}}

function! quickhl#list() "{{{
  call s:o.list()
endfunction "}}}

function! quickhl#lock() "{{{
  let b:quickhl_lock = 1
  call s:clear_match()
endfunction "}}}

function! quickhl#unlock() "{{{
  unlet! b:quickhl_lock
  call s:refresh_match()
endfunction "}}}

function! quickhl#dump() "{{{
  call s:o.dump()
endfunction "}}}

function! quickhl#reset() "{{{
  call s:o.reset()
endfunction "}}}

function! quickhl#add(pattern, regexp) "{{{
  call s:o.add(a:pattern, a:regexp)
endfunction "}}}

function! quickhl#del(pattern, regexp) "{{{
  if empty(a:pattern)
    call s:o.list()
    let index = input("index to delete: ")
    if empty(index)
      return
    endif
    call s:o.del_by_index(index)
  else
    call s:o.del(a:pattern, a:regexp)
  endif
endfunction "}}}

function! quickhl#colors() "{{{
  call s:o.show_colors()
endfunction "}}}

function! quickhl#refresh() "{{{
  call s:o.refresh()
endfunction "}}}

function! quickhl#init_highlight() "{{{
  call s:o.init_highlight()
endfunction "}}}
"}}}

" vim: foldmethod=marker
