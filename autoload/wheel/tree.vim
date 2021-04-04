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

fun! wheel#tree#name (location)
	" Fill the name key of location and return it
	let location = a:location
	if ! has_key(location, 'name') || empty(location.name)
		let default = fnamemodify(location.file, ':t:r')
		let prompt = 'Location name ? '
		" Replace spaces par non-breaking spaces
		let default = substitute(default, ' ', ' ', 'g')
		let location.name = input(prompt, default)
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
	" Replace spaces by non-breaking spaces
	let torus_name = substitute(torus_name, ' ', ' ', 'g')
	if empty(torus_name)
		redraw!
		echomsg 'Torus name cannot be empty.'
		return v:false
	endif
	if index(g:wheel.glossary, torus_name) < 0
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
	else
		redraw!
		echomsg 'Torus' torus_name 'already exists in wheel.'
		return v:false
	endif
endfu

fun! wheel#tree#add_circle (...)
	" Add circle
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name = input('New circle name ? ')
	endif
	" Replace spaces by non-breaking spaces
	let circle_name = substitute(circle_name, ' ', ' ', 'g')
	if empty(circle_name)
		redraw!
		echomsg 'Circle name cannot be empty.'
		return v:false
	endif
	let cur_torus = g:wheel.toruses[g:wheel.current]
	if index(cur_torus.glossary, circle_name) < 0
		redraw!
		echomsg "Adding circle" circle_name
		let index = cur_torus.current
		let circles = cur_torus.circles
		let glossary = cur_torus.glossary
		let template = wheel#void#template ({'name': circle_name, 'locations': []})
		call wheel#chain#insert_next (index, template, circles)
		call wheel#chain#insert_next (index, circle_name, glossary)
		let cur_torus.current += 1
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
		return v:true
	else
		redraw!
		echomsg 'Circle' circle_name 'already exists in torus' cur_torus.name
		return v:false
	endif
endfu

fun! wheel#tree#add_location (location, ...)
	" Add location
	if a:0 > 0
		let optional = a:1
	else
		let optional = 'default'
	endif
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
		let location_name = wheel#tree#name (local)
		if empty(location_name)
			redraw!
			echomsg 'Location name cannot be empty.'
			return v:false
		endif
		if index(cur_circle.glossary, location_name) < 0
			redraw!
			let info = 'Adding location ' . local.name . ' : '
			let info .= local.file . ':' . local.line . ':' . local.col
			let info .= ' in torus ' . cur_torus.name . ' circle ' . cur_circle.name
			echomsg info
			let index = cur_circle.current
			let locations = cur_circle.locations
			let glossary = cur_circle.glossary
			call wheel#chain#insert_next (index, local, locations)
			let cur_circle.current += 1
			call wheel#chain#insert_next (index, location_name, glossary)
			let g:wheel.timestamp = wheel#pendulum#timestamp ()
			if optional !=# 'norecord'
				call wheel#pendulum#record ()
			endif
			return v:true
		else
			redraw!
			echomsg 'Location named' location_name 'already exists in circle.'
			return v:false
		endif
	else
		redraw!
		echomsg 'Location' local.file ':' local.line
					\ 'already exists in torus' cur_torus.name 'circle' cur_circle.name
		return v:false
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

fun! wheel#tree#add_glob (...)
	" Add all files matching a glob pattern
	if a:0 > 0
		let glob = a:1
	else
		let glob = input('Add files matching glob : ')
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
	return filelist
endfun

" Rename

fun! wheel#tree#rename (level, ...)
	" Rename current element at level -> new
	let level = a:level
	let prompt = 'Rename ' . level . ' as ? '
	if a:0 > 0
		let new = a:1
	else
		let new = input(prompt)
	endif
	let upper = wheel#referen#upper (level)
	let current = wheel#referen#current (level)
	" Replace spaces by non-breaking spaces
	let new = substitute(new, ' ', ' ', 'g')
	if empty(new)
		redraw!
		echomsg 'Location name cannot be empty.'
		return v:false
	endif
	if index(upper.glossary, new) < 0
		let old = current.name
		let current.name = new
		redraw!
		echomsg 'Renaming' level old '->' new
		let glossary = upper.glossary
		let upper.glossary = wheel#chain#replace(old, new, glossary)
		let g:wheel.timestamp = wheel#pendulum#timestamp ()
		call wheel#pendulum#rename(level, old, new)
		return v:true
	else
		redraw!
		let upper_level_name = wheel#referen#upper_level_name(a:level)
		echomsg level new 'already exists in' upper_level_name
		return v:false
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
	let rename = command . shellescape(old_name) . ' ' . shellescape(filename)
	"echomsg rename
	call system(rename)
	if ! v:shell_error
		exe 'file ' . filename
		let prompt = 'Write as new file ?'
		let confirm = confirm(prompt, "&Yes\n&No", 2)
		if confirm == 1
			write!
		endif
		for torus in g:wheel.toruses
			for circle in torus.circles
				for location in circle.locations
					if location.file ==# old_name
						let location.file = filename
					endif
				endfor
			endfor
		endfor
		let g:wheel.timestamp = wheel#pendulum#timestamp()
		call wheel#helix#rename_file(old_name, filename)
	endif
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
