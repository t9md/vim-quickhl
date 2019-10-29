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

function! quickhl#windo(func, obj) "{{{
  let winnum = winnr()
  let pwinnum = winnr('#')
  " echo [pwinnum, winnum]
  " echo PP(a:func)
  " echo PP(a:obj)
  "
  let all_win = range(1, winnr('$'))
  let popup_win = popup_findinfo()

  if popup_win !=# 0
    call filter(all_win, 'v:val !=# popup_win')
  endif

  for winno in all_win
    noautocmd execute winno . "windo call call(a:func, [], a:obj)"
  endfor

  if pwinnum !=# 0
    execute pwinnum . "wincmd w"
  endif
  execute winnum . "wincmd w"
endfunction "}}}

" vim: foldmethod=marker
