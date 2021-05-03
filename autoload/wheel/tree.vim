" vim: ft=vim fdm=indent:

" Tree = toruses / circles / locations
" Adding
" Renaming
" Removing

" Notes
"
" To insert a non-breaking space : C-v x a 0

" Helpers

fun! wheel#tree#is_in_circle (location, circle)
	" Whether location is in circle
	let local = a:location
	let present = 0
	for elem in a:circle.locations
		if elem.file ==# local.file && elem.line == local.line
			let present = 1
		endif
	endfor
	return present
endfu

fun! wheel#tree#name ()
	" Prompt for a location name and return it
	let prompt = 'Location name ? '
	let complete = 'customlist,wheel#complete#filename'
	return input(prompt, '', complete)
endfu

fun! wheel#tree#add_name (location)
	" Fill the name key of location and return it
	let location = a:location
	if ! has_key(location, 'name') || empty(location.name)
		let location.name = wheel#tree#name ()
	endif
	return location.name
endfu

" Add

fun! wheel#tree#add_torus (...)
	" Add torus
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name = input('New torus name ? ')
	endif
	" replace spaces by non-breaking spaces
	let torus_name = substitute(torus_name, ' ', ' ', 'g')
	if empty(torus_name)
		redraw!
		echomsg 'Torus name cannot be empty.'
		return v:false
	endif
	" check if not already present
	if index(g:wheel.glossary, torus_name) >= 0
		redraw!
		echomsg 'Torus' torus_name 'already exists in wheel.'
		return v:false
	endif
	" add torus
	redraw!
	echomsg "Adding torus" torus_name
	let index = g:wheel.current
	let toruses = g:wheel.toruses
	let glossary = g:wheel.glossary
	let template = wheel#void#template ({'name': torus_name, 'circles': []})
	call wheel#chain#insert_next (index, template, toruses)
	call wheel#chain#insert_next (index, torus_name, glossary)
	let g:wheel.current += 1
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfu

fun! wheel#tree#add_circle (...)
	" Add circle
	if a:0 > 0
		let circle_name = a:1
	else
		let complete = 'customlist,wheel#complete#directory'
		let circle_name = input('New circle name ? ', '', complete)
	endif
	" add first torus if needed
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	" replace spaces by non-breaking spaces
	let circle_name = substitute(circle_name, ' ', ' ', 'g')
	if empty(circle_name)
		redraw!
		echomsg 'Circle name cannot be empty.'
		return v:false
	endif
	" check if not already present
	let torus = g:wheel.toruses[g:wheel.current]
	if index(torus.glossary, circle_name) >= 0
		redraw!
		echomsg 'Circle' circle_name 'already exists in torus' torus.name
		return v:false
	endif
	" add circle
	redraw!
	echomsg "Adding circle" circle_name
	let index = torus.current
	let circles = torus.circles
	let glossary = torus.glossary
	let template = wheel#void#template ({'name': circle_name, 'locations': []})
	call wheel#chain#insert_next (index, template, circles)
	call wheel#chain#insert_next (index, circle_name, glossary)
	let torus.current += 1
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfu

fun! wheel#tree#add_location (location, ...)
	" Add location
	let location = a:location
	if a:0 > 0
		let optional = a:1
	else
		let optional = 'default'
	endif
	" add first torus if needed
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	let torus = g:wheel.toruses[g:wheel.current]
	" add first circle if needed
	if empty(torus.circles)
		call wheel#tree#add_circle()
	endif
	let circle = torus.circles[torus.current]
	" check location is not in circle
	if wheel#tree#is_in_circle(location, circle)
		redraw!
		echomsg 'Location' location.file ':' location.line
					\ 'already exists in torus' torus.name 'circle' circle.name
		return v:false
	endif
	" add a name to the location
	let name = wheel#tree#add_name (location)
	if empty(name)
		redraw!
		echomsg 'Location name cannot be empty.'
		return v:false
	endif
	" check location name is not in circle
	if index(circle.glossary, name) >= 0
		redraw!
		echomsg 'Location named' name 'already exists in circle.'
		return v:false
	endif
	" add the location to the circle
	redraw!
	let info = 'Adding location ' . location.name . ' : '
	let info .= location.file . ':' . location.line . ':' . location.col
	let info .= ' in torus ' . torus.name . ' circle ' . circle.name
	echomsg info
	let index = circle.current
	let locations = circle.locations
	let glossary = circle.glossary
	call wheel#chain#insert_next (index, location, locations)
	let circle.current += 1
	call wheel#chain#insert_next (index, name, glossary)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	if optional !=# 'norecord'
		call wheel#pendulum#record ()
	endif
	return v:true
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
	exe 'edit' file
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
	exe 'buffer' buffer
	call wheel#tree#add_here()
endfun

