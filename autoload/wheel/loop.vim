" vim: set ft=vim fdm=indent iskeyword&:

" Loops on mandala lines
"
" other names ideas for this file :
"
" ouroboros

" Script constants

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#crystal#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

" looping

fun! wheel#loop#sailing (settings)
	" Navigation loop for element(s) in cursor line or selected line(s)
	" settings keys :
	"   - function : navigation function name or funcref
	"   - target : current window, tab, horizontal or vertical split,
	"              even or with golden ratio
	"   - related buffer of current mandala
	"   - close : whether to close mandala
	let settings = copy(a:settings)
	" ---- default values
	if has_key(settings, 'function')
		let Fun = settings.function
	else
		let Fun = 'wheel#line#switch'
	endif
	if has_key(settings, 'target')
		let target = settings.target
	else
		let target = 'current'
		let settings.target = target
	endif
	if ! has_key(settings, 'related_buffer')
		let settings.related_buffer = b:wheel_related_buffer
	endif
	if has_key(settings, 'close')
		let close = settings.close
	else
		let close = v:true
	endif
	" ---- selection
	let selected = wheel#pencil#addresses ()
	if empty(selected[0])
		return v:false
	endif
	" ---- go to previous window before processing
	call wheel#rectangle#previous ()
	" ---- target : current window or not ?
	if target == 'current'
		let settings.selected = selected[0]
		let winiden = wheel#gear#call(Fun, settings)
		if &foldopen =~ 'jump'
			normal! zv
		endif
		call wheel#spiral#cursor ()
	else
		for elem in selected
			let settings.selected = elem
			let winiden = wheel#gear#call(Fun, settings)
			if &foldopen =~ 'jump'
				normal! zv
			endif
			call wheel#spiral#cursor ()
		endfor
	endif
	" ---- coda
	if close
		call wheel#mandala#close ()
		" go to last destination
		call win_gotoid (winiden)
	else
		call wheel#cylinder#recall ()
		" let the user clear the selection with <bar> if he chooses to
	endif
	return winiden
endfun

fun! wheel#loop#boomerang (settings)
	" Loop for non-sailing actions in boomerang
	" settings is a dictionary containing settings.menu
	" settings.menu keys can be :
	"   - action : action name or funcref
	"   - close : whether to close mandala
	let settings = copy(a:settings)
	let menu_settings = settings.menu
	let Fun = settings.function
	let close = menu_settings.close
	" ---- selection
	let selected = wheel#branch#addresses ()
	if empty(selected[0])
		return v:false
	endif
	" ---- loop
	for elem in selected
		let settings.selected = elem
		let winiden = wheel#gear#call(Fun, settings)
		if &foldopen =~ 'jump'
			normal! zv
		endif
		call wheel#spiral#cursor ()
	endfor
	" ---- coda
	if close
		call wheel#mandala#close ()
	else
		call wheel#cylinder#recall ()
	endif
	return winiden
endfun
