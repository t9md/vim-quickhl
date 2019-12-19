function! quickhl#get_selected_text() "{{{
"copy & paste from tyru's open-browser.vim
  let save_z = getreg('z', 1)
  let save_z_type = getregtype('z')
  try
    silent normal! gv"zy
    return substitute(@z,"\n.*",'','')
  finally
    call setreg('z', save_z, save_z_type)
  endtry
endfunction "}}}

function! quickhl#warn(error) "{{{
	echohl WarningMsg
  echomsg 'quickhl:  ' . a:error
  echohl None
endfunction "}}}

let s:metachar = '\/~ .*^[''$'
function! quickhl#escape(pattern) "{{{
  return escape(a:pattern, s:metachar)
endfunction "}}}

function! quickhl#our_match(pattern) "{{{
  return filter(getmatches(), "v:val.group =~# '". a:pattern . "'")
endfunction "}}}

function! quickhl#windo(func, obj) abort "{{{
  " [BUG] This function is invoked from WinEnter event.
  " Unexpectedly, this event is happen before buffer is not shown on window when invoke `pedit file`.
  " So here I will skip unxexisting buffer(which return `-1`) to avoid E994 error.
  if exists('*bufwinid')
    if bufwinid('') ==# -1
      return
    endif
  endif
  if exists('*win_execute')
    call map(range(1, winnr('$')), "win_execute(win_getid(v:val), 'call call(a:func, [], a:obj)')")
  else
    let winnum = winnr()
    let pwinnum = winnr('#')
    " echo [pwinnum, winnum]
    " echo PP(a:func)
    " echo PP(a:obj)
    noautocmd windo call call(a:func, [], a:obj)

    if pwinnum !=# 0
      execute pwinnum . "wincmd w"
    endif
    execute winnum . "wincmd w"
  endif
endfunction "}}}

" vim: foldmethod=marker
