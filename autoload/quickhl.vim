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

function! s:escape(pattern) "{{{
  return escape(a:pattern, s:metachar)
endfunction "}}}

function! s:our_match(pattern) "{{{
  return filter(getmatches(), "v:val.group =~# '". a:pattern . "'")
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

function! s:windo(func) "{{{
  let winnum = winnr()
  let pwinnum = winnr('#')
  " echo [pwinnum, winnum]
  noautocmd windo call a:func()
  execute pwinnum . "wincmd w"
  execute winnum . "wincmd w"
endfunction "}}}
" }}}

let s:metachar = '\/~ .*^[''$'

" QuickhlTag: {{{
let s:tag = {
      \ "name": "QuickhlTag",
      \ "enable": g:quickhltag_enable_at_startup,
      \ "priority": g:quickhltag_hl_priority,
      \ }

function! s:tag.set() "{{{
  call map(taglist('.*'), 'matchadd("'. self.name . '", v:val.name, self.priority)')
endfunction "}}}

function! s:tag.clear() "{{{
  call map(map(s:our_match(self.name), 'v:val.id'), 'matchdelete(v:val)')
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

function! quickhl#tag_enable() "{{{
  let s:tag.enable = 1
  call quickhl#tag_do()
endfunction "}}}

function! quickhl#tag_disable() "{{{
  let s:tag.enable = 0
  call quickhl#tag_do()
endfunction "}}}

function! quickhl#tag_toggle() "{{{
  let s:tag.enable = !s:tag.enable
  call quickhl#tag_do()
endfunction "}}}

function! quickhl#tag_do() "{{{
  augroup QuickhlTag
    autocmd!
    if s:tag.enable
      " autocmd VimEnter,WinEnter * call quickhl#tag_refresh()
      autocmd BufEnter,WinEnter * call quickhl#tag_refresh()
    endif
  augroup END
  call quickhl#tag_refresh()
endfunction "}}}

function! quickhl#tag_refresh() "{{{
  " echo "called 1"
  " echo "called 2"
  call s:windo(function('s:tag_refresh'))
endfunction "}}}
 "}}}

" QuickhlUser: {{{
let s:user = {
      \ "name": 'Quickhl\d',
      \ "idx": 0,
      \ "enable": g:quickhluser_enable_at_startup,
      \ }

function! s:user_clear() "{{{
  call s:user.clear()
endfunction "}}}

function! s:user.dump() "{{{
  if !exists("*PP")
    echoerr "need prettyprint.vim"
    return
  endif
  echo PP(self)
endfunction "}}}

function! s:user.init() "{{{
  let  self.colors = self.read_colors(g:quickhl_colors)
  call self.init_highlight()
  call self.inject_keywords()
  call self.refresh()
endfunction "}}}

function! s:user.read_colors(list) "{{{
  return map(copy(a:list), '{
        \ "name": "Quickhl" . v:key,
        \ "val": v:val,
        \ "pattern": "",
        \ "regexp": 0,
        \ }')
endfunction "}}}

function! s:user.init_highlight() "{{{
  " [TODO] should update(extend()) with new color but don't change other
  " fields.
  for color in self.colors
    let cmd = 'highlight ' . color.name . ' ' . color.val
    call s:exe(cmd)
  endfor
endfunction "}}}

function! s:user.inject_keywords() "{{{
  for keyword in g:quickhl_keywords
    if type(keyword) == type("")
      call self.add(keyword, 0)
    elseif type(keyword) == type({})
      call self.add(keyword.pattern, get(keyword, "regexp", 0))
    endif
    unlet keyword
  endfor
endfunction "}}}

function! s:user.set() "{{{
  for color in self.colors
    call matchadd(color.name, color.pattern)
  endfor
endfunction "}}}

function! s:user.clear() "{{{
  call map(map(s:our_match(self.name), 'v:val.id'), 'matchdelete(v:val)')
endfunction "}}}

function! s:user.reset() "{{{
  for color in self.colors
    let color.pattern = ""
  endfor
  let self.idx = 0
  " call s:windo(function('s:user_clear'))
  call self.inject_keywords()
endfunction "}}}

function! s:user_refresh() "{{{
  call s:user.refresh()
endfunction "}}}

function! s:user.refresh() "{{{
  call self.clear()
  " if ! self.enable | return | endif
  call self.set()
endfunction "}}}

function! s:user.show_colors() "{{{
  for color in self.colors
    call s:exe("highlight " . color.name)
  endfor
endfunction "}}}

function! s:user.has_match(pattern) "{{{
  for m in s:our_match(self.name)
    if m.pattern == a:pattern
      return 1
    endif
  endfor
  return 0
endfunction "}}}

