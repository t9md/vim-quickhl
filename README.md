Command
-----------------------------------------------------------------
* QuickHLList         #Show registerd keyword list with color.
* QuickHLClear        #Clear all.
* QuickHLShowColors   #Check colors.
* QuickHLRenewColors  #Re-initialize color table.
* QuickHLAdd          #Add word.
    :QuickHLAdd the_word
* QuickHLDel          #Delete word.
    :QuickHLDel the_word

KeyMap Example
-----------------------------------------------------------------
    nmap <Space>m <Plug>(quickhl#toggle)
    vmap <Space>m <Plug>(quickhl#toggle)
    nmap <Space>M <Plug>(quickhl#clear_all)

