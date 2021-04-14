" vim: ft=vim fdm=indent:

" Context menus, acting back on a mandala buffer

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

" Sync buffer variables & top of stack

fun! wheel#boomerang#sync ()
	" Sync selection & settings at top of stack --> buffer variables
	" the action will be performed on the selection of the previous layer
	let stack = b:wheel_stack
	let top = b:wheel_stack.top
	if ! empty(stack.selected)
		let b:wheel_selected = deepcopy(stack.selected[top])
	endif
	" the action will be performed with the settings of the previous layer
	if ! empty(stack.settings)
		let b:wheel_settings = deepcopy(stack.settings[top])
	endif
endfun

" Helpers

fun! wheel#boomerang#remove_deleted ()
	" Remove deleted elements from special buffer lines of the previous layer
	" e.g. : deleted buffers, closed tabs
	let top = b:wheel_stack.top
	let lines = b:wheel_stack.lines[top]
	let filtered = b:wheel_stack.filtered[top]
	for elem in b:wheel_selected
		call wheel#chain#remove_element (elem, lines)
		call wheel#chain#remove_element (elem, filtered)
		" if manually selected with space
		let elem = s:selected_mark . elem
		call wheel#chain#remove_element (elem, lines)
		call wheel#chain#remove_element (elem, filtered)
	endfor
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
	if empty(b:wheel_selected)
		if line('.') == 1 && ! empty(wheel#line#address ())
			echomsg 'wheel boomerang menu : first line filter is not a valid selection.'
			return v:false
		endif
		if empty(wheel#line#address ()) && line('$') > 1
			call cursor(2, 1)
		endif
		if empty(wheel#line#address ())
			echomsg 'wheel boomerang menu : empty selection'
			return v:false
		endif
	endif
	let dictname = 'context/' . a:dictname
	let settings = {'linefun' : dictname, 'ctx_close' : optional.ctx_close, 'ctx_travel' : optional.ctx_travel}
	call wheel#tower#staircase(settings)
	call wheel#boomerang#sync ()
	" Let wheel#line#menu handle open / close,
	" tell wheel#line#sailing to forget it
	let b:wheel_settings.close = v:false
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
		" To inform wheel#line#sailing
		" that a loop on selected elements is necessary ;
		" it does not perform it if target == 'current'
		let settings.target = 'none'
		call wheel#boomerang#remove_deleted ()
		call wheel#line#sailing (settings)
		let top = b:wheel_stack.top
		let b:wheel_stack.selected[top] = []
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
	elseif action == 'tabclose'
		" To inform wheel#line#sailing
		" that a loop on selected elements is necessary ;
		" it does not perform it if target == 'current'
		let settings.target = 'none'
		" closing last tab first
		call reverse(b:wheel_selected)
		call wheel#line#sailing (settings)
		let top = b:wheel_stack.top
		let b:wheel_stack.selected[top] = []
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
