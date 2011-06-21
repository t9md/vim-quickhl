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
                    \ })
    endfor
endfunction"}}}
function! s:o.init_highlight()"{{{
    for c in self.colors
        let cmd = "highlight " . c.hlname . " " . c.hlval
        exe cmd
    endfor
    call self.debug("init_hl")
endfunction"}}}
function! s:o.refresh()"{{{
    for c in self.colors
        exe "syn clear " . c.hlname
    endfor
    call self.init_highlight()
    for c in self.colors
        if has_key(c, "keyword")
            call self.highlight(c)
        endif
    endfor
endfunction"}}}
function! s:o.highlight(c)"{{{
    let c = a:c
    let keyword = escape(c.keyword, "'")
    exe "syntax match " c.hlname . " '" . keyword . "' containedin=ALL"
endfunction"}}}
function! s:o.show_colors()"{{{
    for c in self.colors
        let cmd = "highlight " . c.hlname
        exe cmd
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

    let c = self.colors[idx]
    call self.highlight(c)
endfunction"}}}
function! s:o.del(word)"{{{
    for idx in range(len(self.colors))
        let c = self.colors[idx]
        if has_key(c, "keyword") && c.keyword == a:word
            call self.debug("del: " . a:word)
            let cmd = "syntax clear " . c.hlname
            exe cmd
            call remove(c, "keyword")
        endif
    endfor
endfunction"}}}
function! s:o.list()"{{{
    for c in self.colors
        if !has_key(c, "keyword") | continue | endif
        let cmd =  "echohl ". c.hlname
        exe cmd
        echo c.keyword
        echohl None
    endfor
endfunction"}}}
function! s:o.has_keyword(word)"{{{
    for c in self.colors
        if has_key(c, "keyword") && c.keyword == a:word
            return 1
        endif
    endfor
    return 0
endfunction"}}}
function! s:o.get_color(word)"{{{
    for num in range(len(self.colors))
        let c = self.colors[num]
        if has_key(c, "keyword") && c.keyword == a:word
            return c
        endif
    endfor
    return -1
endfunction"}}}
function! s:o.reset()"{{{
    for c in self.colors
        exe "syn clear " . c.hlname
    endfor
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
