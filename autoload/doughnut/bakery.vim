" vim: set filetype=vim:

fun! doughnut#bakery#init ()
	let s:donut = {}
	let s:donut.toruses = {}
endfu

fun! doughnut#bakery#print ()
	echo s:donut
endfu

fun! doughnut#bakery#add_torus (torus_name)
	exe 'let s:donut.toruses.' . a:torus_name . ' = {}'
	let s:donut.current_torus = a:torus_name
endfu

fun! doughnut#bakery#add_circle (circle_name)
	let current_torus = s:donut.current_torus
	exe 'let s:donut.toruses.' . current_torus . '.' . a:circle_name . ' = []'
endfu
