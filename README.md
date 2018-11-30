![](https://github.com/t9md/t9md/raw/dc52eaf0f8cb0984697f42c50be09174117b2ddb/img/quickhl_anime.gif)

[help](https://github.com/t9md/vim-quickhl/blob/master/doc/quickhl.txt)

# Highlight on the fly.

quickhl.vim support highlight for

- manual keywords
- `tag` in ctags generated file
- automatically highlight word under cursor(`<cword>`).

# Config

Minimum
```Vim
nmap <Space>m <Plug>(quickhl-manual-this)
xmap <Space>m <Plug>(quickhl-manual-this)
nmap <Space>M <Plug>(quickhl-manual-reset)
xmap <Space>M <Plug>(quickhl-manual-reset)
```

Full
```Vim
nmap <Space>m <Plug>(quickhl-manual-this)
xmap <Space>m <Plug>(quickhl-manual-this)

nmap <Space>w <Plug>(quickhl-manual-this-whole-word)
xmap <Space>w <Plug>(quickhl-manual-this-whole-word)

nmap <Space>c <Plug>(quickhl-manual-clear)
vmap <Space>c <Plug>(quickhl-manual-clear)

nmap <Space>M <Plug>(quickhl-manual-reset)
xmap <Space>M <Plug>(quickhl-manual-reset)

nmap <Space>j <Plug>(quickhl-cword-toggle)
nmap <Space>] <Plug>(quickhl-tag-toggle)
map H <Plug>(operator-quickhl-manual-this-motion)
```
