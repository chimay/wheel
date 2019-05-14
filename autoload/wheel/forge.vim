" vim: set filetype=vim:

fun! wheel#bakery#init ()
	let g:donut = {}
	let g:donut.toruses = {}
endfu

fun! wheel#bakery#print ()
	echo g:donut
endfu

fun! wheel#bakery#add_torus (torus_name)
	exe 'let g:donut.toruses.' . a:torus_name . ' = {}'
	let g:donut.current_torus = a:torus_name
endfu

fun! wheel#bakery#add_circle (circle_name)
	let current_torus = g:donut.current_torus
	exe 'let g:donut.toruses.' . current_torus . '.' . a:circle_name . ' = []'
endfu
