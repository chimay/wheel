" vim: set ft=vim fdm=indent iskeyword&:

" Whirl
"
" Wheel navigation, dedicated buffers

fun! wheel#whirl#switch (level)
	" Choose an element of level to switch to
	let level = a:level
	if wheel#referen#is_upper_empty (level)
		let upper_name = wheel#referen#upper_level_name (level)
		echomsg 'wheel whirl switch : empty' upper_name
		return v:false
	endif
	let lines = wheel#flower#element (level)
	call wheel#mandala#blank ('switch/' .. level)
	let settings = { 'level' : level }
	call wheel#river#template (settings)
	if ! empty(lines)
		call wheel#mandala#fill(lines)
	else
		echomsg 'wheel whirl switch : empty or incomplete' level
	endif
	" reload
	let b:wheel_reload = 'wheel#whirl#switch(' .. string(level) .. ')'
endfun

fun! wheel#whirl#helix ()
	" Choose a location coordinate
	" Each coordinate = [torus, circle, location]
	let lines = wheel#flower#helix ()
	if empty(lines)
		echomsg 'wheel whirl helix : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/location')
	let settings = #{ function : 'wheel#curve#helix' }
	call wheel#river#template (settings)
	call wheel#mandala#fill(lines)
	" reload
	let b:wheel_reload = 'wheel#whirl#helix'
endfun

fun! wheel#whirl#grid ()
	" Choose a circle coordinate
	" Each coordinate = [torus, circle]
	let lines = wheel#flower#grid ()
	if empty(lines)
		echomsg 'wheel whirl grid : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/circle')
	let settings = #{ function : 'wheel#curve#grid' }
	call wheel#river#template (settings)
	call wheel#mandala#fill (lines)
	" reload
	let b:wheel_reload = 'wheel#whirl#grid'
endfun

fun! wheel#whirl#tree ()
	" Choose an element in the wheel index tree
	let lines = wheel#flower#tree ()
	if empty(lines)
		echomsg 'wheel whirl tree : empty wheel'
		return v:false
	endif
	call wheel#mandala#blank ('index/tree')
	let settings = #{ function : 'wheel#curve#tree' }
	call wheel#river#template (settings)
	call wheel#mandala#folding_options ()
	call wheel#mandala#fill(lines)
	" properties
	let b:wheel_nature.is_treeish = v:true
	" full information
	let b:wheel_full = wheel#cuboctahedron#tree ()
	" reload
	let b:wheel_reload = 'wheel#whirl#tree'
endfun

fun! wheel#whirl#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#river#generic('history')
endfun

fun! wheel#whirl#history_circuit ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#river#generic('history_circuit')
endfun

fun! wheel#whirl#frecency ()
	" Choose a location coordinate in frecency
	" Each coordinate = [torus, circle, location]
	call wheel#river#generic('frecency')
endfun
