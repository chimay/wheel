" vim: set filetype=vim:

fun! wheel#vortex#init ()
endfu

fun! wheel#vortex#reset ()
	let g:wheel = {}
endfu

fun! wheel#vortex#template(name)
	let template = [{}]
	let template[0].name = a:name
	return template
endfun

fun! wheel#vortex#here ()
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col  = col('.')
	return location
endfun

fun! wheel#vortex#print ()
	echo g:wheel
endfu

fun! wheel#vortex#add_torus (...)
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name = input("New torus name ? ")
	endif
	if empty(g:wheel)
		let g:wheel.toruses = []
		let g:wheel.glossary = []
		let g:wheel.current = -1
	endif
	if index(g:wheel.glossary, torus_name) < 0
		echo "Adding torus" torus_name
		let index = g:wheel.current
		let toruses = g:wheel.toruses
		let g:wheel.toruses  = toruses[0:index] + wheel#vortex#template(torus_name) + toruses[index+1:-1]
		let g:wheel.glossary += [torus_name]
		let g:wheel.current  += 1
	endif
endfu

fun! wheel#vortex#add_circle (...)
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input("New circle name ? ")
	endif
	let cur_torus = g:wheel.toruses[g:wheel.current]
	if ! has_key(cur_torus, 'circles')
		let cur_torus.circles = []
		let cur_torus.glossary = []
		let cur_torus.current = -1
	endif
	if index(cur_torus.glossary, circle_name) < 0
		echo "Adding circle" circle_name
		let index = cur_torus.current
		let circles = cur_torus.circles
		let cur_torus.circles  = circles[0:index] + wheel#vortex#template(circle_name) + circles[index+1:-1]
		let cur_torus.glossary += [circle_name]
		let cur_torus.current  += 1
	endif
endfu

fun! wheel#vortex#add_location (location)
	if empty(g:wheel)
		call wheel#vortex#add_torus()
	endif
	let cur_torus = g:wheel.toruses[g:wheel.current]
	if ! has_key(cur_torus, 'circles')
		call wheel#vortex#add_circle()
	endif
	let cur_circle = cur_torus.circles[cur_torus.current]
	if ! has_key(cur_circle, 'locations')
		let cur_circle.locations = []
		let cur_circle.current = -1
	endif
	if index(cur_circle.locations, a:location) < 0
		echo "Adding location" a:location
		let index = cur_circle.current
		let locations = cur_circle.locations
		let cur_circle.locations  = locations[0:index] + [a:location] + locations[index+1:-1]
		let cur_circle.current  += 1
	endif
endfun

fun! wheel#vortex#add_here()
	let here = wheel#vortex#here()
	call wheel#vortex#add_location(here)
endfun

fun! wheel#vortex#add_file(...)
	if a:0 > 0
		let file = a:1
	else
		let file = input("File to add ? ")
	endif
	exe 'edit ' file
	call wheel#vortex#add_here()
endfun
