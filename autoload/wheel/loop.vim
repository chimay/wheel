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

" Looping

fun! wheel#loop#context_menu (settings)
	" Calls function given by the key = cursor line
	" settings is a dictionary, whose keys can be :
	" - dict : name of a dictionary variable in storage.vim
	" - close : whether to close mandala buffer
	" - travel : whether to go back to previous window before applying action
	let settings = a:settings
	let dict = wheel#crystal#fetch (settings.linefun, 'dict')
	let close = settings.ctx_close
	let travel = settings.ctx_travel
	" Cursor line
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	if empty(cursor_line)
		echomsg 'wheel line menu : you selected an empty line'
		return v:false
	endif
	let key = cursor_line
	if ! has_key(dict, key)
		normal! zv
		call wheel#spiral#cursor ()
		echomsg 'wheel line menu : key not found'
		return v:false
	endif
	" Tab page of mandala before processing
	let elder_tab = tabpagenr()
	" Travel before processing ?
	" True for hub menus
	" False for context menus
	" In case of sailing, it's managed by wheel#loop#sailing
	if travel
		call wheel#mandala#related ()
	endif
	" Call
	let value = dict[key]
	let winiden = wheel#gear#call (value)
	if close
		" Close mandala
		" Go back to mandala
		call wheel#cylinder#recall ()
		" Close it
		call wheel#mandala#close ()
		" Go to last destination
		call wheel#gear#win_gotoid (winiden)
	else
		" Do not close mandala
		" Tab page changed ?
		call wheel#gear#win_gotoid (winiden)
		let new_tab = tabpagenr()
		if elder_tab != new_tab
			" Tab changed, move mandala to new tab
			" Go back to mandala
			call wheel#cylinder#recall()
			" Close it in elder tab
			silent call wheel#mandala#close ()
			" Go back in new tab
			exe 'tabnext' new_tab
			" Call mandala back in new tab
			call wheel#cylinder#recall()
		else
			" Same tab, just go to mandala window
			call wheel#cylinder#recall()
		endif
	endif
	return v:true
endfun

fun! wheel#loop#sailing (settings)
	" Go to element(s) on cursor line or selected line(s)
	" settings keys :
	" - level : torus, circle or location
	" - target : current, tab, horizontal_split, vertical_split
	" - close : whether to close mandala
	" - action : navigation function name or funcref
	let settings = copy(a:settings)
	if has_key(settings, 'target')
		let target = settings.target
	else
		let target = 'current'
		let settings.target = target
	endif
	if has_key(settings, 'close')
		let close = settings.close
	else
		let close = v:true
	endif
	if has_key(settings, 'action')
		let Fun = settings.action
	else
		let Fun = 'wheel#line#switch'
	endif
	if empty(b:wheel_selected)
		let selected = [wheel#line#address ()]
	elseif type(b:wheel_selected) == v:t_list
		let selected = b:wheel_selected
	else
		echomsg 'wheel line sailing : bad format for b:wheel_selected'
		return v:false
	endif
	if close
		call wheel#mandala#close ()
	else
		call wheel#mandala#related ()
	endif
	if target != 'current'
		for elem in selected
			let settings.selected = elem
			call wheel#gear#call(Fun, settings)
			normal! zv
			call wheel#spiral#cursor ()
		endfor
	else
		let settings.selected = selected[0]
		call wheel#gear#call(Fun, settings)
		normal! zv
		call wheel#spiral#cursor ()
	endif
	let winiden = win_getid ()
	if ! close
		call wheel#cylinder#recall ()
		" let the user clear the selection with <bar> if he chooses to
	else
		call win_gotoid (winiden)
	endif
	return winiden
endfun
