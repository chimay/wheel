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
	" ---- cursor line
	let cursor_line = getline('.')
	let cursor_line = wheel#pencil#erase (cursor_line)
	if empty(cursor_line)
		echomsg 'wheel line menu : you selected an empty line'
		return v:false
	endif
	let key = cursor_line
	if ! has_key(dict, key)
		if &foldopen =~ 'jump'
			normal! zv
		endif
		call wheel#spiral#cursor ()
		echomsg 'wheel line menu : key not found'
		return v:false
	endif
	" ---- tab page of mandala before processing
	let elder_tab = tabpagenr()
	" ---- travel before processing ?
	" true for helm menus
	" false for context menus
	" in case of sailing, it's managed by loop#sailing
	if travel
		call wheel#rectangle#previous ()
	endif
	" ---- call function linked to cursor line
	let value = dict[key]
	let winiden = wheel#gear#call (value)
	" ---- coda
	if close
		call wheel#mandala#close ()
		" -- go to last destination
		call wheel#gear#win_gotoid (winiden)
	else
		call wheel#gear#win_gotoid (winiden)
		let new_tab = tabpagenr()
		" -- tab changed, move mandala to new tab
		if elder_tab != new_tab
			" close it in elder tab
			silent call wheel#mandala#close ()
			" go back in new tab
			execute 'tabnext' new_tab
		endif
		call wheel#cylinder#recall()
	endif
	return v:true
endfun

fun! wheel#loop#sailing (settings)
	" Go to element(s) on cursor line or selected line(s)
	" settings keys :
	"   - related buffer of current mandala
	"   - target : current window, tab, horizontal or vertical split,
	"              even or with golden ratio
	"   - close : whether to close mandala
	"   - action : navigation function name or funcref
	let settings = copy(a:settings)
	" ---- default values
	if ! has_key(settings, 'related_buffer')
		let settings.related_buffer = b:wheel_related_buffer
	endif
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
	echomsg 'winiden' winiden
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
