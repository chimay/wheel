" vim: set filetype=vim:

" Adding to tree = toruses / circles / locations
" Removing from tree

fun! wheel#tree#add_torus (...)
	" Add torus
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
		echomsg "Adding torus" torus_name
		let index = g:wheel.current
		let toruses = g:wheel.toruses
		let template = wheel#gear#template(torus_name)
		let g:wheel.toruses  = wheel#list#insert_next(index, template, toruses)
		let g:wheel.glossary += [torus_name]
		let g:wheel.current  += 1
	else
		echomsg 'Torus' torus_name 'already exists in Wheel.'
	endif
endfu

fun! wheel#tree#add_circle (...)
	" Add circle
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input("New circle name ? ")
	endif
	if empty(g:wheel)
		call wheel#tree#add_torus()
	endif
	let cur_torus = g:wheel.toruses[g:wheel.current]
	if ! has_key(cur_torus, 'circles')
		let cur_torus.circles = []
		let cur_torus.glossary = []
		let cur_torus.current = -1
	endif
	if index(cur_torus.glossary, circle_name) < 0
		echomsg "Adding circle" circle_name
		let index = cur_torus.current
		let circles = cur_torus.circles
		let template = wheel#gear#template(circle_name)
		let cur_torus.circles  = wheel#list#insert_next(index, template, circles)
		let cur_torus.glossary += [circle_name]
		let cur_torus.current  += 1
	else
		echomsg 'Circle' circle_name 'already exists in Torus' cur_torus.name
	endif
endfu

fun! wheel#tree#add_location (location, ...)
	" Add location
	" If location contains no name,
	" it will be a:1 if given, or asked otherwise
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
		let cur_circle.glossary = []
		let cur_circle.current = -1
	endif
	let locat = a:location
	let present = 0
	for loc in cur_circle.locations
		if locat.file == loc.file && locat.line == loc.line
			let present = 1
		endif
	endfor
	if ! present
		if ! has_key(locat, 'name') || empty(locat.name)
			if a:0 > 1
				let location_name = a:1
			else
				let location_name = input("New location name ? ")
			endif
			if ! empty(location_name)
				if index(cur_circle.glossary, location_name) < 0
					echomsg 'Adding location' locat.file ':' locat.line ':' locat.col
								\ 'in Torus' cur_torus.name 'Circle' cur_circle.name
					let index = cur_circle.current
					let locations = cur_circle.locations
					let cur_circle.locations  = wheel#list#insert_next(index, locat, locations)
					let cur_circle.current  += 1
					let cur_location = cur_circle.locations[cur_circle.current]
					let cur_location.name = location_name
					let cur_circle.glossary += [location_name]
				else
					echomsg 'Location named' location_name 'already exists in Circle.'
				endif
			else
				echomsg 'Location name must not be an empty string.'
			endif
		endif
	else
		echomsg 'Location' locat.file ':' locat.line ':' locat.col
					\ 'already exists in Torus' cur_torus.name 'Circle' cur_circle.name
	endif
endfun

fun! wheel#tree#add_here ()
	" Add here to locations
	let here = wheel#vortex#here()
	call wheel#tree#add_location(here)
endfun

fun! wheel#tree#add_file(...)
	" Add file to location
	if a:0 > 0
		let file = a:1
	else
		let file = input("File to add ? ")
	endif
	exe 'edit ' file
	call wheel#tree#add_here()
endfun

fun! wheel#tree#rename_torus (...)
	" Rename current torus
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name = input("Torus name ? ")
	endif
	let cur_torus = wheel#referen#torus ()
	let old_name = cur_torus.name
	let cur_torus.name = torus_name
	let glossary = g:wheel.glossary
	echomsg old_name torus_name join(glossary, ' ')
	let g:wheel.glossary = wheel#list#replace(old_name, torus_name, glossary)
endfun

fun! wheel#tree#rename_circle (...)
	" Rename current circle
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input("Circle name ? ")
	endif
	let [cur_torus, cur_circle] = wheel#referen#circle ('all')
	let old_name = cur_circle.name
	let cur_circle.name = circle_name
	let glossary = cur_torus.glossary
	let cur_torus.glossary = wheel#list#replace(old_name, circle_name, glossary)
endfun

fun! wheel#tree#rename_location (...)
	" Rename current location
	if a:0 > 0
		let location_name = a:1
	else
		let location_name = input("Location name ? ")
	endif
	let [cur_torus, cur_circle, cur_location] = wheel#referen#location ('all')
	let old_name = cur_location.name
	let cur_location.name = location_name
	let glossary = cur_circle.glossary
	let cur_circle.glossary = wheel#list#replace(old_name, location_name, glossary)
endfun

fun! wheel#tree#delete_torus ()
	" Delete current torus
	let cur_torus = wheel#referen#torus ()
	let toruses = g:wheel.toruses
	let cur_index = g:wheel.current
	let cur_length = len(g:wheel.toruses)
	let g:wheel.toruses = wheel#list#remove_index(cur_index, toruses)
	let g:wheel.current = wheel#gear#circular_minus(cur_index, cur_length)
	let glossary = g:wheel.glossary
	let cur_name = cur_torus.name
	let g:wheel.glossary = wheel#list#remove_element(cur_name, glossary)
endfun

fun! wheel#tree#delete_circle ()
	" Delete current circle
	let [cur_torus, cur_circle] = wheel#referen#circle ('all')
	let circles = cur_torus.circles
	let cur_index = cur_torus.current
	let cur_length = len(cur_torus.circles)
	let cur_torus.circles = wheel#list#remove_index(cur_index, circles)
	let cur_torus.current = wheel#gear#circular_minus(cur_index, cur_length)
	let glossary = cur_torus.glossary
	let cur_name = cur_circle.name
	let cur_torus.glossary = wheel#list#remove_element(cur_name, glossary)
endfun

fun! wheel#tree#delete_location ()
	" Delete current location
	let [cur_torus, cur_circle, cur_location] =
				\ wheel#referen#location ('all')
	let locations = cur_circle.locations
	let cur_index = cur_circle.current
	let cur_length = len(cur_circle.locations)
	let cur_circle.locations = wheel#list#remove_index(cur_index, locations)
	let cur_circle.current = wheel#gear#circular_minus(cur_index, cur_length)
	let glossary = cur_circle.glossary
	let cur_name = cur_location.name
	let cur_circle.glossary = wheel#list#remove_element(cur_name, glossary)
endfun
