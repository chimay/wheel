" vim: ft=vim fdm=indent:

" Move to elements
" Move elements

fun! wheel#vortex#here ()
	" Location of cursor
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col  = col('.')
	return location
endfun

fun! wheel#vortex#closest ()
	" Find closest location to current buffer & position
	" The search is done in current circle
	let circle = wheel#referen#circle ()
	if empty(circle) || ! has_key(circle, 'locations')
		return [-1, {}]
	endif
	let cur_file = expand('%:p')
	let locations = deepcopy(circle.locations)
	call filter(locations, {_,value -> value.file == cur_file})
	if empty(locations)
		return [-1, {}]
	endif
	let cur_line = line('.')
	let lines = map(deepcopy(locations), {_,val -> val.line})
	let deltas = map(deepcopy(locations), {_,val -> abs(val.line - cur_line)})
	let minim = min(deltas)
	let where = index(deltas, minim)
	let minline = lines[where]
	let closest = filter(locations, {_,value -> value.line == minline})[0]
	let index = index(circle.locations, closest)
	return [index, closest]
endfun

fun! wheel#vortex#update ()
	" Update current location to cursor
	let location = wheel#referen#location()
	if ! empty(location) && location.file ==# expand('%:p')
		let location.line = line('.')
		let location.col  = col('.')
	endif
endfun

fun! wheel#vortex#jump ()
	" Jump to current location
	let location = wheel#referen#location ()
	if ! empty(location)
		let window = wheel#mosaic#tour ()
		if window
			"echomsg 'Switching to window ' window
			call win_gotoid(window)
		elseif bufloaded(location.file)
			"echomsg 'Switching to buffer ' buffer
			let buffer = bufname(location.file)
			exe 'silent buffer ' . buffer
		else
			"echomsg 'Opening file ' location.file
			exe 'silent edit ' . fnameescape(location.file)
		endif
		call cursor(location.line, location.col)
		if g:wheel_config.cd_project > 0
			let markers = g:wheel_config.project_markers
			call wheel#gear#project_root(markers)
		endif
		call wheel#pendulum#record ()
		normal! zv
		silent doautocmd User WheelAfterJump
		call wheel#spiral#cursor ()
		call wheel#status#dashboard ()
	endif
endfun

fun! wheel#vortex#follow ()
	" Try to set current location to match current file
	" Search for current file in current circle
	let cur_file = expand('%:p')
	let cur_location = wheel#referen#location()
	if empty(cur_location)
		return
	endif
	let cur_loc_file = cur_location.file
	if cur_file ==# cur_loc_file
		return
	endif
	let [index, location] = wheel#vortex#closest ()
	if index < 0
		return
	endif
	let circle = wheel#referen#circle ()
	let circle.current = index
	let position = getcurpos()
	call wheel#vortex#jump ()
	call setpos('.', position)
	redraw!
	echomsg 'Wheel follows :' string(location)
endfun

" Next / Previous

fun! wheel#vortex#previous (level)
	" Previous element in level
	let level = a:level
	let upper = wheel#referen#upper(level)
	if ! empty(upper)
		call wheel#vortex#update ()
		let index = upper.current
		let elements = wheel#referen#elements(upper)
		let length = len(elements)
		if empty(elements)
			let upper.current = -1
		else
			let upper.current = wheel#gear#circular_minus(index, length)
		endif
		call wheel#vortex#jump()
	endif
endfun

fun! wheel#vortex#next (level)
	" Next element in level
	let level = a:level
	let upper = wheel#referen#upper(level)
	if ! empty(upper)
		call wheel#vortex#update ()
		let index = upper.current
		let elements = wheel#referen#elements(upper)
		let length = len(elements)
		if empty(elements)
			let upper.current = -1
		else
			let upper.current = wheel#gear#circular_plus(index, length)
		endif
		call wheel#vortex#jump()
	endif
endfun

" Tune

fun! wheel#vortex#tune (level, name)
	" Adjust wheel variables of level to name
	let level = a:level
	let name = a:name
	let upper = wheel#referen#upper(level)
	if ! empty(upper) && ! empty(upper.glossary)
		let glossary = upper.glossary
		let index = index(glossary, name)
		if index >= 0
			let upper.current = index
		else
			echomsg 'Wheel vortex tune : element not found'
		endif
		return index
	else
		echomsg 'Wheel vortex tune : empty or incomplete' level
	endif
endfun

fun! wheel#vortex#chord (coordin)
	" Adjust wheel to coordin = [torus, circle, location]
	let indexes = [-1, -1, -1]
	if len(a:coordin) == 3
		let indexes[0] = wheel#vortex#tune ('torus', a:coordin[0])
		if indexes[0] >= 0
			let indexes[1] = wheel#vortex#tune ('circle', a:coordin[1])
		endif
		if indexes[1] >= 0
			let indexes[2] = wheel#vortex#tune ('location', a:coordin[2])
		endif
	else
		echomsg 'Tuning wheel : [' join(a:coordin) '] should contain 3 elements.'
	endif
	return indexes
endfun

" Switch : tune and jump

fun! wheel#vortex#switch (level, ...)
	" Switch element
	call wheel#vortex#update ()
	let level = a:level
	let prompt = 'Switch to ' . level . ' : '
	let complete =  'custom,wheel#complete#' . level
	if a:0 > 0
		let name = a:1
	else
		let name = input(prompt, '', complete)
	endif
	let index = wheel#vortex#tune (level, name)
	if index >= 0
		call wheel#vortex#jump ()
	endif
endfun