fun! wheel#tree#add_glob (...)
	" Add all files matching a glob pattern
	if a:0 > 0
		let glob = a:1
	else
		let glob = input('Add files matching glob : ', '', 'file_in_path')
	endif
	let answer = confirm('Create new circle ?', "&Yes\n&No", 2)
	if answer == 1
		call wheel#tree#add_circle()
	endif
	let filelist = glob(glob, v:false, v:true)
	for filename in filelist
		let location = {}
		let location.name = filename
		let location.file = fnamemodify(filename, ':p')
		let location.line = 1
		let location.col = 1
		call wheel#tree#add_location(location, 'norecord')
	endfor
	" jump to first location of circle, if not empty
	let circle = wheel#referen#current('circle')
	if ! empty(circle.locations)
		let circle.current = 0
		call wheel#vortex#jump ()
	endif
	return filelist
endfun

" Rename

fun! wheel#tree#rename (level, ...)
	" Rename current element at level -> new
	let level = a:level
	if a:0 > 0
		let new = a:1
	else
		let prompt = 'Rename ' . level . ' as ? '
		if level ==# 'torus'
			let complete = 'customlist,wheel#complete#empty'
		elseif level ==# 'circle'
			let complete = 'customlist,wheel#complete#directory'
		elseif level ==# 'location'
			let complete = 'customlist,wheel#complete#filename'
		else
			echomsg 'wheel rename : bad level name.'
			return v:false
		endif
		let new = input(prompt, '', complete)
	endif
	let upper = wheel#referen#upper (level)
	let current = wheel#referen#current (level)
	" replace spaces by non-breaking spaces
	let new = substitute(new, ' ', ' ', 'g')
	if empty(new)
		redraw!
		echomsg level 'name cannot be empty.'
		return v:false
	endif
	" check new is not present in upper list
	if index(upper.glossary, new) >= 0
		redraw!
		let upper_level_name = wheel#referen#upper_level_name(a:level)
		echomsg level new 'already exists in' upper_level_name
		return v:false
	endif
	" rename
	let old = current.name
	let current.name = new
	redraw!
	echomsg 'Renaming' level old '->' new
	let glossary = upper.glossary
	let upper.glossary = wheel#chain#replace(old, new, glossary)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	call wheel#pendulum#rename(level, old, new)
	return v:true
endfun

fun! wheel#tree#rename_file (...)
	" Rename current file in filesystem & in the wheel
	if a:0 > 0
		let filename = a:1
	else
		let dir = expand('%:h') . '/'
		let cwd = getcwd() . '/'
		let dir = substitute(dir, cwd, '', '')
		let filename = input('Rename file as ? ', dir)
	endif
	" replace spaces by underscores
	" non breaking spaces would be confusing in the user’s filesystem
	let filename = substitute(filename, ' ', '_', 'g')
	" convert to absolute path if needed
	if filename[0] != '/'
		let filename = fnamemodify(filename, ':p')
	endif
	" old name
	let location = wheel#referen#location ()
	let old_name = location.file
	" link buffer to new file name
	exe 'file' filename
	" write it
	write
	" remove old file
	let prompt = 'Remove old file ' . old_name . ' ?'
	let confirm = confirm(prompt, "&Yes\n&No", 2)
	if confirm == 1
		let command = 'rm'
		let remove = command . ' ' . shellescape(old_name)
		call system(remove)
		if v:shell_error
			echomsg 'wheel rename file : error in executing system command.'
			return v:false
		endif
	endif
	" rename file in all involved locations of the wheel
	for torus in g:wheel.toruses
		for circle in torus.circles
			for location in circle.locations
				if location.file ==# old_name
					let location.file = filename
				endif
			endfor
		endfor
	endfor
	" rename file in wheel history records
	let g:wheel.timestamp = wheel#pendulum#timestamp()
	call wheel#helix#rename_file(old_name, filename)
	" rename location
	call wheel#tree#rename('location')
endfun

" Delete

fun! wheel#tree#delete (level)
	" Delete current element at level
	let level = a:level
	let prompt = 'Delete current ' . level . ' ?'
	let confirm = confirm(prompt, "&Yes\n&No", 2)
	if confirm != 1
		return
	endif
	" For history
	let old_names = wheel#referen#names ()
	" Remove
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	if empty(elements)
		let upper_name = wheel#referen#upper_level_name (level)
		echomsg upper_name . ' is already empty.'
		return v:false
	endif
	let length = len(elements)
	let upper_level_name = wheel#referen#upper_level_name (level)
	let key = wheel#referen#list_key (upper_level_name)
	let current = wheel#referen#current (level)
	let index = upper.current
	let upper[key] = wheel#chain#remove_index(index, elements)
	let length -= 1
	if empty(elements)
		let upper.current = -1
	else
		let upper.current = wheel#gear#circular_minus(index, length)
	endif
	let glossary = upper.glossary
	let name = current.name
	let upper.glossary = wheel#chain#remove_element(name, glossary)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	call wheel#vortex#jump ()
	" Adjust history
	call wheel#pendulum#delete(level, old_names)
endfun
