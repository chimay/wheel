" vim: ft=vim fdm=indent:

" Move to elements
" Move elements

fun! wheel#vortex#here ()
	" Location of cursor
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col  = col('.')
	let location.name = fnamemodify(location.file, ':t:r')
	" Replace spaces par non-breaking spaces
	let location.name = substitute(location.name, ' ', ' ', 'g')
	return location
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
			exe 'silent edit ' . location.file
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

fun! wheel#vortex#prev_torus ()
	call wheel#vortex#previous ('torus')
endfun

fun! wheel#vortex#next_torus ()
	call wheel#vortex#next ('torus')
endfun

fun! wheel#vortex#prev_circle ()
	call wheel#vortex#previous ('circle')
endfun

fun! wheel#vortex#next_circle ()
	call wheel#vortex#next ('circle')
endfun

fun! wheel#vortex#prev_location ()
	call wheel#vortex#previous ('location')
endfun

fun! wheel#vortex#next_location ()
	call wheel#vortex#next ('location')
endfun

" Tune

fun! wheel#vortex#frequency (level, name)
	" Adjust wheel variables of level to name
	let level = a:level
	let name = a:name
	let upper = wheel#referen#upper(level)
	if ! empty(upper.glossary)
		let glossary = upper.glossary
		let index = index(glossary, name)
		if index >= 0
			let upper.current = index
		endif
		return index
	endif
endfun

fun! wheel#vortex#tune_torus (torus_name)
	" Adjust wheel variables to torus_name
	return wheel#vortex#frequency('torus', a:torus_name)
endfun

fun! wheel#vortex#tune_circle (circle_name)
	" Adjust wheel variables to circle_name
	return wheel#vortex#frequency('circle', a:circle_name)
endfun

fun! wheel#vortex#tune_location (location_name)
	" Adjust wheel variables to location_name
	return wheel#vortex#frequency('location', a:location_name)
endfun

fun! wheel#vortex#tune (coordin)
	" Adjust wheel to coordin = [torus, circle, location]
	let indexes = [-1, -1, -1]
	if len(a:coordin) >= 3
		let indexes[0] = wheel#vortex#tune_torus (a:coordin[0])
		if indexes[0] >= 0
			let indexes[1] = wheel#vortex#tune_circle (a:coordin[1])
		endif
		if indexes[1] >= 0
			let indexes[2] = wheel#vortex#tune_location (a:coordin[2])
		endif
	else
		echomsg 'Tuning wheel : [' join(a:coordin) '] does not contain enough elements.'
	endif
	return indexes
endfun

" Switch : tune and jump

fun! wheel#vortex#switch_torus (...)
	" Switch torus
	call wheel#vortex#update ()
	if a:0 > 0
		let torus_name = a:1
	else
		let torus_name =
					\ input('Switch to torus : ', '', 'custom,wheel#complete#torus')
	endif
	let index = wheel#vortex#tune_torus (torus_name)
	if index >= 0
		call wheel#vortex#jump ()
	endif
endfun

fun! wheel#vortex#switch_circle (...)
	" Switch circle
	call wheel#vortex#update ()
	if a:0 > 0
		let circle_name = a:1
	else
		let circle_name =
					\ input('Switch to circle : ', '', 'custom,wheel#complete#circle')
	endif
	let index = wheel#vortex#tune_circle (circle_name)
	if index >= 0
		call wheel#vortex#jump ()
	endif
endfun

fun! wheel#vortex#switch_location (...)
	" Switch location
	call wheel#vortex#update ()
	if a:0 > 0
		let location_name = a:1
	else
		let location_name =
					\ input('Switch to location : ', '', 'custom,wheel#complete#location')
	endif
	let index = wheel#vortex#tune_location (location_name)
	if index >= 0
		call wheel#vortex#jump ()
	endif
endfun