function! s:user.add(pattern, regexp) "{{{
  let pattern = a:regexp ? a:pattern : s:escape(a:pattern)
  if self.has_match(pattern)
    call s:decho("duplicate: " . pattern)
    return
  endif
  call s:decho("new: " . pattern)
  let self.colors[self.idx].pattern = pattern
  let self.colors[self.idx].regexp  = a:regexp
  let self.idx = (self.idx + 1) % len(self.colors)
endfunction "}}}

function! s:user.del(pattern, regexp) "{{{
  let pattern = a:regexp ? a:pattern : s:escape(a:pattern)
  if self.has_match(pattern)
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

function! s:user.del_by_index(idx) "{{{
  let color = get(self.colors, a:idx, {})
  if !empty(color) && !empty(color.pattern)
    let self.colors[a:idx].pattern = ""
  else
    call s:report_error("index not found: " . a:idx)
  endif
endfunction "}}}

function! s:user.list() "{{{
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

call s:user.init()

function! quickhl#user_toggle(mode) "{{{
  let pattern = 
        \ a:mode == 'n' ? expand('<cword>') :
        \ a:mode == 'v' ? s:get_selected_text() :
        \ ""
  if pattern == '' | return | endif
  call s:decho("[toggle] " . pattern)
  if !s:user.has_match(s:escape(pattern))
    call s:user.add(pattern, 0)
  else
    call s:user.del(pattern, 0)
  endif
  call quickhl#user_refresh()
endfunction "}}}

function! quickhl#user_reset() "{{{
  call s:user.reset()
  call quickhl#user_refresh()
endfunction "}}}

function! quickhl#user_list() "{{{
  call s:user.list()
endfunction "}}}

function! quickhl#user_enable() "{{{
  let s:user.enable = 1
  call quickhl#user_refresh()
endfunction "}}}

function! quickhl#user_disable() "{{{
  let s:user.enable = 0
  call quickhl#user_refresh()
endfunction "}}}

function! quickhl#user_dump() "{{{
  call s:user.dump()
endfunction "}}}

function! quickhl#user_add(pattern, regexp) "{{{
  call s:user.add(a:pattern, a:regexp)
  call quickhl#user_refresh()
endfunction "}}}

function! quickhl#user_del(pattern, regexp) "{{{
  if empty(a:pattern)
    call s:user.list()
    let index = input("index to delete: ")
    if empty(index)
      return
    endif
    call s:user.del_by_index(index)
  else
    call s:user.del(a:pattern, a:regexp)
  endif
  call quickhl#user_refresh()
endfunction "}}}

function! quickhl#user_colors() "{{{
  call s:user.show_colors()
endfunction "}}}

function! quickhl#user_refresh() "{{{
  call s:windo(function('s:user_refresh'))
endfunction "}}}

function! quickhl#user_init_highlight() "{{{
  call s:user.init_highlight()
endfunction "}}}
 "}}}

" QuickhlCword: {{{
let s:cword = {
      \ "enable": g:quickhlcword_enable_at_startup,
      \ }

function! s:cword.refresh() "{{{
  silent! 2match none
  if !self.enable | return | endif
  let pattern = s:escape(expand('<cword>'))
  exe "2match QuickhlCword /". pattern . "/"
endfunction "}}}

function! quickhl#cword_toggle() "{{{
  " echo s:cword.enable
  let s:cword.enable = !s:cword.enable
  call quickhl#cword_do()
endfunction "}}}

function! quickhl#cword_enable() "{{{
  let s:cword.enable = 1
  call quickhl#cword_do()
endfunction "}}}

function! quickhl#cword_disable() "{{{
  let s:cword.enable = 0
  call quickhl#cword_do()
endfunction "}}}

function! quickhl#cword_refresh() "{{{
  call s:cword.refresh()
endfunction "}}}

function! quickhl#cword_do() "{{{
  augroup QuickhlCword
    autocmd!
    if s:cword.enable
      autocmd! CursorMoved <buffer> call quickhl#cword_refresh()
    endif
  augroup END
  call quickhl#cword_refresh()
endfunction "}}}

" function! quickhl#cword(action) "{{{
  " if a:action == 'clear' || ( a:action == "toggle" && exists("b:quickhlmatch_pattern") )
    " call quickhl#_cword("clear")
    " if exists("#QuickhlCword")
      " augroup QuickhlCword
        " autocmd!
      " augroup END
      " augroup! QuickhlCword
    " endif
    " return
  " endif

  " call quickhl#match("on")
  " augroup QuickhlMatch
    " autocmd!
    " autocmd! CursorMoved <buffer> call quickhl#match("on")
  " augroup END
" endfunction "}}}
" }}}

" vim: foldmethod=marker
