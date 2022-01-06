" vim: set ft=vim fdm=indent iskeyword&:

" Tree = toruses / circles / locations
" Adding
" Renaming
" Removing

" Notes
"
" To insert a non-breaking space : C-v x a 0

" Script constants

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

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

fun! wheel#tree#format_name (name)
	" Format element name to avoid annoying characters
	let name = a:name
	let name = substitute(name, ' ', ' ', 'g')
	return name
endfun

fun! wheel#tree#format_filename (filename)
	" Format filename to avoid annoying characters
	let filename = a:filename
	let filename = substitute(filename, ' ', '_', 'g')
	" escape annoying chars
	let filename = fnameescape(filename)
	" convert to absolute path if needed
	if filename[0] != '/'
		let filename = fnamemodify(filename, ':p')
	endif
	return filename
endfun

fun! wheel#tree#name ()
	" Prompt for a location name and return it
	let prompt = 'Location name ? '
	let complete = 'customlist,wheel#completelist#current_file'
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

" Insert existent element

fun! wheel#tree#insert_torus (torus)
	" Insert torus into wheel
	let torus = a:torus
	let wheel = g:wheel
	let index = wheel.current
	let glossary = wheel.glossary
	let name = torus.name
	if index(glossary, name) >= 0
		let complete = 'customlist,wheel#completelist#torus'
		let name = input('Insert torus with name ? ', '', complete)
	endif
	if index(glossary, name) >= 0
		echomsg 'Torus named' name 'already exists in wheel.'
		return v:false
	endif
	let torus.name = name
	call wheel#chain#insert_next (index, torus, wheel.toruses)
	let wheel.current += 1
	call wheel#chain#insert_next (index, name, glossary)
	let wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfun

fun! wheel#tree#insert_circle (circle)
	" Insert circle into current torus
	let circle = a:circle
	let torus = g:wheel.toruses[g:wheel.current]
	let index = torus.current
	let glossary = torus.glossary
	let name = circle.name
	if index(glossary, name) >= 0
		let complete = 'customlist,wheel#completelist#circle'
		let name = input('Insert circle with name ? ', '', complete)
	endif
	if index(glossary, name) >= 0
		echomsg 'Circle named' name 'already exists in torus ' . torus.name
		return v:false
	endif
	let circle.name = name
	call wheel#chain#insert_next (index, circle, torus.circles)
	let torus.current += 1
	call wheel#chain#insert_next (index, name, glossary)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfun

fun! wheel#tree#insert_location (location)
	" Insert location into current circle
	let location = a:location
	let torus = g:wheel.toruses[g:wheel.current]
	let circle = torus.circles[torus.current]
	let index = circle.current
	let glossary = circle.glossary
	let name = location.name
	if index(glossary, name) >= 0
		let complete = 'customlist,wheel#completelist#location'
		let name = input('Insert location with name ? ', '', complete)
	endif
	if index(glossary, name) >= 0
		echomsg 'Location named' name 'already exists in circle ' . circle.name
		return v:false
	endif
	let location.name = name
	call wheel#chain#insert_next (index, location, circle.locations)
	let circle.current += 1
	call wheel#chain#insert_next (index, name, glossary)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfun

" Add new element

fun! wheel#tree#add_torus (...)
	" Add torus
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name = input('New torus name ? ')
	endif
	" replace spaces by non-breaking spaces
	let torus_name = wheel#tree#format_name (torus_name)
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
		let complete = 'customlist,wheel#completelist#current_directory'
		let circle_name = input('New circle name ? ', '', complete)
	endif
	" add first torus if needed
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	" replace spaces by non-breaking spaces
	let circle_name = wheel#tree#format_name (circle_name)
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
		let prompt = 'File to add ? '
		let complete =  'customlist,wheel#completelist#file'
		let file = input(prompt, '', complete)
	endif
	exe 'edit' fnameescape(file)
	call wheel#tree#add_here()
endfun

fun! wheel#tree#add_buffer (...)
	" Add buffer to circle
	call wheel#vortex#update ()
	if a:0 > 0
		let buffer = a:1
	else
		let prompt = 'Buffer to add ? '
		let complete =  'customlist,wheel#completelist#buffer'
		let buffer = input(prompt, '', complete)
	endif
	exe 'buffer' buffer
	call wheel#tree#add_here()
endfun

fun! wheel#tree#add_glob (...)
	" Add all files matching a glob pattern
	if a:0 > 0
		let glob = a:1
	else
		let prompt = 'Add files matching glob : '
		let complete =  'customlist,wheel#completelist#file'
		let glob = input(prompt, '', complete)
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
			let complete = 'customlist,wheel#completelist#empty'
		elseif level ==# 'circle'
			let complete = 'customlist,wheel#completelist#current_directory'
		elseif level ==# 'location'
			let complete = 'customlist,wheel#completelist#current_file'
		else
			echomsg 'wheel rename : bad level name.'
			return v:false
		endif
		let new = input(prompt, '', complete)
	endif
	let upper = wheel#referen#upper (level)
	let current = wheel#referen#current (level)
	" replace spaces by non-breaking spaces
	let new = wheel#tree#format_name (new)
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

" Rename file

