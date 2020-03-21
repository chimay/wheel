" vim: set filetype=vim:

call wheel#referen#print()
call wheel#disc#write('g:wheel', g:wheel_config['file'])
call wheel#disc#read("~/racine/test/vim/wheel")

call wheel#vortex#next_torus()
call wheel#vortex#prev_torus()
call wheel#vortex#next_circle()
call wheel#vortex#prev_circle()
call wheel#vortex#next_location()
call wheel#vortex#prev_location()
