" vim: set filetype=vim:

fun! doughnut#bakery#init ()
	let g:donut = {}
	let g:donut.toruses = {}
endfu

fun! doughnut#bakery#print ()
	echo g:donut
endfu

fun! doughnut#bakery#add_torus (torus_name)
	exe 'let g:donut.toruses.' . a:torus_name . ' = {}'
	let g:donut.current_torus = a:torus_name
endfu

fun! doughnut#bakery#add_circle (circle_name)
	let current_torus = g:donut.current_torus
	exe 'let g:donut.toruses.' . current_torus . '.' . a:circle_name . ' = []'
endfu
