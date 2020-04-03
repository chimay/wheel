" vim: ft=vim fdm=indent:

" Adding to tree = toruses / circles / locations
" Renaming
" Removing

" Notes
"
" To insert a non-breaking space : C-v x a 0

fun! wheel#tree#is_in_circle (location, circle)
	let local = a:location
	let present = 0
	for elem in a:circle.locations
		if elem.file ==# local.file && elem.line == local.line
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
	" Replace spaces par non-breaking spaces
	let torus_name = substitute(torus_name, ' ', ' ', 'g')
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
		echomsg 'Torus' torus_name 'already exists in wheel.'
	endif
endfu

fun! wheel#tree#add_circle (...)
	" Add circle
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input('New circle name ? ')
	endif
	" Replace spaces par non-breaking spaces
	let circle_name = substitute(circle_name, ' ', ' ', 'g')
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
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
	else
		echomsg 'Circle' circle_name 'already exists in torus' cur_torus.name
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
	let cur_circle = cur_torus.circles[cur_torus.current]
	let local = a:location
	let present = wheel#tree#is_in_circle(local, cur_circle)
	if ! present
		let string = 'New location name [' . local.name . '] ? '
		let location_name = input(string, local.name)
		if empty(location_name)
			let location_name = local.name
		endif
		" Replace spaces par non-breaking spaces
		let location_name = substitute(location_name, ' ', ' ', 'g')
		if index(cur_circle.glossary, location_name) < 0
			let string = 'Adding location ' . local.name . ' : '
			let string .= local.file . ':' . local.line . ':' . local.col
			let string .= ' in torus ' . cur_torus.name . ' circle ' . cur_circle.name
			echomsg string
			let index = cur_circle.current
			let locations = cur_circle.locations
			let glossary = cur_circle.glossary
			let cur_circle.locations = wheel#chain#insert_next(index, local, locations)
			let cur_circle.current  += 1
			let cur_location = cur_circle.locations[cur_circle.current]
			let cur_location.name = location_name
			let cur_circle.glossary =
						\ wheel#chain#insert_next(index, location_name, glossary)
			let g:wheel.timestamp = wheel#pendulum#timestamp ()
			call wheel#pendulum#record ()
		else
			echomsg 'Location named' location_name 'already exists in circle.'
		endif
	else
		echomsg 'Location' local.file ':' local.line
					\ 'already exists in torus' cur_torus.name 'circle' cur_circle.name
	endif
endfun

fun! wheel#tree#add_here ()
	" Add here to circle
	let here = wheel#vortex#here()
	call wheel#tree#add_location(here)
endfun

fun! wheel#tree#add_file (...)
	" Add file to circle
	call wheel#vortex#update ()
	if a:0 > 0
		let file = a:1
	else
		let file = input('File to add ? ', '', 'file_in_path')
	endif
	exe 'edit ' file
	call wheel#tree#add_here()
endfun

fun! wheel#tree#add_buffer (...)
	" Add buffer to circle
	call wheel#vortex#update ()
	if a:0 > 0
		let buffer = a:1
	else
		let buffer = input('Buffer to add ? ', '', 'buffer')
	endif
	exe 'buffer ' buffer
	call wheel#tree#add_here()
endfun

fun! wheel#tree#rename_torus (...)
	" Rename current torus
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name = input('Rename torus as ? ')
	endif
	" Replace spaces par non-breaking spaces
	let torus_name = substitute(torus_name, ' ', ' ', 'g')
	if index(g:wheel.glossary, torus_name) < 0
		let cur_torus = wheel#referen#torus ()
		let old_name = cur_torus.name
		echomsg 'Renaming torus' old_name '->' torus_name
		let cur_torus.name = torus_name
		let glossary = g:wheel.glossary
		let g:wheel.glossary = wheel#chain#replace(old_name, torus_name, glossary)
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
		call wheel#pendulum#rename(0, old_name, torus_name)
	else
		echomsg 'Torus' torus_name 'already exists in wheel.'
	endif
endfun

fun! wheel#tree#rename_circle (...)
	" Rename current circle
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input('Rename circle as ? ')
	endif
	" Replace spaces par non-breaking spaces
	let circle_name = substitute(circle_name, ' ', ' ', 'g')
	let [cur_torus, cur_circle] = wheel#referen#circle ('all')
	if index(cur_torus.glossary, circle_name) < 0
		let old_name = cur_circle.name
		let cur_circle.name = circle_name
		echomsg 'Renaming circle' old_name '->' circle_name
		let glossary = cur_torus.glossary
		let cur_torus.glossary = wheel#chain#replace(old_name, circle_name, glossary)
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
		call wheel#pendulum#rename(1, old_name, circle_name)
	else
		echomsg 'Circle' circle_name 'already exists in torus' cur_torus.name
	endif
endfun

fun! wheel#tree#rename_location (...)
	" Rename current location
	if a:0 > 0
		let location_name = a:1
	else
		let location_name = input('Rename location as ? ')
	endif
	" Replace spaces par non-breaking spaces
	let location_name = substitute(location_name, ' ', ' ', 'g')
	let [cur_torus, cur_circle, cur_location] = wheel#referen#location ('all')
	if index(cur_circle.glossary, location_name) < 0
		let old_name = cur_location.name
		let cur_location.name = location_name
		echomsg 'Renaming location' old_name '->' location_name
		let glossary = cur_circle.glossary
		let cur_circle.glossary = wheel#chain#replace(old_name, location_name, glossary)
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
		call wheel#pendulum#rename(2, old_name, location_name)
	else
		echomsg 'Location named' location_name 'already exists in circle.'
	endif
endfun

fun! wheel#tree#rename_file (...)
	if a:0 > 0
		let filename = a:1
	else
		let filename = input('Rename file as ? ')
	endif
	" Replace spaces by underscores
	" Non breaking spaces would be confusing in the user’s filesystem
	let filename = substitute(filename, ' ', '_', 'g')
	if filename[0] != '/'
		let filename = expand('%:p:h') . '/' . filename
	endif
	let location = wheel#referen#location ()
	let old_name = location.file
	let command = 'mv -i '
	let rename = command . old_name . ' ' . filename
	"echomsg rename
	call system(rename)
	if ! v:shell_error
		exe 'file ' . filename
		for torus in g:wheel.toruses
			for circle in torus.circles
				for location in circle.locations
					if location.file == old_name
						let location.file = filename
					endif
				endfor
			endfor
		endfor
		call wheel#helix#rename_file(old_name, filename)
	endif
endfun

fun! wheel#tree#delete_torus ()
	" Delete current torus
	let confirm = confirm('Delete current torus ?', "&Yes\n&No", 2)
	if confirm == 1
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
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
		call wheel#vortex#jump ()
		call wheel#pendulum#delete(0, cur_name)
	endif
endfun

fun! wheel#tree#delete_circle ()
	" Delete current circle
	let confirm = confirm('Delete current circle ?', "&Yes\n&No", 2)
	if confirm == 1
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
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
		call wheel#vortex#jump ()
		call wheel#pendulum#delete(1, cur_name)
	endif
endfun

fun! wheel#tree#delete_location ()
	" Delete current location
	let confirm = confirm('Delete current location ?', "&Yes\n&No", 2)
	if confirm == 1
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
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
		call wheel#vortex#jump ()
		call wheel#pendulum#delete(2, cur_name)
	endif
endfun
