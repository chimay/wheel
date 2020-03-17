" vim: set filetype=vim:

" let a=[1,2,3]
" let b=[4,5,6]
" echo wheel#gear#insert(a,b)

call wheel#void#reset()
call wheel#tree#add_here()
normal 2j
normal 2h
call wheel#tree#add_here()
normal 3j
normal 4l
call wheel#tree#add_here()
call wheel#mandala#print()
call wheel#disc#write("g:wheel", "~/racine/test/vim/wheel")

call wheel#vortex#next_torus()
call wheel#vortex#prev_torus()
call wheel#vortex#next_circle()
call wheel#vortex#prev_circle()
call wheel#vortex#next_location()
call wheel#vortex#prev_location()
