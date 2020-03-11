" vim: set filetype=vim:

fun! wheel#forge#init ()
endfu

fun! wheel#forge#reset ()
	let g:wheel = {}
endfu

fun! wheel#forge#print ()
	echo g:wheel
endfu

fun! wheel#forge#add_torus (torus_name)
	exe 'let g:wheel.' . a:torus_name . ' = {}'
	let g:wheel.current_torus = a:torus_name
endfu

fun! wheel#forge#add_circle (circle_name)
	let current_torus = g:wheel.current_torus
	exe 'let g:wheel.toruses.' . current_torus . '.' . a:circle_name . ' = []'
endfu
