" vim: set filetype=vim:

fun! wheel#vortex#init ()
endfu

fun! wheel#vortex#reset ()
	let g:wheel = {}
endfu

fun! wheel#vortex#print ()
	echo g:wheel
endfu

fun! wheel#vortex#add_torus (torus_name)
	exe 'let g:wheel.' . a:torus_name . ' = {}'
	let g:wheel.current_torus = a:torus_name
endfu

fun! wheel#vortex#add_circle (circle_name)
	let current_torus = g:wheel.current_torus
	exe 'let g:wheel.toruses.' . current_torus . '.' . a:circle_name . ' = []'
endfu
