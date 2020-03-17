" vim: set filetype=vim:

" let a=[1,2,3]
" let b=[4,5,6]
" echo wheel#gear#insert(a,b)

call wheel#mandala#print()
call wheel#disc#write('g:wheel', g:wheel_config['file'])
call wheel#disc#read("~/racine/test/vim/wheel")

call wheel#vortex#next_torus()
call wheel#vortex#prev_torus()
call wheel#vortex#next_circle()
call wheel#vortex#prev_circle()
call wheel#vortex#next_location()
call wheel#vortex#prev_location()
