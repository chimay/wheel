" vim: ft=vim fdm=indent:

" Action of the cursor line :
" - Going to an element

fun! wheel#line#filter ()
	" Return lines matching words of first line
	if ! exists('b:wheel_menu') || empty(b:wheel_menu)
		let linelist = getline(2, '$')
		let b:wheel_menu = copy(linelist)
	else
		let linelist = copy(b:wheel_menu)
	endif
	let first = getline(1)
	let wordlist = split(first)
	let Matches = function('wheel#gear#word_filter', [wordlist])
	let candidates = filter(linelist, Matches)
	return candidates
endfu

fun! wheel#line#torus (...)
	" Switch to torus whose name is in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let torus_name = getline('.')
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#switch_torus(torus_name)
endfun

fun! wheel#line#circle (...)
	" Switch to circle whose name is in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let circle_name = getline('.')
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#switch_circle(circle_name)
endfun

fun! wheel#line#location (...)
	" Switch to location whose name is in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let location_name = getline('.')
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#switch_location(location_name)
endfun

fun! wheel#line#helix (...)
	" Switch to helix location in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let line = getline('.')
	let list = split(line, ' ')
	let coordin = [list[0], list[2], list[4]]
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#tune(coordin)
	call wheel#vortex#jump ()
endfun

fun! wheel#line#grid (...)
	" Switch to grid circle in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let line = getline('.')
	let list = split(line, ' ')
	let coordin = [list[0], list[2]]
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#tune_torus(coordin[0])
	call wheel#vortex#tune_circle(coordin[1])
	call wheel#vortex#jump ()
endfun

fun! wheel#line#history (...)
	" Switch to history location in current line
	let mode = 'close'
	if a:0 > 0
		let mode = a:1
	endif
	let line = getline('.')
	let list = split(line, ' ')
	let coordin = [list[6], list[8], list[10]]
	if mode ==# 'close'
		call wheel#mandala#close ()
	else
		if winnr('$') > 1
			wincmd p
		else
			bdelete!
		endif
	endif
	call wheel#vortex#tune(coordin)
	call wheel#vortex#jump ()
endfun
