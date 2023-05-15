" vim: set ft=vim fdm=indent iskeyword&:

" Curve
"
" Wheel action on the cursor line :
"
" - switching element
" - element in index
" - element in history
"
" called by loop#navigation

" ---- script constants

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = wheel#crystal#fetch('separator/field')
lockvar s:field_separ

if exists('s:level_separ')
	unlockvar s:level_separ
endif
let s:level_separ = wheel#crystal#fetch('separator/level')
lockvar s:level_separ

" -- applications

fun! wheel#curve#switch (settings)
	" Switch to element in wheel
	" settings keys :
	" - target : current, tab, horizontal_split, vertical_split
	" - level : torus, circle or location
	" - selection : selection item
	" - selection.component : place to jump to
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let level = settings.level
	let component = settings.selection.component
	" ---- jump
	call wheel#vortex#voice(level, component)
	call wheel#vortex#jump(target)
	return win_getid ()
endfun

fun! wheel#curve#helix (settings)
	" Go to torus > circle > location
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let coordin = split(component, s:level_separ)
	" ---- jump
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (target)
	return win_getid ()
endfun

fun! wheel#curve#grid (settings)
	" Go to torus > circle
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let coordin = split(component, s:level_separ)
	" ---- jump
	call wheel#vortex#interval (coordin)
	call wheel#vortex#jump (target)
	return win_getid ()
endfun

fun! wheel#curve#tree (settings)
	" Go to torus, circle or location in tree view
	" Possible vallues of selection component :
	" - [torus]
	" - [torus, circle]
	" - [torus, circle, location]
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let coordin = settings.selection.component
	let length = len(coordin)
	" ---- jump
	if length == 3
		call wheel#vortex#chord(coordin)
	elseif length == 2
		call wheel#vortex#interval (coordin)
	elseif length == 1
		call wheel#vortex#voice('torus', coordin[0])
	else
		return v:false
	endif
	call wheel#vortex#jump (target)
	return win_getid ()
endfun

fun! wheel#curve#history (settings)
	" Go to location in history
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let coordin = split(fields[1], s:level_separ)
	" ---- jump
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (target)
	return win_getid ()
endfun

fun! wheel#curve#history_circuit (settings)
	" Go to location in history circuit
	return wheel#curve#history (a:settings)
endfun

fun! wheel#curve#frecency (settings)
	" Go to location in history
	" ---- settings
	let settings = a:settings
	let target = settings.target
	let component = settings.selection.component
	let fields = split(component, s:field_separ)
	let coordin = split(fields[1], s:level_separ)
	" ---- jump
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (target)
	return win_getid ()
endfun
