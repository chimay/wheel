" vim: set filetype=vim:

fun! wheel#vortex#init ()
endfu

fun! wheel#vortex#reset ()
	let g:wheel = {}
endfu

fun! wheel#vortex#print ()
	echo g:wheel
endfu

fun! wheel#vortex#add_torus (...)
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name = input("New torus name ? ")
	endif
	if ! has_key(g:wheel.toruses, torus_name)
		echo "Adding torus" torus_name
		let g:wheel.current = torus_name
		let g:wheel.toruses[torus_name] = {}
	endif
endfu

fun! wheel#vortex#add_circle (circle_name)
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input("New circle name ? ")
	endif
	let torus_name = g:wheel.current
	let cur_torus = g:wheel.toruses[torus_name]
	if ! has_key(cur_torus, circle_name)
		echo "Adding circle" circle_name
		let g:wheel.toruses[torus_name].current = circle_name
		let g:wheel.toruses[torus_name].circles[circle_name] = {}
	endif
endfu

fun! wheel#vortex#add_location ()
	if empty(g:wheel)
		call wheel#vortex#add_torus()
	endif
	let torus_name = g:wheel.current
	let cur_torus = g:wheel.toruses[torus_name]
	if empty(g:wheel.toruses[torus_name])
		call wheel#vortex#add_circle()
	endif
	let circle_name = cur_torus.current
	let cur_circle = cur_torus.circles[circle_name]
	let here = wheel#vortex#here()
	if index(cur_circle.locations, here) < 0
		echo "Adding location" here
		let g:wheel.toruses[torus_name].circles[circle_name].current = circle_name
		let g:wheel.toruses[torus_name].circles[circle_name].circles[circle_name] = here
	endif
endfun

fun! wheel#vortex#here ()
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col  = col('.')
	return location
endfun