fun! wheel#tree#adapt_filename (old_filename, new_filename)
	" Adapt wheel variables to new_filename
	let old_filename = a:old_filename
	let new_filename = a:new_filename
	" rename file in all involved locations of the wheel
	for torus in g:wheel.toruses
		for circle in torus.circles
			for location in circle.locations
				if location.file ==# old_filename
					let location.file = new_filename
				endif
			endfor
		endfor
	endfor
	" rename file in wheel index
	let g:wheel.timestamp = wheel#pendulum#timestamp()
	call wheel#helix#rename_file(old_filename, new_filename)
endfun

fun! wheel#tree#rename_file (...)
	" Rename current file in filesystem & in the wheel
	if a:0 > 0
		let new_filename = a:1
	else
		let dir = expand('%:h') . '/'
		let cwd = getcwd() . '/'
		let dir = substitute(dir, cwd, '', '')
		let prompt = 'Rename file as ? '
		let complete =  'customlist,wheel#completelist#file'
		let new_filename = input(prompt, dir, complete)
	endif
	" new name
	let new_filename = wheel#tree#format_filename (new_filename)
	" old name
	let location = wheel#referen#location ()
	let old_filename = location.file
	" link buffer to new file name
	exe 'file' new_filename
	" write it
	write
	" remove old file
	let prompt = 'Remove old file ' . old_filename . ' ?'
	let confirm = confirm(prompt, "&Yes\n&No", 2)
	if confirm == 1
		let command = 'rm'
		let remove = command . ' ' . shellescape(old_filename)
		call system(remove)
		if v:shell_error
			echomsg 'wheel rename file : error in executing system command.'
			return v:false
		endif
	endif
	" adapt wheel variables to new_filename
	call wheel#tree#adapt_filename (old_filename, new_filename)
	" rename location
	call wheel#tree#rename('location')
endfun

" Remove

fun! wheel#tree#remove (level, element)
	" Remove element at level
	" No confirm prompt, no jump : internal use only
	let level = a:level
	let elem = a:element
	let old_names = wheel#referen#names ()
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let glossary = upper.glossary
	" find element index
	let index = index(glossary, elem.name)
	if index < 0
		echomsg upper_name . 'does not contain ' elem.name
	endif
	" remove from elements list
	call wheel#chain#remove_index(index, elements)
	" adjust current index if necessary
	if empty(elements)
		let upper.current = -1
	elseif index == upper.current
		let length = len(elements)
		let upper.current = wheel#gear#circular_minus(index, length)
	endif
	" remove from glossary
	let name = elem.name
	call wheel#chain#remove_element(name, glossary)
	" for index auto update at demand
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	" adjust history
	call wheel#pendulum#delete(level, old_names)
	return v:true
endfun

" Delete

fun! wheel#tree#delete (level, ...)
	" Delete current element at level
	let level = a:level
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	if mode != 'force'
		let prompt = 'Delete current ' . level . ' ?'
		let confirm = confirm(prompt, "&Yes\n&No", 2)
		if confirm != 1
			return v:false
		endif
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
	return v:true
endfun

" Move

fun! wheel#tree#copy_move (level, mode, ...)
	" Copy or move element of level
	" level can be :
	"   - circle : move circle to another torus
	"   - location : move location to another circle
	let level = a:level
	let mode = a:mode
	if a:0 > 0
		let destination = a:1
	else
		let upper_name = wheel#referen#upper_level_name (level)
		let prompt = mode . ' ' . level . ' to ' . upper_name . ' ? '
		if level ==# 'torus'
			let destination = 'wheel'
		elseif level ==# 'circle'
			let complete = 'customlist,wheel#completelist#torus'
			let destination = input(prompt, '', complete)
		elseif level ==# 'location'
			let complete = 'customlist,wheel#completelist#grid'
			let destination = input(prompt, '', complete)
		else
			echomsg 'wheel ' . mode . ' : bad level name.'
			return v:false
		endif
	endif
	let element = deepcopy(wheel#referen#{level}())
	let coordin = split(destination, s:level_separ)
	" pre checks
	if mode == 'move'
		if level ==# 'torus'
			echomsg 'wheel : move torus in wheel = noop'
			return v:false
		elseif level ==# 'circle' && destination ==# wheel#referen#torus().name
			echomsg 'wheel : move circle to current torus = noop'
			return v:false
		elseif level ==# 'location' && coordin ==# wheel#referen#names()[:1]
			echomsg 'wheel : move location to current circle = noop'
			return v:false
		endif
		call wheel#tree#remove (level, element)
	elseif mode !=# 'copy'
		echomsg 'wheel copy/move : mode must be copy or move'
	endif
	" copy / move
	if level == 'torus'
		" mode must be copy at this stage
		call wheel#tree#insert_torus (element)
	elseif level == 'circle'
		call wheel#vortex#tune ('torus', destination)
		call wheel#tree#insert_circle (element)
	elseif level == 'location'
		call wheel#vortex#tune ('torus', coordin[0])
		call wheel#vortex#tune ('circle', coordin[1])
		call wheel#tree#insert_location (element)
	endif
	call wheel#vortex#jump ()
endfun

fun! wheel#tree#copy (level)
	" Copy element of level
	call wheel#tree#copy_move(a:level, 'copy')
endfun

fun! wheel#tree#move (level)
	" Move element of level
	call wheel#tree#copy_move(a:level, 'move')
endfun
