" vim: ft=vim fdm=indent:

" Move to elements
" Move elements

" Variables

if ! exists('s:referen_coordin')
	let s:referen_coordin = ['torus', 'circle', 'location']
	lockvar s:referen_coordin
endif

" Functions

fun! wheel#vortex#here ()
	" Location of cursor
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col  = col('.')
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

fun! wheel#vortex#jump (...)
	" Jump to current location
	" Optional argument :
	" if new, do not search for buffer in tabs & windows
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	let location = wheel#referen#location ()
	if ! empty(location)
		if mode != 'new'
			let window = wheel#rectangle#tour ()
		else
			let window = v:false
		endif
		if window
			" switch to window containing location buffer
			call win_gotoid(window)
		elseif bufloaded(location.file)
			" load buffer in current window
			let buffer = bufname(location.file)
			exe 'silent buffer' buffer
		else
			" edit location file
			exe 'silent edit' fnameescape(location.file)
		endif
		call cursor(location.line, location.col)
		if g:wheel_config.cd_project > 0
			let markers = g:wheel_config.project_markers
			call wheel#gear#project_root(markers)
		endif
		call wheel#pendulum#record ()
		normal! zv
		doautocmd User WheelAfterJump
		call wheel#spiral#cursor ()
		call wheel#status#dashboard ()
	endif
	return win_getid ()
endfun

" Next / Previous

fun! wheel#vortex#previous (level, ...)
	" Previous element in level
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
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
		call wheel#vortex#jump(mode)
	endif
endfun

fun! wheel#vortex#next (level, ...)
	" Next element in level
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
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
		call wheel#vortex#jump(mode)
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
			echomsg 'wheel vortex tune :' name 'not found'
		endif
		return index
	else
		echomsg 'wheel vortex tune : empty or incomplete' level
		return -1
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
		echomsg 'wheel vortex chord : [' join(a:coordin) '] should contain 3 elements.'
	endif
	return indexes
endfun

" Switch : tune and jump

fun! wheel#vortex#switch (level, ...)
	" Switch to element with completion
	" Optional argument 0 : name of element
	" Optional argument 1 : jump mode
	call wheel#vortex#update ()
	let level = a:level
	let prompt = 'Switch to ' . level . ' : '
	let complete =  'custom,wheel#complete#' . level
	if a:0 > 0
		let name = a:1
	else
		let name = input(prompt, '', complete)
	endif
	if a:0 > 1
		let mode = a:2
	else
		let mode = 'default'
	endif
	let index = wheel#vortex#tune (level, name)
	if index >= 0
		call wheel#vortex#jump (mode)
	endif
endfun

fun! wheel#vortex#multi_switch(...)
	" Switch torus, circle & location
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	call wheel#vortex#update ()
	let indexes = [-1, -1, -1]
	for level in s:referen_coordin
		let prompt = 'Switch to ' . level . ' : '
		let complete =  'custom,wheel#complete#' . level
		let name = input(prompt, '', complete)
		let levind = wheel#referen#coordin_index(level)
		let found = wheel#vortex#tune (level, name)
		if found >= 0
			let indexes[levind] = found
		else
			echomsg 'wheel vortex multi switch : name' name 'not found'
			return indexes
		endif
	endfor
	call wheel#vortex#jump (mode)
	return indexes
endfun
