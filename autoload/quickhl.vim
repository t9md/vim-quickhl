let s:def_str = "THE_WORD_ALWAYS_HIGHLIGTED_IS_THE_WORD_YOUD_NEVER_USE"
let s:o = {}
let s:o.name = "QuickHL"
function! s:o.debug(msg)"{{{
    if !g:quickhl_debug | return | endif
    echo "[". self.name. "] " . a:msg
endfunction"}}}
function! s:o.init()"{{{
    let self.pointer = 0
    call s:o.read_colors( g:quickhl_colors )
    call s:o.init_highlight()
endfunction"}}}
function! s:o.inc_pointer()"{{{
    let self.pointer = (self.pointer + 1) % len(self.colors)
    return self.pointer
endfunction"}}}
function! s:o.read_colors(list)"{{{
    let self.colors = []
    for idx in range(len(a:list))
        call add(self.colors, {
                    \ "hlname" : "QuickHL".idx,
                    \ "hlval" : a:list[idx],
                    \ "keyword" : s:def_str,
                    \ })
    endfor
endfunction"}}}
function! s:o.init_highlight()"{{{
    for c in self.colors
        exe  "highlight " . c.hlname . " " . c.hlval
    endfor
    call self.debug("init_hl")
endfunction"}}}
function! s:o.syn_clear()"{{{
    for c in self.colors
        exe "syn clear " . c.hlname
    endfor
endfunction"}}}
function! s:o.highlight_all()"{{{
    for c in self.colors
        call self.highlight(c)
    endfor
endfunction"}}}
function! s:o.refresh()"{{{
    call self.syn_clear()
    call self.init_highlight()
    call self.highlight_all()
endfunction"}}}
function! s:o.highlight(c)"{{{
    let c = a:c
    let keyword = escape(c.keyword, "'")
    exe "syntax match " c.hlname . " '" . keyword . "' containedin=ALL"
endfunction"}}}
function! s:o.show_colors()"{{{
    for c in self.colors
        exe "highlight " . c.hlname
    endfor
endfunction"}}}
function! s:o.add(word)"{{{
    " guard duplicate entry
    if self.has_keyword(a:word)
        call self.debug("dup: " . a:word)
        return -1
    endif
    let idx = self.pointer
    let self.colors[idx].keyword = a:word
    call self.debug("new: " . a:word)
    call self.inc_pointer()
    call self.refresh()
endfunction"}}}
function! s:o.del(word)"{{{
    for c in self.colors
        if c.keyword == a:word
            let c.keyword = s:def_str
        endif
    endfor
    call s:o.refresh()
endfunction"}}}
function! s:o.list()"{{{
    for c in filter(copy(self.colors), 'v:val.keyword != s:def_str ')
        exe  "echohl ". c.hlname
        echo c.keyword
        echohl None
    endfor
endfunction"}}}
function! s:o.has_keyword(word)"{{{
    return len(filter(copy(self.colors), 'v:val.keyword == a:word')) != 0
endfunction"}}}
function! s:o.reset()"{{{
    call self.syn_clear()
    call self.init()
endfunction"}}}
function! s:o.toggle(word)"{{{
    if !self.has_keyword(a:word)
        call self.add(a:word)
    else
        call self.del(a:word)
    endif
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
    call s:o.toggle(pat)
endfunction"}}}
function! quickhl#list()"{{{
    call s:o.list()
endfunction"}}}
function! quickhl#reset()"{{{
    call s:o.reset()
endfunction"}}}
function! quickhl#add(word)"{{{
    call s:o.add(a:word)
endfunction"}}}
function! quickhl#del(word)"{{{
    call s:o.del(a:word)
endfunction"}}}
function! quickhl#colors()"{{{
    call s:o.show_colors()
endfunction"}}}
function! quickhl#refresh()"{{{
    call s:o.refresh()
endfunction"}}}

" vim: set sw=4 sts=4 et fdm=marker:
