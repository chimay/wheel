" vim: ft=vim fdm=indent:

" Adding to tree = toruses / circles / locations
" Renaming
" Removing

fun! wheel#tree#isin (location, circle)
	let local = a:location
	let present = 0
	for elt in a:circle.locations
		if local.file ==# elt.file && local.line == elt.line
			let present = 1
		endif
	endfor
	return present
endfu

fun! wheel#tree#add_torus (...)
	" Add torus
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name = input('New torus name ? ')
	endif
	if index(g:wheel.glossary, torus_name) < 0
		echomsg "Adding torus" torus_name
		let index = g:wheel.current
		let toruses = g:wheel.toruses
		let glossary = g:wheel.glossary
		let template = wheel#void#template(torus_name, 'circles')
		let g:wheel.toruses  = wheel#chain#insert_next(index, template, toruses)
		let g:wheel.glossary = wheel#chain#insert_next(index, torus_name, glossary)
		let g:wheel.current  += 1
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
	else
		echomsg 'Torus' torus_name 'already exists in Wheel.'
	endif
endfu

fun! wheel#tree#add_circle (...)
	" Add circle
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input('New circle name ? ')
	endif
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	let cur_torus = g:wheel.toruses[g:wheel.current]
	if index(cur_torus.glossary, circle_name) < 0
		echomsg "Adding circle" circle_name
		let index = cur_torus.current
		let circles = cur_torus.circles
		let glossary = cur_torus.glossary
		let template = wheel#void#template(circle_name, 'locations')
		let cur_torus.circles  = wheel#chain#insert_next(index, template, circles)
		let cur_torus.glossary = wheel#chain#insert_next(index, circle_name, glossary)
		let cur_torus.current  += 1
	else
		echomsg 'Circle' circle_name 'already exists in Torus' cur_torus.name
	endif
endfu

fun! wheel#tree#add_location (location)
	" Add location
	" Location name will be a:1 if given, or asked otherwise
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	let cur_torus = g:wheel.toruses[g:wheel.current]
	if empty(cur_torus.circles)
		call wheel#tree#add_circle()
	endif
	let local = a:location
	let cur_circle = cur_torus.circles[cur_torus.current]
	let present = wheel#tree#isin(local, cur_circle)
	if ! present
		let chaine = 'New location name [' . local.name . '] ? '
		let location_name = input(chaine)
		if empty(location_name)
			let location_name = local.name
		endif
		if index(cur_circle.glossary, location_name) < 0
			echomsg 'Adding location' local.name ':' local.file ':' local.line ':' local.col
						\ 'in Torus' cur_torus.name 'Circle' cur_circle.name
			let index = cur_circle.current
			let locations = cur_circle.locations
			let glossary = cur_circle.glossary
			let cur_circle.locations  = wheel#chain#insert_next(index, local, locations)
			let cur_circle.current  += 1
			let cur_location = cur_circle.locations[cur_circle.current]
			let cur_location.name = location_name
			let cur_circle.glossary =
						\ wheel#chain#insert_next(index, location_name, glossary)
			call wheel#pendulum#record ()
		else
			echomsg 'Location named' location_name 'already exists in Circle.'
		endif
	else
		echomsg 'Location' local.file ':' local.line
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
		let torus_name = input('Torus name ? ')
	endif
	let cur_torus = wheel#referen#torus ()
	let old_name = cur_torus.name
	let cur_torus.name = torus_name
	let glossary = g:wheel.glossary
	echomsg old_name torus_name join(glossary, ' ')
	let g:wheel.glossary = wheel#chain#replace(old_name, torus_name, glossary)
endfun

fun! wheel#tree#rename_circle (...)
	" Rename current circle
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input('Circle name ? ')
	endif
	let [cur_torus, cur_circle] = wheel#referen#circle ('all')
	let old_name = cur_circle.name
	let cur_circle.name = circle_name
	let glossary = cur_torus.glossary
	let cur_torus.glossary = wheel#chain#replace(old_name, circle_name, glossary)
endfun

fun! wheel#tree#rename_location (...)
	" Rename current location
	if a:0 > 0
		let location_name = a:1
	else
		let location_name = input('Location name ? ')
	endif
	let [cur_torus, cur_circle, cur_location] = wheel#referen#location ('all')
	let old_name = cur_location.name
	let cur_location.name = location_name
	let glossary = cur_circle.glossary
	let cur_circle.glossary = wheel#chain#replace(old_name, location_name, glossary)
endfun

fun! wheel#tree#delete_torus ()
	" Delete current torus
	let cur_torus = wheel#referen#torus ()
	let toruses = g:wheel.toruses
	let cur_index = g:wheel.current
	let cur_length = len(toruses)
	let g:wheel.toruses = wheel#chain#remove_index(cur_index, toruses)
	let cur_length -= 1
	let g:wheel.current = wheel#gear#circular_minus(cur_index, cur_length)
	let glossary = g:wheel.glossary
	let cur_name = cur_torus.name
	let g:wheel.glossary = wheel#chain#remove_element(cur_name, glossary)
endfun

fun! wheel#tree#delete_circle ()
	" Delete current circle
	let [cur_torus, cur_circle] = wheel#referen#circle ('all')
	let circles = cur_torus.circles
	let cur_index = cur_torus.current
	let cur_length = len(circles)
	let cur_torus.circles = wheel#chain#remove_index(cur_index, circles)
	let cur_length -= 1
	let cur_torus.current = wheel#gear#circular_minus(cur_index, cur_length)
	let glossary = cur_torus.glossary
	let cur_name = cur_circle.name
	let cur_torus.glossary = wheel#chain#remove_element(cur_name, glossary)
endfun

fun! wheel#tree#delete_location ()
	" Delete current location
	let [cur_torus, cur_circle, cur_location] =
				\ wheel#referen#location ('all')
	let locations = cur_circle.locations
	let cur_index = cur_circle.current
	let cur_length = len(locations)
	let cur_circle.locations = wheel#chain#remove_index(cur_index, locations)
	let cur_length -= 1
	let cur_circle.current = wheel#gear#circular_minus(cur_index, cur_length)
	let glossary = cur_circle.glossary
	let cur_name = cur_location.name
	let cur_circle.glossary = wheel#chain#remove_element(cur_name, glossary)
endfun
