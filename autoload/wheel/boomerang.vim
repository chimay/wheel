" vim: ft=vim fdm=indent:

" Context menus, acting back on a mandala buffer

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

" Sync buffer variables & top of stack

fun! wheel#boomerang#sync ()
	" Sync cursor address, selection & settings at top of stack --> mandala state
	let stack = b:wheel_stack
	let top = b:wheel_stack.top
	let b:wheel_address = deepcopy(wheel#layer#top_field('address'))
	" the action will be performed on the selection of the previous layer
	let b:wheel_selected = deepcopy(wheel#layer#top_field('selected'))
	" the action will be performed with the settings of the previous layer
	let b:wheel_settings = deepcopy(wheel#layer#top_field('settings'))
endfun

" Helpers

fun! wheel#boomerang#remove_deleted ()
	" Remove deleted elements from special buffer lines of the previous layer
	" deleted = selected or cursor address
	" e.g. : deleted buffers, closed tabs
	let top = b:wheel_stack.top
	let lines = wheel#layer#top_field ('lines')
	let filtered = wheel#layer#top_field ('filtered')
	let selected = wheel#layer#top_field ('selected')
	if ! empty(selected)
		" if manually selected with space
		for elem in selected
			let elem = s:selected_mark . elem
			call wheel#chain#remove_element (elem, lines)
			call wheel#chain#remove_element (elem, filtered)
		endfor
	else
		" operate by default on cursor line address on top layer
		" no manual selection, no marker
		let elem = wheel#layer#top_field ('address')
		if type(elem) == v:t_list
			let elem = elem[-1]
		endif
		call wheel#chain#remove_element (elem, lines)
		call wheel#chain#remove_element (elem, filtered)
	endif
endfun

" Generic

fun! wheel#boomerang#menu (dictname, ...)
	" Context menu
	if a:0 > 0
		let optional = a:1
	else
		let optional = {}
	endif
	if ! has_key(optional, 'ctx_close')
		" ctx_close = v:false by default, to be able to perform other
		" operations after this one
		let optional.ctx_close = v:false
	endif
	if ! has_key(optional, 'ctx_travel')
		" ctx_travel = v:false by default, to be able to catch mandala buffer variables
		let optional.ctx_travel = v:false
	endif
	" selection
	if empty(b:wheel_selected)
		if line('.') == 1
			if line('$') > 1
				call cursor(2, 1)
			else
				echomsg 'wheel boomerang menu : not enough lines for a default selection.'
				return v:false
			endif
		endif
	endif
	let dictname = 'context/' . a:dictname
	let settings = {'linefun' : dictname, 'ctx_close' : optional.ctx_close, 'ctx_travel' : optional.ctx_travel}
	call wheel#tower#staircase(settings)
	call wheel#boomerang#sync ()
	" Let wheel#line#menu handle open / close,
	" tell wheel#line#sailing to forget it
	let b:wheel_settings.close = v:false
	" Default selection = cursor line address of previous layer
	if empty(b:wheel_selected)
		let b:wheel_selected = [wheel#layer#top_field ('address')]
	endif
	" Reload function
	let b:wheel_reload = "wheel#boomerang#menu('" . a:dictname . "')"
endfun

" Applications

fun! wheel#boomerang#sailing (action)
	" Sailing actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.ctx_action = 'sailing'
	if action == 'current'
		let settings.target = 'current'
		call wheel#line#sailing (settings)
		return v:true
	elseif action == 'tab'
		let settings.target = 'tab'
		call wheel#line#sailing (settings)
		return v:true
	elseif action == 'horizontal_split'
		let settings.target = 'horizontal_split'
		call wheel#line#sailing (settings)
		return v:true
	elseif action == 'vertical_split'
		let settings.target = 'vertical_split'
		call wheel#line#sailing (settings)
		return v:true
	elseif action == 'horizontal_golden'
		let settings.target = 'horizontal_golden'
		call wheel#line#sailing (settings)
		return v:true
	elseif action == 'vertical_golden'
		let settings.target = 'vertical_golden'
		call wheel#line#sailing (settings)
		return v:true
	endif
	return v:false
endfun

fun! wheel#boomerang#opened_files (action)
	" Opened files (buffers) actions
	let action = a:action
	let settings = b:wheel_settings
	if action == 'delete' || action == 'wipe'
		let settings.ctx_action = action
		" remove deleted elements from the opened_files mandala
		call wheel#boomerang#remove_deleted ()
		" To inform wheel#line#sailing
		" that a loop on selected elements is necessary ;
		" it does not perform it if target == 'current'
		let settings.target = 'none'
		call wheel#line#sailing (settings)
		let top = b:wheel_stack.top
		let b:wheel_stack.layers[top].selected = []
	endif
endfun

fun! wheel#boomerang#tabwins (action)
	" Buffers visible in tabs & wins
	let action = a:action
	let settings = b:wheel_settings
	let settings.ctx_action = action
	if action == 'open'
		" wheel#line#sailing will process the first selected line
		let settings.target = 'current'
		return wheel#line#sailing (settings)
	elseif action == 'tabnew'
		call wheel#line#sailing (settings)
		return v:true
	elseif action == 'tabclose'
		" inform wheel#line#sailing that a loop on selected elements is necessary
		let settings.target = 'none'
		" closing last tab first
		call reverse(b:wheel_selected)
		call wheel#line#sailing (settings)
		let top = b:wheel_stack.top
		let b:wheel_stack.layers[top].selected = []
		return v:true
	endif
	return v:false
endfun

fun! wheel#boomerang#tabwins_tree (action)
	" Buffers visible in tree of tabs & wins
	return wheel#boomerang#tabwins (a:action)
endfun

fun! wheel#boomerang#grep (action)
	" Grep actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.ctx_action = action
	if action == 'quickfix'
		call wheel#mandala#close ()
		call wheel#vector#copen ()
	endif
endfun

fun! wheel#boomerang#yank (action)
	" Yank actions
	" action = before / after
	let action = a:action
	let settings = b:wheel_settings
	let settings.ctx_action = action
	let mode = b:wheel_settings.mode
	call wheel#line#paste_{mode} (action, 'open')
endfun
