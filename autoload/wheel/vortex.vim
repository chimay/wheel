" vim: set ft=vim fdm=indent iskeyword&:

" Move to elements

" other names ideas for this file :
"
" chakra
" caduceus

" Variables

if ! exists('s:referen_coordin')
	let s:referen_coordin = ['torus', 'circle', 'location']
	lockvar s:referen_coordin
endif
" Script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" Functions

fun! wheel#vortex#here ()
	" Location of cursor
	let location = {}
	let location.file = expand('%:p')
	let location.line = line('.')
	let location.col = col('.')
	return location
endfun

fun! wheel#vortex#update (...)
	" Update current location to cursor
	" Optional argument : default or verbose
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	let location = wheel#referen#location()
	if empty(location) || location.file !=# expand('%:p')
		return v:false
	endif
	let cur_line = line('.')
	let cur_col = col('.')
	if location.line == cur_line && location.col == cur_col
		return v:false
	endif
	let location.line = cur_line
	let location.col = cur_col
	if mode == 'verbose'
		echo 'wheel : location updated'
	endif
	return v:true
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
	" check location
	let location = wheel#referen#location ()
	if empty(location)
		return win_getid ()
	endif
	" jump
	if mode != 'new'
		let window = wheel#rectangle#tour ()
	else
		let window = v:false
	endif
	if window
		" switch to window containing location buffer
		call win_gotoid(window)
		call cursor(location.line, location.col)
	elseif bufloaded(location.file)
		" load buffer in current window
		let buffer = bufname(location.file)
		execute 'noautocmd silent buffer' buffer
		call cursor(location.line, location.col)
		doautocmd BufEnter
	else
		" edit location file
		exe 'noautocmd silent edit' fnameescape(location.file)
		call cursor(location.line, location.col)
		doautocmd BufRead
		doautocmd BufEnter
	endif
	if g:wheel_config.cd_project > 0
		let markers = g:wheel_config.project_markers
		call wheel#gear#project_root(markers)
	endif
	call wheel#pendulum#record ()
	normal! zv
	silent doautocmd User WheelAfterJump
	call wheel#spiral#cursor ()
	call wheel#status#dashboard ()
	" return
	return win_getid ()
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

fun! wheel#vortex#interval (coordin)
	" Adjust wheel to circle coordin = [torus, circle]
	let indexes = [-1, -1]
	if len(a:coordin) == 2
		let indexes[0] = wheel#vortex#tune ('torus', a:coordin[0])
		if indexes[0] >= 0
			let indexes[1] = wheel#vortex#tune ('circle', a:coordin[1])
		endif
	else
		echomsg 'wheel vortex interval : [' join(a:coordin) '] should contain 2 elements.'
	endif
	return indexes
endfun

fun! wheel#vortex#chord (coordin)
	" Adjust wheel to location coordin = [torus, circle, location]
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

" Switch : tune and jump

fun! wheel#vortex#switch (level, ...)
	" Switch to element with completion
	" Optional argument 0 : name of element
	" Optional argument 1 : jump mode
	call wheel#vortex#update ()
	let level = a:level
	let prompt = 'Switch to ' .. level .. ' : '
	let complete = 'customlist,wheel#complete#' .. level
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
	" Optional argument : jump mode
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	call wheel#vortex#update ()
	let indexes = [-1, -1, -1]
	for level in s:referen_coordin
		let prompt = 'Switch to ' .. level .. ' : '
		let complete = 'customlist,wheel#complete#' .. level
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

fun! wheel#vortex#helix (...)
	" Switch to coordinates in helix index
	" Optional argument : jump mode
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	let prompt = 'Switch to location in index : '
	let complete = 'customlist,wheel#complete#helix'
	let record = input(prompt, '', complete)
	let coordin = split(record, s:level_separ)
	call wheel#vortex#chord (coordin)
	call wheel#vortex#jump (mode)
endfun

fun! wheel#vortex#grid (...)
	" Switch to coordinates in grid index
	" Optional argument : jump mode
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	let prompt = 'Switch to circle in index : '
	let complete = 'customlist,wheel#complete#grid'
	let record = input(prompt, '', complete)
	let coordin = split(record, s:level_separ)
	call wheel#vortex#interval (coordin)
	call wheel#vortex#jump (mode)
endfun

fun! wheel#vortex#history (...)
	" Switch to coordinates in history
	" Optional argument : jump mode
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	let prompt = 'Switch to history element : '
	let complete = 'customlist,wheel#complete#history'
	let record = input(prompt, '', complete)
	let fields = split(record, s:field_separ)
	let entry = fields[1]
	let coordin = split(entry, s:level_separ)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (mode)
endfun
