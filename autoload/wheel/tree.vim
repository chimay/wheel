" vim: set filetype=vim:

" Growing tree

fun! wheel#tree#add_torus (...)
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
		let template = wheel#gear#template(torus_name)
		let g:wheel.toruses  = wheel#gear#insert(template, toruses, index)
		let g:wheel.glossary += [torus_name]
		let g:wheel.current  += 1
	endif
endfu

fun! wheel#tree#add_circle (...)
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
		let template = wheel#gear#template(circle_name)
		let cur_torus.circles  = wheel#gear#insert(template, circles, index)
		let cur_torus.glossary += [circle_name]
		let cur_torus.current  += 1
	endif
endfu

fun! wheel#tree#add_location (location)
	if empty(g:wheel)
		call wheel#tree#add_torus()
	endif
	let cur_torus = g:wheel.toruses[g:wheel.current]
	if ! has_key(cur_torus, 'circles')
		call wheel#tree#add_circle()
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
		let cur_circle.locations  = wheel#gear#insert([a:location], locations, index)
		let cur_circle.current  += 1
	endif
endfun

fun! wheel#tree#add_here()
	let here = wheel#vortex#here()
	call wheel#tree#add_location(here)
endfun

fun! wheel#tree#add_file(...)
	if a:0 > 0
		let file = a:1
	else
		let file = input("File to add ? ")
	endif
	exe 'edit ' file
	call wheel#tree#add_here()
endfun

fun! wheel#tree#name_location ()
	if a:0 > 0
		let location_name = a:1
	else
		let location_name = input("Location name ? ")
	endif
	let cur_location = wheel#mandala#current_location ()
	let cur_location.name = location_name
endfun
