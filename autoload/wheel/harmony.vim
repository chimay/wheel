" vim: set ft=vim fdm=indent iskeyword&:

" Harmony
"
" Writing functions for local BufWriteCmd autocommand
" in wheel elements dedicated buffers

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

if ! exists('s:fold_1')
	let s:fold_1 = wheel#crystal#fetch('fold/one')
	lockvar s:fold_1
endif

if ! exists('s:fold_2')
	let s:fold_2 = wheel#crystal#fetch('fold/two')
	lockvar s:fold_2
endif

" ---- wheel elements

fun! wheel#harmony#reorder (level, ask = 'confirm')
	" Reorder elements at level, after buffer content
	let level = a:level
	" ---- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" ---- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" ---- reorder
	let upper = wheel#referen#upper (level)
	let upper_level_name = wheel#referen#upper_level_name(level)
	let key = wheel#referen#list_key (upper_level_name)
	let old_list = deepcopy(wheel#referen#elements (upper))
	let old_names = deepcopy(old_list)
	let old_names = map(old_names, {_,val -> val.name})
	let new_names = wheel#teapot#all_lines ()
	let new_list = []
	for name in new_names
		let index = old_names->index(name)
		if index < 0
			echomsg 'wheel harmony reorder : ' name  'not found'
			continue
		endif
		let elem = old_list[index]
		eval new_list->add(elem)
	endfor
	if len(new_list) < len(old_list)
		echomsg 'Some elements seem to be missing : changes not written'
		return []
	elseif len(new_list) > len(old_list)
		echomsg 'Elements in excess : changes not written'
		return []
	endif
	let upper[key] = new_list
	let upper.glossary = new_names
	setlocal nomodified
	echomsg 'Changes written to wheel'
	return new_list
endfun

fun! wheel#harmony#rename (level, ask = 'confirm')
	" Rename elements at level, after buffer content
	let level = a:level
	" ---- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" ---- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" ---- rename
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let names = wheel#teapot#all_lines ()
	let len_names = len(names)
	let len_elements = len(elements)
	if len_names < len_elements
		echomsg 'Some names seem to be missing : changes not written'
		return []
	endif
	if len_names > len_elements
		echomsg 'Names in excess : changes not written'
		return []
	endif
	let upper.glossary = names
	for index in range(len_names)
		let old_name = elements[index].name
		let new_name = names[index]
		" nothing to do if old == new
		if old_name == new_name
			continue
		endif
		let elements[index].name = new_name
		call wheel#pendulum#rename(level, old_name, new_name)
	endfor
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	call wheel#rectangle#goto_previous ()
	call wheel#vortex#jump()
	call wheel#cylinder#recall()
	setlocal nomodified
	echomsg 'Changes written to wheel'
	return elements
endfun

fun! wheel#harmony#rename_file (ask = 'confirm')
	" Rename locations & files of current circle, after buffer content
	" ---- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" ---- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" ---- init
	let circle = wheel#referen#circle ()
	let glossary = circle.glossary
	let locations = circle.locations
	let lines = wheel#teapot#all_lines ()
	let len_lines = len(lines)
	let len_locations = len(locations)
	" ---- pre-checks
	if len_lines < len_locations
		echomsg 'Some names seem to be missing : changes not written'
		return []
	endif
	if len_lines > len_locations
		echomsg 'Names in excess : changes not written'
		return []
	endif
	" ---- rename location
	for index in range(len_lines)
		let fields = split(lines[index], s:field_separ)
		let old_name = glossary[index]
		let new_name = wheel#tree#format_name(fields[0])
		" -- check not empty
		if empty(old_name) || empty(new_name)
			echomsg 'wheel harmony rename : location name cannot be empty'
			continue
		endif
		" --- nothing to do if old == new
		if old_name == new_name
			continue
		endif
		" -- search for location
		let found = glossary->index(new_name)
		if found >= 0 && found != index
			echomsg 'Location' new_name 'already present in circle'
			continue
		endif
		" -- rename location
		let glossary[index] = new_name
		let locations[index].name = new_name
		call wheel#pendulum#rename('location', old_name, new_name)
	endfor
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	" ---- rename file
	for index in range(len_lines)
		let fields = split(lines[index], s:field_separ)
		let old_filename = locations[index].file
		let new_filename = wheel#tree#format_filename (fields[1])
		" -- old -> new
		let returnstring = wheel#disc#rename(old_filename, new_filename)
		if returnstring != 'success'
			continue
		endif
		echomsg 'wheel : renaming' old_filename '->' new_filename
		let locations[index].file = new_filename
		" -- wipe old filename buffer if existent
		if bufexists(old_filename)
			execute 'bwipe' old_filename
		endif
		" -- rename file in all involved locations of the wheel
		call wheel#tree#adapt_to_filename (old_filename, new_filename)
	endfor
	call wheel#rectangle#goto_previous ()
	call wheel#vortex#jump()
	call wheel#cylinder#recall()
	setlocal nomodified
	echomsg 'Changes written to wheel'
	return lines
endfun

fun! wheel#harmony#delete (level, ask = 'confirm')
	" Delete selected elements at level, after buffer content
	let level = a:level
	" ----  confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" ----  update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" ----  delete
	let upper = wheel#referen#upper (level)
	let upper_level_name = wheel#referen#upper_level_name(level)
	let glossary = upper.glossary
	let elements = wheel#referen#elements (upper)
	let selection = wheel#pencil#selection ()
	let components = selection.components
	if empty(components)
		echomsg 'wheel delete : first select element(s)'
	endif
	for name in components
		let index = glossary->index(name)
		if index < 0
			echomsg upper_level_name 'does not contain' name
			continue
		endif
		" -- remove from elements list
		eval glossary->remove(index)
		eval elements->remove(index)
		if empty(elements)
			let upper.current = -1
		elseif index <= upper.current
			" if removed element index is before current one,
			" the need to decrease current
			let length = len(elements)
			let upper.current = wheel#taijitu#circular_minus(index, length)
		endif
	endfor
	" -- clean history
	call wheel#pendulum#broom ()
	" -- for index auto update at demand
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	setlocal nomodified
	echomsg 'Changes written to wheel'
	return elements
endfun

fun! wheel#harmony#copy_move (level, ask = 'confirm')
	" Copy or move selected elements at level
	let level = a:level
	" ---- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" ---- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" ---- mode : copy or move
	let prompt = 'Mode ? '
	let answer = confirm(prompt, "&Copy\n&Move", 1)
	if answer == 1
		let mode = 'copy'
	elseif answer == 2
		let mode = 'move'
	endif
	" ---- prompt for destination
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
	let coordin = split(destination, s:level_separ)
	" ---- pre checks
	let selection = wheel#pencil#selection ()
	let components = selection.components
	if empty(components)
		echomsg 'wheel copy / move : first select element(s)'
	endif
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
	endif
	" ---- departure
	if level ==# 'wheel'
		echomsg 'Cannot copy or move the wheel'
		return v:false
	elseif level ==# 'torus'
		for name in components
			" mode must be copy at this stage
			let index = g:wheel.glossary->index(name)
			let torus = deepcopy(g:wheel.toruses[index])
			call wheel#tree#insert_torus (torus)
		endfor
	else
		let upper = wheel#referen#upper (level)
		let glossary = upper.glossary
		let elements = wheel#referen#elements (upper)
		let travellers = []
		for name in components
			let index = glossary->index(name)
			let elem = deepcopy(elements[index])
			eval travellers->add(elem)
			if mode ==# 'move'
				call wheel#tree#remove (level, elem.name)
			endif
		endfor
	endif
	" ---- destination
	if level ==# 'circle'
		call wheel#vortex#voice ('torus', destination)
		for circle in travellers
			call wheel#tree#insert_circle (circle)
		endfor
	elseif level ==# 'location'
		call wheel#vortex#interval (coordin)
		for location in travellers
			call wheel#tree#insert_location (location)
		endfor
	endif
	let g:wheel.timestamp = wheel#pendulum#timestamp ()
	setlocal nomodified
	echomsg 'Changes written to wheel'
	call wheel#rectangle#goto_previous ()
	call wheel#vortex#jump ()
	call wheel#cylinder#recall()
endfun

fun! wheel#harmony#reorganize (ask = 'confirm')
	" Reorganize wheel after elements contained in buffer
	" Rebuild all from scratch
	" Follow folding tree
	" ---- confirm
	if ! wheel#polyphony#confirm (a:ask)
		return v:false
	endif
	" ---- save old wheel before reorganizing
	let prompt = 'Write old wheel to file before reorganizing ?'
	let confirm = confirm(prompt, "&Yes\n&No", 1)
	if confirm == 1
		call wheel#disc#write_wheel ()
	endif
	" ---- update lines in local vars from visible lines
	call wheel#polyphony#update_var_lines ()
	" ---- start from empty wheel
	call wheel#ouroboros#unlet ('g:wheel')
	call wheel#void#wheel ()
	" ---- loop over buffer lines
	let linelist = wheel#teapot#all_lines ()
	let marker = s:fold_markers[0]
	let pat_fold_one = '\m' .. s:fold_1 .. '$'
	let pat_fold_two = '\m' .. s:fold_2 .. '$'
	let pat_dict = '\m^{.*}'
	for line in linelist
		if line =~ pat_fold_one
			" -- torus line
			let torus = split(line)[0]
			call wheel#tree#add_torus(torus)
		elseif line =~ pat_fold_two
			" -- circle line
			let circle = split(line)[0]
			call wheel#tree#add_circle(circle)
		elseif line =~ pat_dict
			" -- location line
			let location = eval(line)
			" -- no pendulum#record in tree#insert_location
			call wheel#tree#insert_location(location)
		endif
	endfor
	" ---- rebuild location index
	call wheel#helix#helix ()
	" ---- rebuild circle index
	call wheel#helix#grid ()
	" ---- rebuild file index
	call wheel#helix#files ()
	" ---- remove invalid entries from history
	call wheel#pendulum#broom ()
	" ---- info
	setlocal nomodified
	echomsg 'Changes written to wheel'
	" -- tune wheel coordinates to first entry in history
	call wheel#vortex#chord(g:wheel_history.line[0].coordin)
endfun
