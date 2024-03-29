" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Organize wheel elements, prompt functions
"
" Tree = toruses / circles / locations
"
" Adding
" Renaming
" Removing

" Notes
"
" To insert a non-breaking space : C-v x a 0

" ---- script constants

if exists('s:level_separ')
	unlockvar s:level_separ
endif
let s:level_separ = wheel#crystal#fetch('separator/level')
lockvar s:level_separ

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = wheel#crystal#fetch('separator/field')
lockvar s:field_separ

" ---- helpers

fun! wheel#tree#is_in_circle (location, circle)
	" Whether file & cursor position is in circle
	let local = a:location
	let present = 0
	for elem in a:circle.locations
		if elem.file ==# local.file && elem.line == local.line
			let present = 1
		endif
	endfor
	return present
endfun

fun! wheel#tree#format_name (name)
	" Format element name to avoid annoying characters
	let name = a:name
	if name ==# '%'
		let name = getreg('%')
	endif
	if name ==# '#'
		let name = getreg('#')
	endif
	let name = trim(name, ' ')
	let name = substitute(name, ' ', '_', 'g')
	return name
endfun

fun! wheel#tree#name ()
	" Prompt for a location name and return it
	let prompt = 'Location name ? '
	let complete = 'customlist,wheel#complete#current_file'
	let name = input(prompt, '', complete)
	let name = wheel#tree#format_name (name)
	return name
endfun

fun! wheel#tree#add_name (location)
	" Fill the name key of location and return it
	let location = a:location
	if ! has_key(location, 'name') || empty(location.name)
		let location.name = wheel#tree#name ()
	endif
	return location.name
endfun

" ---- insert existent element

fun! wheel#tree#insert_torus (torus)
	" Insert torus into wheel
	" No confirm prompt, no jump : internal use only
	let torus = a:torus
	let wheel = g:wheel
	let index = wheel.current
	let glossary = wheel.glossary
	let name = torus.name
	if wheel#chain#is_inside(name, glossary)
		let complete = 'customlist,wheel#complete#torus'
		let name = input('Clone torus with name ? ', '', complete)
		let name = wheel#tree#format_name (name)
	endif
	if empty(name)
		call wheel#status#message('Torus name cannot be empty')
		return v:false
	endif
	if wheel#chain#is_inside(name, glossary)
		echomsg 'Torus named' name 'already exists in wheel'
		return v:false
	endif
	let torus.name = name
	eval wheel.toruses->wheel#chain#insert_next(index, torus)
	let wheel.current += 1
	eval glossary->wheel#chain#insert_next(index, name)
	let wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfun

fun! wheel#tree#insert_circle (circle)
	" Insert circle into current torus
	" No confirm prompt, no jump : internal use only
	let circle = a:circle
	let torus = g:wheel.toruses[g:wheel.current]
	let index = torus.current
	let glossary = torus.glossary
	let name = circle.name
	if wheel#chain#is_inside(name, glossary)
		let complete = 'customlist,wheel#complete#circle'
		let name = input('Insert circle with name ? ', '', complete)
		let name = wheel#tree#format_name (name)
	endif
	if empty(name)
		call wheel#status#message('Circle name cannot be empty')
		return v:false
	endif
	if wheel#chain#is_inside(name, glossary)
		echomsg 'Circle named' name 'already exists in torus' torus.name
		return v:false
	endif
	let circle.name = name
	eval torus.circles->wheel#chain#insert_next(index, circle)
	let torus.current += 1
	eval glossary->wheel#chain#insert_next(index, name)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfun

fun! wheel#tree#insert_location (location)
	" Insert location into current circle
	" No confirm prompt, no jump : internal use only
	let location = a:location
	let torus = g:wheel.toruses[g:wheel.current]
	let circle = torus.circles[torus.current]
	let index = circle.current
	let glossary = circle.glossary
	let name = location.name
	if wheel#chain#is_inside(name, glossary)
		let complete = 'customlist,wheel#complete#location'
		let name = input('Insert location with name ? ', '', complete)
		let name = wheel#tree#format_name (name)
	endif
	if empty(name)
		call wheel#status#message('Location name cannot be empty')
		return v:false
	endif
	if wheel#chain#is_inside(name, glossary)
		echomsg 'Location named' name 'already exists in circle' circle.name
		return v:false
	endif
	let location.name = name
	eval circle.locations->wheel#chain#insert_next(index, location)
	let circle.current += 1
	eval glossary->wheel#chain#insert_next(index, name)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfun

" ---- add new element

fun! wheel#tree#add_torus (...)
	" Add torus
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name = input('New torus name ? ')
	endif
	" ---- torus name
	let torus_name = wheel#tree#format_name (torus_name)
	if empty(torus_name)
		call wheel#status#message('Torus name cannot be empty')
		return v:false
	endif
	" ---- check name is not already present
	if wheel#chain#is_inside(torus_name, g:wheel.glossary)
		call wheel#status#message('Torus', torus_name, 'already exists in wheel')
		return v:false
	endif
	" ---- add torus
	call wheel#status#message('Adding torus', torus_name)
	let index = g:wheel.current
	let toruses = g:wheel.toruses
	let glossary = g:wheel.glossary
	let template = wheel#void#template ({'name': torus_name, 'circles': []})
	eval toruses->wheel#chain#insert_next(index, template)
	eval glossary->wheel#chain#insert_next(index, torus_name)
	let g:wheel.current += 1
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfun

fun! wheel#tree#add_circle (...)
	" Add circle
	if a:0 > 0
		let circle_name = a:1
	else
		let complete = 'customlist,wheel#complete#dir_or_subdir'
		let circle_name = input('New circle name ? ', '', complete)
	endif
	let circle_name = wheel#tree#format_name (circle_name)
	" ---- add first torus if needed
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	" ---- circle name
	if empty(circle_name)
		call wheel#status#message('Circle name cannot be empty')
		return v:false
	endif
	" ---- check name is not already present
	let torus = g:wheel.toruses[g:wheel.current]
	if wheel#chain#is_inside(circle_name, torus.glossary)
		let infolist = ['Circle', circle_name, 'already exists in torus', torus.name]
		call wheel#status#message(infolist)
		return v:false
	endif
	" ---- add circle
	call wheel#status#message('Adding circle', circle_name)
	let index = torus.current
	let circles = torus.circles
	let glossary = torus.glossary
	let template = wheel#void#template ({'name': circle_name, 'locations': []})
	eval circles->wheel#chain#insert_next(index, template)
	eval glossary->wheel#chain#insert_next(index, circle_name)
	let torus.current += 1
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	return v:true
endfun

fun! wheel#tree#add_location (location, optional = 'default')
	" Add location
	let location = a:location
	let optional = a:optional
	" ---- add first torus if needed
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	let torus = g:wheel.toruses[g:wheel.current]
	" ---- add first circle if needed
	if empty(torus.circles)
		call wheel#tree#add_circle()
	endif
	let circle = torus.circles[torus.current]
	" ---- location name
	let name = wheel#tree#add_name (location)
	if empty(name)
		call wheel#status#message('Location name cannot be empty')
		return v:false
	endif
	" ---- check name is not already present
	if wheel#chain#is_inside(name, circle.glossary)
		let infolist = ['Location named', name, 'already exists in circle']
		call wheel#status#message(infolist)
		return v:false
	endif
	" ---- add the location to the circle
	let infolist = [ 'Adding location', location.name, ':', location.file ]
	let infolist += [ ':', location.line, ':', location.col ]
	let infolist += [ 'in torus', torus.name, 'circle', circle.name ]
	call wheel#status#message(infolist)
	let index = circle.current
	let locationlist = circle.locations
	let glossary = circle.glossary
	eval locationlist->wheel#chain#insert_next(index, location)
	eval glossary->wheel#chain#insert_next(index, name)
	let circle.current += 1
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	if optional !=# 'dont-record'
		call wheel#pendulum#record ()
	endif
	return v:true
endfun

fun! wheel#tree#add_here ()
	" Add here to circle
	silent doautocmd User WheelBeforeOrganize
	let here = wheel#vortex#here()
	call wheel#tree#add_location(here)
endfun

fun! wheel#tree#add_file (...)
	" Add file to circle
	if a:0 > 0
		let file = a:1
	else
		let prompt = 'File to add ? '
		let complete = 'customlist,wheel#complete#file'
		let file = input(prompt, '', complete)
	endif
	if empty(file)
		return v:false
	endif
	silent doautocmd User WheelBeforeOrganize
	execute 'hide edit' file
	call wheel#tree#add_here()
	return v:true
endfun

fun! wheel#tree#add_buffer (...)
	" Add buffer to circle
	if a:0 > 0
		let buffer = a:1
	else
		let prompt = 'Buffer to add ? '
		let complete = 'customlist,wheel#complete#buffer'
		let choice = input(prompt, '', complete)
		if empty(choice)
			return v:false
		endif
		let fields = split(choice, s:field_separ)
		let buffer = fields[3]
	endif
	if empty(buffer)
		return v:false
	endif
	silent doautocmd User WheelBeforeOrganize
	execute 'hide buffer' buffer
	call wheel#tree#add_here()
	return v:true
endfun

fun! wheel#tree#add_glob (...)
	" Add all files matching a glob pattern
	if a:0 > 0
		let glob = a:1
	else
		let prompt = 'Add files matching glob : '
		let complete = 'customlist,wheel#complete#file'
		let glob = input(prompt, '', complete)
	endif
	if empty(glob)
		return []
	endif
	silent doautocmd User WheelBeforeOrganize
	" add first torus if needed
	if empty(g:wheel.toruses)
		call wheel#tree#add_torus()
	endif
	" add files to a new circle ?
	let answer = confirm('Create new circle ?', "&Yes\n&No", 2)
	if answer == 1
		call wheel#tree#add_circle()
	endif
	" add first circle if needed
	let torus = g:wheel.toruses[g:wheel.current]
	if empty(torus.circles)
		call wheel#tree#add_circle()
	endif
	" add files
	let filelist = glob(glob, v:false, v:true)
	for filename in filelist
		let location = {}
		let location.name = filename
		let location.file = fnamemodify(filename, ':p')
		let location.line = 1
		let location.col = 1
		call wheel#tree#insert_location(location)
	endfor
	" jump to first location of circle, if not empty
	let circle = wheel#referen#current('circle')
	if ! empty(circle.locations)
		let circle.current = 0
		call wheel#vortex#jump ()
	endif
	return filelist
endfun

" ---- rename

fun! wheel#tree#rename (level, ...)
	" Rename current element at level -> new
	let level = a:level
	if wheel#referen#is_empty (level)
		echomsg 'wheel rename :' level 'is empty'
		return v:false
	endif
	if a:0 > 0
		let new = a:1
	else
		let prompt = 'Rename ' .. level .. ' as ? '
		if level ==# 'torus'
			let complete = 'customlist,wheel#complete#empty'
		elseif level ==# 'circle'
			let complete = 'customlist,wheel#complete#current_directory'
		elseif level ==# 'location'
			let complete = 'customlist,wheel#complete#current_file'
		else
			echomsg 'wheel rename : bad level name'
			return v:false
		endif
		let new = input(prompt, '', complete)
	endif
	if empty(new)
		return v:false
	endif
	let upper = wheel#referen#upper (level)
	let current = wheel#referen#current (level)
	" ---- name
	let new = wheel#tree#format_name (new)
	if empty(new)
		call wheel#status#message(level, 'name cannot be empty')
		return v:false
	endif
	" ---- check new is not present in upper list
	if wheel#chain#is_inside(new, upper.glossary)
		let upper_level_name = wheel#referen#upper_level_name(a:level)
		let infolist = [level, new, 'already exists in', upper_level_name]
		call wheel#status#message(infolist)
		return v:false
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeOrganize
	" ---- rename
	let old = current.name
	let current.name = new
	call wheel#status#message('Renaming', level, old, '->', new)
	let glossary = upper.glossary
	let upper.glossary = glossary->wheel#chain#replace(old, new)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	call wheel#pendulum#rename(level, old, new)
	return v:true
endfun

" -- rename file

fun! wheel#tree#adapt_to_filename (old_filename, new_filename)
	" Adapt wheel variables to new_filename
	let old_filename = a:old_filename
	let new_filename = a:new_filename
	" ---- rename file in all involved locations of the wheel
	for torus in g:wheel.toruses
		for circle in torus.circles
			for location in circle.locations
				if location.file ==# old_filename
					let location.file = new_filename
				endif
			endfor
		endfor
	endfor
	" ---- rename file in wheel index
	let g:wheel.timestamp = wheel#pendulum#timestamp()
	call wheel#helix#rename_file(old_filename, new_filename)
endfun

fun! wheel#tree#rename_file (...)
	" Rename current file in filesystem & in the wheel
	if wheel#referen#is_empty ('location')
		echomsg 'wheel rename file : location is empty'
		return v:false
	endif
	if a:0 > 0
		let new_filename = a:1
	else
		let dir = expand('%:h')
		let dir = wheel#disc#relative_path (dir)
		let prompt = 'Rename file as ? '
		let complete = 'customlist,wheel#complete#file'
		let new_filename = input(prompt, dir, complete)
	endif
	if empty(new_filename)
		return v:false
	endif
	" ---- old name
	let location = wheel#referen#location ()
	let old_filename = location.file
	" ---- new name
	let new_filename = wheel#disc#format_name (new_filename)
	" ---- rename file
	let returnstring = wheel#disc#rename (old_filename, new_filename)
	if returnstring != 'success'
		return v:false
	endif
	" ---- link buffer to new file name
	execute 'silent file' new_filename
	silent write!
	" ---- user update autocmd
	silent doautocmd User WheelBeforeOrganize
	" ---- adapt wheel variables to new_filename
	call wheel#tree#adapt_to_filename (old_filename, new_filename)
	" ---- rename location
	call wheel#tree#rename('location')
	return v:true
endfun

" ---- remove

fun! wheel#tree#remove (level, name)
	" Remove element given by name at level
	" No confirm prompt, no jump : internal use only
	let level = a:level
	let name = a:name
	let coordin = wheel#referen#coordinates ()
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let glossary = upper.glossary
	" ---- find element index
	let index = glossary->index(name)
	if index < 0
		echomsg upper_name 'does not contain' name
		return v:false
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeOrganize
	" ---- remove from elements list
	eval elements->remove(index)
	" ---- adjust current index if necessary
	if empty(elements)
		let upper.current = -1
	elseif index <= upper.current
		" if removed element index is before current one,
		" the need to decrease current
		let length = len(elements)
		let upper.current = wheel#taijitu#circular_minus(index, length)
	endif
	" ---- remove from glossary
	eval glossary->wheel#chain#remove_element(name)
	" ---- for index auto update at demand
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	" ---- adjust history
	call wheel#pendulum#delete (level, coordin)
	return v:true
endfun

" -- delete

fun! wheel#tree#delete (level, ask = 'confirm')
	" Delete current element at level
	" Optional argument :
	"   - confirm : ask confirmation
	"   - force : don't ask confirmation
	let level = a:level
	let ask = a:ask
	let current = wheel#referen#current (level)
	let name = current.name
	if ask != 'force'
		let prompt = 'Delete current ' .. level .. ' ' .. name .. ' ?'
		let confirm = confirm(prompt, "&Yes\n&No", 2)
		if confirm != 1
			return v:false
		endif
	endif
	" ---- for history
	let coordin = wheel#referen#coordinates ()
	" ---- check
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	if empty(elements)
		let upper_name = wheel#referen#upper_level_name (level)
		echomsg upper_name 'is already empty'
		return v:false
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeOrganize
	" ---- remove
	let length = len(elements)
	let upper_level_name = wheel#referen#upper_level_name (level)
	let key = wheel#referen#list_key (upper_level_name)
	let index = upper.current
	eval elements->remove(index)
	let length -= 1
	if empty(elements)
		let upper.current = -1
	else
		let upper.current = wheel#taijitu#circular_minus(index, length)
	endif
	eval upper.glossary->wheel#chain#remove_element(name)
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	call wheel#vortex#jump ()
	" ---- adjust history
	call wheel#pendulum#delete (level, coordin)
	return v:true
endfun

" ---- copy / move

fun! wheel#tree#copy_move (level, mode, ...)
	" Copy or move element of level
	" level can be :
	"   - circle : move circle to another torus
	"   - location : move location to another circle
	let level = a:level
	let mode = a:mode
	if wheel#referen#is_empty (level)
		echomsg 'wheel copy/move :' level 'is empty'
		return v:false
	endif
	if a:0 > 0
		let destination = a:1
	else
		let upper_name = wheel#referen#upper_level_name (level)
		let prompt = mode .. ' ' .. level .. ' to ' .. upper_name .. ' ? '
		if level ==# 'torus'
			let destination = 'wheel'
		elseif level ==# 'circle'
			let complete = 'customlist,wheel#complete#torus'
			let destination = input(prompt, '', complete)
		elseif level ==# 'location'
			let complete = 'customlist,wheel#complete#grid'
			let destination = input(prompt, '', complete)
		else
			echomsg 'wheel' mode ': bad level name'
			return v:false
		endif
	endif
	if empty(destination)
		return v:false
	endif
	let element = deepcopy(wheel#referen#{level}())
	let coordin = split(destination, s:level_separ)
	" ---- pre checks
	if mode ==# 'move'
		if level ==# 'torus'
			echomsg 'wheel : move torus in wheel = noop'
			return v:false
		elseif level ==# 'circle' && destination ==# wheel#referen#torus().name
			echomsg 'wheel : move circle to current torus = noop'
			return v:false
		elseif level ==# 'location' && coordin ==# wheel#referen#coordinates()[:1]
			echomsg 'wheel : move location to current circle = noop'
			return v:false
		endif
		call wheel#tree#remove (level, element.name)
	elseif mode !=# 'copy'
		echomsg 'wheel copy/move : mode must be copy or move'
	endif
	" ---- user update autocmd
	silent doautocmd User WheelBeforeOrganize
	" ---- copy / move
	if level ==# 'torus'
		" mode must be copy at this stage
		call wheel#tree#insert_torus (element)
	elseif level ==# 'circle'
		call wheel#vortex#voice ('torus', destination)
		call wheel#tree#insert_circle (element)
	elseif level ==# 'location'
		call wheel#vortex#interval (coordin)
		call wheel#tree#insert_location (element)
	endif
	call wheel#vortex#jump ()
	return v:true
endfun

fun! wheel#tree#copy (level)
	" Copy element of level
	call wheel#tree#copy_move(a:level, 'copy')
endfun

fun! wheel#tree#move (level)
	" Move element of level
	call wheel#tree#copy_move(a:level, 'move')
endfun
