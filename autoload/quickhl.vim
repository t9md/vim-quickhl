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

function! s:report_error(error) "{{{
	echohl WarningMsg
  echomsg 'quickhl:  ' . a:error
  echohl None
endfunction "}}}

let s:metachar = '\/~ .*^[''$'
function! s:escape(pattern) "{{{
  return escape(a:pattern, s:metachar)
endfunction "}}}

function! s:read_colors(list) "{{{
  return map(copy(a:list), '{
        \ "name": "Quickhl" . v:key,
        \ "val": v:val,
        \ "pattern": "",
        \ "regexp": 0,
        \ }')
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
let s:o = { }
let s:hl_name_tag = "QuickhlTag"
let s:hl_name_hl = 'Quickhl\d'
" default 10, 
let s:hl_priority = 9
let g:underlinetag_enable = 0



function! s:set_hl() "{{{
  call map(taglist('.*'), 'matchadd(s:hl_name_tag, v:val.name, s:hl_priority)')
endfunction "}}}

function! s:clear_hl() "{{{
  call map(map(s:our_match(s:hl_name_tag), 'v:val.id'), 'matchdelete(v:val)')
endfunction "}}}

function! s:refresh() "{{{
  " only enable on normal(&buftype is empty) buffer.
  if !empty(&buftype) | return | endif
  call s:clear_hl()
  if !g:underlinetag_enable | return | endif
  call s:set_hl()
endfunction "}}}

function! quickhl#tag_enable() "{{{
  let g:underlinetag_enable = 1
  call quickhl#tag_do()
endfunction "}}}

function! quickhl#tag_disable() "{{{
  let g:underlinetag_enable = 0
  call quickhl#tag_do()
endfunction "}}}

function! quickhl#tag_toggle() "{{{
  let g:underlinetag_enable = !g:underlinetag_enable
  call quickhl#tag_do()
endfunction "}}}

function! quickhl#tag_do() "{{{
  augroup UnderlineTag
    autocmd!
    if g:underlinetag_enable
      autocmd VimEnter,WinEnter * call quickhl#tag_refresh()
    endif
  augroup END

  call quickhl#tag_refresh()
endfunction "}}}

function! quickhl#tag_refresh() "{{{
  call s:windo(function('s:refresh'))
endfunction "}}}

function! s:o.dump() "{{{
  if !exists("*PP")
    echoerr "need prettyprint.vim"
    return
  endif
  echo PP(self)
endfunction "}}}

function! s:o.init() "{{{
  let  self.idx = 0
  let  self.colors = s:read_colors(g:quickhl_colors)
  call self.init_highlight()
  call self.inject_keywords()
  call self.refresh()
endfunction "}}}

function! s:o.init_highlight() "{{{
  " [TODO] should update(extend()) with new color but don't change other
  " fields.
  " let self.colors = s:read_colors(g:quickhl_colors)
  for color in self.colors
    let cmd = 'highlight ' . color.name . ' ' . color.val
    call s:exe(cmd)
  endfor
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

function! s:our_match(pattern) "{{{
  return filter(getmatches(), "v:val.group =~# '". a:pattern . "'")
endfunction "}}}

function! s:clear_match() "{{{
  for id in map(s:our_match(s:hl_name_hl), 'v:val.id')
    call matchdelete(id)
  endfor
endfunction "}}}

function! s:o.reset() "{{{
  for color in self.colors
    let color.pattern = ""
  endfor
  let self.idx = 0
  call s:windo(function('s:clear_match'))
  call self.inject_keywords()
endfunction "}}}

function! s:o.refresh() "{{{
  call s:windo(function('s:refresh_match'))
endfunction "}}}

function! s:set_winvar() "{{{
  for n in map(range(winnr('$')), 'v:val+1')
    call setwinvar(n, "quickhl_winno", n)
  endfor
endfunction "}}}

function! s:get_winvar() "{{{
  for n in map(range(winnr('$')), 'v:val+1')
    let here = n == winnr() ? " <==" : ''
    echo n . ":". getwinvar(n, "quickhl_winno", -1) . here
  endfor
endfunction "}}}

function! s:find_win(num) "{{{
  for n in map(range(winnr('$')), 'v:val+1')
    if getwinvar(n, "quickhl_winno", -1)  == a:num
      return n
    endif
  endfor
  return -1
endfunction "}}}

function! s:windo(func) "{{{
  let winnum = winnr()
  let pwinnum = winnr('#')
  " echo [pwinnum, winnum]
  noautocmd windo call a:func()
  execute pwinnum . "wincmd w"
  execute winnum . "wincmd w"
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
  for m in s:our_match(s:hl_name_hl)
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
endfunction "}}}

function! s:o.del_by_index(idx) "{{{
  let color = get(self.colors, a:idx, {})
  if !empty(color) && !empty(color.pattern)
    let self.colors[a:idx].pattern = ""
  else
    call s:report_error("index not found: " . a:idx)
  endif
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
  call s:o.refresh()
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

  let pattern = s:escape(expand('<cword>'))
  if a:action == 'toggle'
    if exists('b:quickhlmatch_pattern')
          \ && b:quickhlmatch_pattern == pattern
      silent! match none
      unlet b:quickhlmatch_pattern
      return
    endif
  endif

  let b:quickhlmatch_pattern = pattern
  " exe "highlight QuickhlMatch " . g:quickhl_match_color

  exe "highlight link QuickhlMatch Search"
  exe "match QuickhlMatch /". b:quickhlmatch_pattern . "/"
endfunction "}}}

function! quickhl#match_auto(action) "{{{
  if a:action == 'clear' || a:action == "toggle" && exists("b:quickhlmatch_pattern")
    call quickhl#match("clear")
    if exists("#QuickhlMatch")
      augroup QuickhlMatch
        autocmd!
      augroup END
      augroup! QuickhlMatch
    endif
    return
  endif

  call quickhl#match("on")
  augroup QuickhlMatch
    autocmd!
    autocmd! CursorMoved <buffer> call quickhl#match("on")
  augroup END
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
  call s:o.refresh()
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
  call s:o.refresh()
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
