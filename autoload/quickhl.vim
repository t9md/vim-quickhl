let s:o = {}
let s:o.name = "QuickHL"

function! s:o.init_color()"{{{
    for num in range(len(g:quick_hl_colors))
        let cmd = "highlight QuickMatch". num . " " . g:quick_hl_colors[num]
        exe cmd
    endfor
endfunction"}}}

function! s:o.show_colors()"{{{
    for num in range(len(g:quick_hl_colors))
        let cmd = "highlight QuickMatch". num
        exe cmd
    endfor
endfunction"}}}

function! s:o.init()"{{{
    let self.keywords = {}
    let self.pointer = 0
    call self.init_color()
endfunction"}}}

function! s:o.inc_pointer()"{{{
    let self.pointer = (self.pointer + 1) % len(g:quick_hl_colors)
endfunction"}}}

function! s:o.debug(msg)"{{{
    if !g:quick_hl_debug
        return
    endif
    echo "[". self.name."] " . string(a:msg)
endfunction"}}}

function! s:o.add_keyword(word)"{{{
    call self.debug("word added: " . a:word)
    let idx = self.id_for(a:word)
    call self.debug("id is " . idx)
    if idx != -1
        call self.debug("dup " . a:word)
        let self.keywords[idx] = a:word
    else
        call self.debug("new " . a:word)
        let self.keywords[self.pointer] = a:word
    endif
        call self.inc_pointer()
endfunction"}}}

function! s:o.delete_keyword(word)"{{{
    let idx = self.id_for(a:word)
    call remove(self.keywords, idx)
    call self.debug("word deleted: " . a:word)
endfunction"}}}

function! s:o.id_for(word)"{{{
    for [key, val] in items(self.keywords)
        if val == a:word
            return key
        endif
    endfor
    return -1
endfunction"}}}

function! s:o.do(word)"{{{
    call self.debug("do for " . a:word)
    let idx = self.id_for(a:word)
    call self.debug("in do idx was " . idx)
    if idx == -1 | return | endif
    let cmd = self.syn_cmd_for(idx)
    call self.debug("cmd :" . cmd)
    exe cmd
endfunction"}}}

function! s:o.syn_cmd_for(num)"{{{
    call self.debug("in syn_cmd_for")
    call self.debug(self.keywords)
    let keyword = self.keywords[a:num]
    let cmd = "syntax match QuickMatch" . a:num . " '" .  keyword . "' " . "containedin=ALL"
    return cmd
endfunction"}}}

function! s:o.do_by_num(num)"{{{
    let cmd = self.syn_cmd_for(a:num)
    exe cmd
    " exe `self.syn_cmd_for(a:num)`
endfunction"}}}

function! s:o.list() "{{{
    for num in range(len(self.keywords))
        exe 'echohl QuickMatch' . num
        echo num self.keywords[num]
        echohl None
    endfor
endfunction"}}}

" function! s:o.list() "{{{
    " for [num, word] in items(self.keywords)
        " echo num word
    " endfor
" endfunction"}}}
function! s:o.clear_all()"{{{
    for num in range(len(g:quick_hl_colors))
        let cmd = "syntax clear QuickMatch" . num
        exe cmd
    endfor
    let self.keywords = {}
    let self.pointer = 0
endfunction"}}}

function! s:o.clear_for(word)"{{{
    let idx = self.id_for(a:word)
    if idx == -1 | return | endif
    let cmd = "syntax clear QuickMatch" . idx
    exe cmd
endfunction"}}}

function! s:o.toggle_for(word)"{{{
    let idx = self.id_for(a:word)
    if idx == -1
        call self.add_keyword(a:word)
        call self.do(a:word)
    else
        let cmd = "syntax clear QuickMatch" . idx
        exe cmd
        call self.delete_keyword(a:word)
    endif
    call self.debug( self.keywords )
endfunction"}}}

call s:o.init()

" PublicInterface:
function! quickhl#toggle(mode)"{{{
    if a:mode == 'v'
        normal `<
        let s = col('.') - 1
        normal `>
        let e = col('.') - 1
        let line = getline('.')
        let pat = line[s : e]
    else
        let pat = expand('<cword>')
    endif
    let pat = escape(pat, '/')
    call s:o.toggle_for(pat)
endfunction"}}}

function! quickhl#list()"{{{
    call s:o.list()
endfunction"}}}

function! quickhl#clear_all()"{{{
    call s:o.clear_all()
endfunction"}}}

function! quickhl#add(word)"{{{
    call s:o.add_keyword(a:word)
    call s:o.do(a:word)
endfunction"}}}

function! quickhl#show_colors()"{{{
    call s:o.show_colors()
endfunction"}}}

function! quickhl#delete(word)"{{{
    let idx = s:o.id_for(a:word)
    call s:o.debug("delete for " . idx)
    if idx != -1
        let cmd = "syntax clear QuickMatch" . idx
        exe cmd
        call s:o.delete_keyword(a:word)
    endif
endfunction"}}}

function! quickhl#renew_colors()"{{{
    call s:o.init_color()
endfunction"}}}

" vim: set sw=4 sts=4 et fdm=marker:
