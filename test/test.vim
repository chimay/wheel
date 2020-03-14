" vim: set filetype=vim:

" let a=[1,2,3]
" let b=[4,5,6]
" echo wheel#gear#insert(a,b)

call wheel#void#reset()
call wheel#tree#add_here()
echo g:wheel
call wheel#disc#write("g:wheel", "~/racine/test/vim/wheel")
