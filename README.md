# Highlight on the fly.
quickhl.vim support highlight for
* manual keywords
* `tag` in ctags generated file
* automatically higlight word under cursor(`<cword>`).

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
nmap <Space>M <Plug>(quickhl-manual-reset)
xmap <Space>M <Plug>(quickhl-manual-reset)

nmap <Space>j <Plug>(quickhl-cword-toggle)
nmap <Space>] <Plug>(quickhl-tag-toggle)
map H <Plug>(operator-quickhl-manual-this-motion)
```
  
# Movie
![Example](https://github.com/t9md/t9md/blob/master/img/vim-quickhl_anime.gif?raw=true)


![Movie](http://gifzo.net/xGOtmydHwZ.gif)


* [help](https://github.com/t9md/vim-quickhl/blob/master/doc/quickhl.txt)
