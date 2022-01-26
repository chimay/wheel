" vim: set ft=vim fdm=indent iskeyword&:

" Loops on mandala lines
"
" other names ideas for this file :
"
" ouroboros

" looping

fun! wheel#loop#selection (settings)
	" Navigation loop for element(s) in cursor line or selection line(s)
	" settings keys :
	"   - function : navigation function name or funcref
	"   - target : current window, tab, horizontal or vertical split,
	"              even or with golden ratio
	"   - related buffer of current mandala
	"   - follow : whether to find closest wheel location after arrival
	"   - close : whether to close mandala
	let settings = copy(a:settings)
	call wheel#whirl#default (settings)
	let Fun = settings.function
	let target = settings.target
	let close = settings.close
	" ---- selection
	let selection = wheel#pencil#selection ()
	let indexes = selection.indexes
	let components = selection.components
	if empty(indexes)
		return v:false
	endif
	" ---- switch off preview
	call wheel#orbiter#switch_off ()
	" ---- go to previous window before processing
	call wheel#rectangle#previous ()
	" ---- target : current window or not ?
	if target == 'current'
		let settings.selection.index = selection.indexes[0]
		let settings.selection.component = selection.components[0]
		let winiden = wheel#gear#call(Fun, settings)
		if &foldopen =~ 'jump'
			normal! zv
		endif
		call wheel#spiral#cursor ()
	else
		let length = len(indexes)
		for ind in range(length)
			let settings.selection.index = selection.indexes[ind]
			let settings.selection.component = selection.component[ind]
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
	" Loop for non-navigation actions in boomerang
	" settings is a dictionary containing settings.menu
	" settings.menu keys can be :
	"   - action : action name or funcref
	"   - close : whether to close mandala
	let settings = copy(a:settings)
	call wheel#whirl#default (settings)
	let menu_settings = settings.menu
	let Fun = settings.function
	let close = menu_settings.close
	" ---- selection
	let selection = wheel#upstream#components ()
	if empty(selection[0])
		return v:false
	endif
	" ---- loop
	for elem in selection
		let settings.selection = elem
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
