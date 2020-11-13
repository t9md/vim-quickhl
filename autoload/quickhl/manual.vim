function! s:decho(msg) "{{{1
  if g:quickhl_debug
    echo "[debug] ". a:msg
  endif
endfunction

function! s:is_cmdwin() "{{{1
  return bufname('%') ==# '[Command Line]'
endfunction

function! s:exe(cmd) "{{{1
  call s:decho("[cmd] " . a:cmd)
  exe a:cmd
endfunction
"}}}


let s:manual = {
      \ "name": 'QuickhlManual\d',
      \ "enabled": g:quickhl_manual_enable_at_startup,
      \ "locked": 0,
      \ }

function! s:manual.dump() "{{{
  if !exists("*PP")
    echoerr "need prettyprint.vim"
    return
  endif
  echo PP(self.history)
endfunction "}}}

function! s:manual.init() "{{{
  let self.colors = self.read_colors(g:quickhl_manual_colors)
  let self.history = range(len(g:quickhl_manual_colors))
  call self.init_highlight()
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
  for color in self.colors
    exe 'highlight ' . color.name . ' ' . color.val
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
  for color in self.colors
    call matchadd(color.name, color.pattern, g:quickhl_manual_hl_priority)
  endfor
endfunction "}}}

function! s:manual.clear() "{{{
  call map(map(quickhl#our_match(self.name), 'v:val.id'), 'matchdelete(v:val)')
endfunction "}}}

function! s:manual.reset() "{{{
  call self.init()
  call quickhl#manual#refresh()
  if self.enabled | call self.inject_keywords() | endif
endfunction "}}}

function! s:manual.is_locked() "{{{
  return self.locked
endfunction "}}}

function! s:manual.refresh() "{{{
  call self.clear()
  if self.locked || ( exists("w:quickhl_manual_lock") && w:quickhl_manual_lock )
    return
  endif
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
  " let index = self.index_of('')
  " return ( index != -1 ? index : remove(self.history, 0) )
  return remove(self.history, 0)
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
  if index == -1
    call s:decho("Can't find for '" . pattern . "'" )
    return
  endif
  call self.del_by_index(index)
endfunction "}}}

function! s:manual.del_by_index(idx) "{{{
  if a:idx >= len(self.colors) | return | endif
  let self.colors[a:idx].pattern = ''
  call remove(self.history, index(self.history, a:idx))
  call insert(self.history, a:idx, 0 )
endfunction "}}}

function! s:manual.list() "{{{
  for idx in range(len(self.colors))
    let color = self.colors[idx]
    exe "echohl " . color.name
    echo printf("%2d: ", idx) . color.pattern
    echohl None
  endfor
endfunction "}}}

function! s:manual.search(flag) "{{{
  let pattern = ''
  for color in self.colors
    if color.pattern != ''
      let pattern = pattern . '\|' . color.pattern
    endif
  endfor
  " eliminate first '\|'
  call search(strpart(pattern, 2), a:flag)
endfunction "}}}

function! quickhl#manual#this(mode) "{{{
  if !s:manual.enabled | call quickhl#manual#enable() | endif
  let pattern =
        \ a:mode == 'n' ? expand('<cword>') :
        \ a:mode == 'v' ? quickhl#get_selected_text() :
        \ ""
  if pattern == '' | return | endif
  " call s:decho("[toggle] " . pattern)
  call quickhl#manual#add_or_del(pattern, 0)
endfunction "}}}

function! quickhl#manual#this_whole_word(mode) "{{{
  if !s:manual.enabled | call quickhl#manual#enable() | endif
  let pattern =
        \ a:mode == 'n' ? expand('<cword>') :
        \ a:mode == 'v' ? quickhl#get_selected_text() :
        \ ""
  if pattern == '' | return | endif
  call quickhl#manual#add_or_del('\<'. quickhl#escape(pattern).'\>', 1)
endfunction "}}}

function! quickhl#manual#clear_this(mode) " {{{
  if !s:manual.enabled | call quickhl#manual#enable() | endif
  let pattern =
        \ a:mode == 'n' ? expand('<cword>') :
        \ a:mode == 'v' ? quickhl#get_selected_text() :
        \ ""
  if pattern == '' | return | endif
  let l:pattern_et = quickhl#escape(pattern)
  let l:pattern_ew = '\<' . quickhl#escape(pattern) . '\>'
  if s:manual.index_of(l:pattern_et) != -1
    call s:manual.del(l:pattern_et, 1)
  elseif s:manual.index_of(l:pattern_ew) != -1
    call s:manual.del(l:pattern_ew, 1)
  endif
  call quickhl#manual#refresh()
endfunction " }}}

function! quickhl#manual#add_or_del(pattern, escaped) "{{{
  if !s:manual.enabled | call quickhl#manual#enable() | endif

  if s:manual.index_of(a:escaped ? a:pattern : quickhl#escape(a:pattern)) == -1
    call s:manual.add(a:pattern, a:escaped)
  else
    call s:manual.del(a:pattern, a:escaped)
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

function! quickhl#manual#lock_window() "{{{
  let w:quickhl_manual_lock = 1
  call s:manual.clear()
endfunction "}}}

function! quickhl#manual#unlock_window() "{{{
  let w:quickhl_manual_lock = 0
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#lock_window_toggle() "{{{
  if !exists("w:quickhl_manual_lock")
    let w:quickhl_manual_lock = 0
  endif
  let w:quickhl_manual_lock = !w:quickhl_manual_lock
  call s:manual.refresh()
endfunction "}}}

function! quickhl#manual#lock() "{{{
  let s:manual.locked = 1
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#unlock() "{{{
  let s:manual.locked = 0
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#lock_toggle() "{{{
  let s:manual.locked = !s:manual.locked
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#dump() "{{{
  call s:manual.dump()
  " echo s:manual.history
endfunction "}}}

function! quickhl#manual#add(pattern, escaped) "{{{
  if !s:manual.enabled | call quickhl#manual#enable() | endif
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
  call s:manual.init()
  let  s:manual.enabled = 1
  call s:manual.inject_keywords()

  augroup QuickhlManual
    autocmd!
    autocmd VimEnter,WinEnter * call quickhl#manual#refresh()
    autocmd! ColorScheme * call quickhl#manual#init_highlight()
  augroup END
  call quickhl#manual#init_highlight()
  call quickhl#manual#refresh()
endfunction "}}}

function! quickhl#manual#disable() "{{{
  let s:manual.enabled = 0
  augroup QuickhlManual
    autocmd!
  augroup END
  autocmd! QuickhlManual
  call quickhl#manual#reset()
endfunction "}}}

function! quickhl#manual#refresh() "{{{
  call quickhl#windo(s:manual.refresh, s:manual)
endfunction "}}}

function! quickhl#manual#status() "{{{
  echo s:manual.enabled
endfunction "}}}

function! quickhl#manual#init_highlight() "{{{
  call s:manual.init_highlight()
endfunction "}}}

function! quickhl#manual#go_to_next(...) "{{{
  let flags = ""
  if a:0 == 1
    let flags = a:1
  endif
  call s:manual.search("" . flags)
endfunction "}}}

function! quickhl#manual#go_to_prev(...) "{{{
  let flags = ""
  if a:0 == 1
    let flags = a:1
  endif
  call s:manual.search("b" . flags)
endfunction "}}}

function! quickhl#manual#this_motion(motion_wise) " {{{
  let lnum_beg = line("'[")
  let lnum_end = line("']")
  for n in range(lnum_beg, lnum_end)
    let _s = getline(n)
    let s = {
          \  "all":     _s,
          \  "between": _s[col("'[")-1 : col("']")-1],
          \  "pos2end": _s[col("'[")-1 : -1 ],
          \  "beg2pos": _s[ : col("']")-1],
          \  }

    if a:motion_wise == 'char'
      let str =
            \ lnum_beg == lnum_end ?            s.between :
            \ n        == lnum_beg ?            s.pos2end :
            \ n        == lnum_end ?            s.beg2pos :
            \                                   s.all
    elseif a:motion_wise == 'line'  | let str = s.all
    elseif a:motion_wise == 'block' | let str = s.between
    endif

    call quickhl#manual#add_or_del(str, 0)
  endfor
endfunction " }}}

call s:manual.init()
" vim: foldmethod=marker
