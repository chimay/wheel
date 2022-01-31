" vim: set ft=vim fdm=indent iskeyword&:

" Curve
"
" Wheel action on the cursor line :
"
" - switching element
" - element in index
" - element in history
"
" called by loop#selection, and sometimes loop#boomerang

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

if ! exists('s:level_separ')
	let s:level_separ = wheel#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

" ---- target

fun! wheel#curve#where (target)
	" Where to jump
	" Return value :
	"   - search-window : search for active buffer
	"                     in tabs & windows
	"   - here : load the buffer in current window,
	"            do not search in tabs & windows
	" See also vortex#jump
	" -- arguments
	let target = a:target
	" -- search for window is better with prompt functions
	"if target ==# 'current'
		"return 'search-window'
	"endif
	" -- coda
	return 'here'
endfun

fun! wheel#curve#target (target)
	" Open target tab / win if needed before navigation
	let target = a:target
	if target ==# 'tab'
		noautocmd tabnew
	elseif target ==# 'horizontal_split'
		noautocmd split
	elseif target ==# 'vertical_split'
		noautocmd vsplit
	elseif target ==# 'horizontal_golden'
		call wheel#spiral#horizontal_split ()
	elseif target ==# 'vertical_golden'
		call wheel#spiral#vertical_split ()
	endif
endfun

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
	echomsg settings
	let component = settings.selection.component
	" ---- jump
	let where = wheel#curve#where (target)
	call wheel#curve#target (target)
	call wheel#vortex#switch(level, component, where)
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
	let where = wheel#curve#where (target)
	call wheel#curve#target (target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (where)
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
	let where = wheel#curve#where (target)
	call wheel#curve#target (target)
	call wheel#vortex#interval (coordin)
	call wheel#vortex#jump (where)
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
	let where = wheel#curve#where (target)
	call wheel#curve#target (a:settings.target)
	if length == 3
		call wheel#vortex#chord(coordin)
	elseif length == 2
		call wheel#vortex#interval (coordin)
	elseif length == 1
		call wheel#vortex#voice('torus', coordin[0])
	else
		return v:false
	endif
	call wheel#vortex#jump (where)
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
	let where = wheel#curve#where (target)
	call wheel#curve#target (target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (where)
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
	let where = wheel#curve#where (target)
	call wheel#curve#target (target)
	call wheel#vortex#chord(coordin)
	call wheel#vortex#jump (where)
	return win_getid ()
endfun
