let s:def_str = "THE_WORD_ALWAYS_HIGHLIGTED_IS_THE_WORD_YOUD_NEVER_USE"
let s:o = {}
let s:o.name = "QuickHL"
function! s:o.debug(msg)"{{{
    if !g:quickhl_debug | return | endif
    echo "[". self.name. "] " . a:msg
endfunction"}}}
function! s:o.init()"{{{
    let  self.idx = 0
    let  self.kwlist = {}
    call s:o.read_colors( g:quickhl_colors )
    call s:o.init_highlight()
endfunction"}}}
function! s:o.refresh()"{{{
    call self.syn_clear()
    call self.init_highlight()
    call self.highlight_all()
endfunction"}}}
function! s:o.reset()"{{{
    call self.syn_clear()
    call self.init()
endfunction"}}}
function! s:o.read_colors(list)"{{{
    let self.colors = map(copy(a:list),
                \ '{ "hlname": "Quickhl".v:key, "hlval": v:val, "keyword": s:def_str }')
endfunction"}}}
function! s:o.init_highlight()"{{{
    call self.each_color_exe('"highlight " . c.hlname . " " . c.hlval')
endfunction"}}}

function! s:o.inc_idx()"{{{
    let self.idx = (self.idx + 1) % len(self.colors)
endfunction"}}}
function! s:o.each_color_exe(exp)"{{{
    for c in self.colors
        exe eval(a:exp)
    endfor
endfunction"}}}
function! s:o.each_color_call(f)"{{{
    for c in self.colors
        call call(a:f, [c], self)
    endfor
endfunction"}}}
function! s:o.syn_clear()"{{{
    call self.each_color_exe('"syn clear " . c.hlname')
endfunction"}}}
function! s:o.highlight_all()"{{{
    call self.each_color_call(self.highlight)
endfunction"}}}
function! s:o.highlight(c)"{{{
    exe "syntax match " a:c.hlname . " '" . escape(a:c.keyword, "'") . "' containedin=ALL"
endfunction"}}}
function! s:o.show_colors()"{{{
    call self.each_color_exe('"highlight " . c.hlname')
endfunction"}}}
function! s:o.add(word)"{{{
    " guard duplicate entry
    if self.has_keyword(a:word)
        call self.debug("dup: " . a:word)
        return -1
    endif
    let  self.colors[self.idx].keyword = a:word
    let  self.kwlist[a:word] = self.idx
    call self.debug("new: " . a:word)
    call self.inc_idx()
    call self.refresh()
endfunction"}}}
function! s:o.del(word)"{{{
    let idx = get(self.kwlist, a:word, -1)
    if idx != -1
        let self.colors[idx].keyword = s:def_str
        call remove(self.kwlist, a:word)
        call self.debug("del: " . a:word)
        call s:o.refresh()
    endif
endfunction"}}}
function! s:o.list()"{{{
    for idx in sort(values(self.kwlist))
        let c = self.colors[idx]
        exe  "echohl ". c.hlname|echo c.keyword|echohl None
    endfor
endfunction"}}}
function! s:o.has_keyword(word)"{{{
    return has_key(self.kwlist, a:word)
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
