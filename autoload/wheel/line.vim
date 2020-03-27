" vim: ft=vim fdm=indent:

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
