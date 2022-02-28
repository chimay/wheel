" vim: set ft=vim fdm=indent iskeyword&:

" Waterclock
"
" Travel in the stream of history
"
" Same as vortex, but for history & frecency

" other names ideas for this file :
"   - water glass, clepsydra
"   - sundial
"   - hourglass, sandglass

" ---- script constants

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" ---- newer & older

fun! wheel#waterclock#newer_anywhere ()
	" Go to newer entry in g:wheel_history.circuit
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#taijitu#rotate_right (timeloop)
	let coordin = timeloop[0].coordin
	" rotate makes deepcopy
	let g:wheel_history.circuit = timeloop
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#waterclock#older_anywhere ()
	" Go to older entry in g:wheel_history.circuit
	let timeloop = g:wheel_history.circuit
	let timeloop = wheel#taijitu#rotate_left (timeloop)
	let coordin = timeloop[0].coordin
	" rotate makes deepcopy
	let g:wheel_history.circuit = timeloop
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#waterclock#newer (level = 'wheel')
	" Go to newer entry in g:wheel_history.circuit, same level
	let level = a:level
	if wheel#referen#is_empty(level)
		echomsg 'wheel newer :' level 'is empty'
		return v:false
	endif
	if level ==# 'wheel'
		return wheel#waterclock#newer_anywhere ()
	endif
	" ---- current coordin
	let present_coordin = wheel#referen#coordinates ()
	" ---- index for range in coordin
	let level_index = wheel#referen#level_index_in_coordin (level)
	" ---- back to the future
	let timeloop = g:wheel_history.circuit
	let range = wheel#chain#rangelen(timeloop)
	let range = reverse(range)
	for index in range[:-2]
		let coordin = timeloop[index].coordin
		if present_coordin[:level_index] == coordin[:level_index]
			let timeloop = timeloop->wheel#taijitu#roll_right(index)
			break
		endif
	endfor
	" ---- newer found in same torus or circle ?
	if present_coordin[:level_index] != coordin[:level_index]
		echomsg 'wheel newer : no location found in same' level
		return v:false
	endif
	" ---- update timeloop : rotate return a deepcopy
	let g:wheel_history.circuit = timeloop
	" ---- jump
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

fun! wheel#waterclock#older (level = 'wheel')
	" Go to older entry in g:wheel_history.circuit, same level
	let level = a:level
	if wheel#referen#is_empty(level)
		echomsg 'wheel older :' level 'is empty'
		return v:false
	endif
	if level ==# 'wheel'
		return wheel#waterclock#older_anywhere ()
	endif
	" ---- current coordin
	let present_coordin = wheel#referen#coordinates ()
	" ---- index for range in coordin
	let level_index = wheel#referen#level_index_in_coordin (level)
	" ---- back in history
	let timeloop = g:wheel_history.circuit
	let range = wheel#chain#rangelen(timeloop)
	for index in range[1:]
		let coordin = timeloop[index].coordin
		if present_coordin[:level_index] == coordin[:level_index]
			let timeloop = timeloop->wheel#taijitu#roll_left(index)
			break
		endif
	endfor
	" ---- older found in same torus or circle ?
	if present_coordin[:level_index] != coordin[:level_index]
		echomsg 'wheel older : no location found in same' level
		return v:false
	endif
	" ---- update timeloop : rotate return a deepcopy
	let g:wheel_history.circuit = timeloop
	" ---- jump
	call wheel#vortex#chord(coordin)
	return wheel#vortex#jump ()
endfun

" ---- prompt

fun! wheel#waterclock#history (where = 'search-window')
	" Switch to coordinates in history
	" Optional argument : see vortex#jump optional argument
	let where = a:where
	let prompt = 'Switch to history element : '
	let complete = 'customlist,wheel#complete#history'
	let record = input(prompt, '', complete)
	if empty(record)
		return v:false
	endif
	let fields = split(record, s:field_separ)
	let entry = fields[1]
	let coordin = split(entry, s:level_separ)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (where)
	return v:true
endfun

fun! wheel#waterclock#history_circuit (where = 'search-window')
	" Switch to coordinates in history
	" Optional argument : see vortex#jump optional argument
	let where = a:where
	let prompt = 'Switch to history circuit element : '
	let complete = 'customlist,wheel#complete#history_circuit'
	let record = input(prompt, '', complete)
	if empty(record)
		return v:false
	endif
	let fields = split(record, s:field_separ)
	let entry = fields[1]
	let coordin = split(entry, s:level_separ)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (where)
	return v:true
endfun

fun! wheel#waterclock#frecency (where = 'search-window')
	" Switch to coordinates in frecency
	" Optional argument : see vortex#jump optional argument
	let where = a:where
	let prompt = 'Switch to frecency element : '
	let complete = 'customlist,wheel#complete#frecency'
	let record = input(prompt, '', complete)
	if empty(record)
		return v:false
	endif
	let fields = split(record, s:field_separ)
	let entry = fields[1]
	let coordin = split(entry, s:level_separ)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (where)
	return v:true
endfun
