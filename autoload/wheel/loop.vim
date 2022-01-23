" vim: set ft=vim fdm=indent iskeyword&:

" Loops on mandala lines
"
" other names ideas for this file :
"
" ouroboros

" script constants

if ! exists('s:selection_pattern')
	let s:selection_pattern = wheel#crystal#fetch('selection/pattern')
	lockvar s:selection_pattern
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
	call wheel#sailing#default (settings)
	let Fun = settings.function
	let target = settings.target
	let close = settings.close
	" ---- selection
	let selected = wheel#pencil#addresses ()
	if empty(selected[0])
		return v:false
	endif
	" ---- switch off preview
	call wheel#orbiter#switch_off ()
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
		call wheel#cylinder#close ()
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
	let selected = wheel#upstream#addresses ()
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
		call wheel#cylinder#close ()
	else
		call wheel#cylinder#recall ()
	endif
	return winiden
endfun
