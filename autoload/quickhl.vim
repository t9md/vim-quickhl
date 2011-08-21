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

let s:metachar = '\/~ .*^[''$'
function! s:escape(pattern) "{{{
  return escape(a:pattern,s:metachar)
endfunction "}}}

function! s:read_colors(list) "{{{
  let colors = []
  let index = 0
  while index < len(a:list)
    call add(colors, {
          \ "name": "Quickhl" . index,
          \ "val": a:list[index],
          \ "pattern": "",
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
endfunction "}}}

function! s:o.init_highlight() "{{{
  for color in self.colors
    let cmd = 'highlight ' . color.name . ' ' . color.val
    call s:exe(cmd)
  endfor
  call self.inject_keywords()
endfunction "}}}

function! s:o.inject_keywords() "{{{
  for keyword in g:quickhl_keywords
    call self.add(keyword)
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
    let escaped_pattern = s:escape(color.pattern)
    if !empty(escaped_pattern)
      call s:decho(escaped_pattern)
    endif
    call matchadd(color.name, escaped_pattern)
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

function! s:has_match(word) "{{{
  for m in s:our_match()
    if m.pattern == s:escape(a:word)
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:o.add(word) "{{{
  if s:has_match(a:word)
    call s:decho("duplicate: " . a:word)
    return
  endif
  call s:decho("new: " . a:word)
  let self.colors[self.idx].pattern = a:word
  call self.inc_idx()
  call self.refresh()
endfunction "}}}

function! s:o.del(word) "{{{
  if s:has_match(a:word)
    call s:decho("del: " . a:word)
    for color in self.colors
      if color.pattern == a:word
        let color.pattern = ""
      endif
    endfor
  endif
  call self.refresh()
endfunction "}}}

function! s:o.list() "{{{
  for color in self.colors
    if color.pattern == ""
      continue
    endif
    exe "echohl " . color.name
    let cmd = "echo " . string(color.pattern)
    exe cmd
    echohl None
  endfor
endfunction "}}}

function! s:o.toggle(word) "{{{
  if !s:has_match(a:word)
    call self.add(a:word)
  else
    call self.del(a:word)
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

function! quickhl#add(word) "{{{
  call s:o.add(a:word)
endfunction "}}}

function! quickhl#del(word) "{{{
  call s:o.del(a:word)
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
