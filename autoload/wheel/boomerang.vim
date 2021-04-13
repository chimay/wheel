" vim: ft=vim fdm=indent:

" Context menus, acting back on a mandala buffer

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

" Sync buffer variables & top of stack

fun! wheel#boomerang#sync ()
	" Sync top of stack --> buffer variables
	" Selection
	let stack = b:wheel_stack
	if ! empty(stack.selected)
		let b:wheel_selected = deepcopy(stack.selected[0])
	endif
	" If selection is empty, take the old cursor line
	" Should be filled with wheel#line#address anyway
	if empty(b:wheel_selected)
		let linum = stack.positions[0][1]
		let now = stack.current[0]
		let b:wheel_selected = [now[linum - 1]]
	endif
	" Sync settings with top of stack
	if ! empty(stack.settings)
		let b:wheel_settings = deepcopy(stack.settings[0])
	endif
endfun

" Helpers

fun! wheel#boomerang#remove_selected ()
	" Remove selected elements from special buffer lines
	let lines = b:wheel_stack.lines[0]
	let filtered = b:wheel_stack.filtered[0]
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
	if ! exists('b:wheel_selected') || empty(b:wheel_selected)
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
	" Let wheel#line#menu handle open / close
	let b:wheel_settings.close = v:false
endfun

" Applications

fun! wheel#boomerang#sailing (action)
	" Sailing actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.ctx_key = 'sailing'
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
		let settings.ctx_key = action
		" To inform wheel#line#sailing
		" that a loop on selected elements is necessary ;
		" it does not perform it if target == 'current'
		let settings.target = 'none'
		call wheel#boomerang#remove_selected ()
		call wheel#line#sailing (settings)
		let b:wheel_stack.selected[0] = []
	endif
endfun

fun! wheel#boomerang#tabwins (action)
	" Buffers visible in tabs & wins
	let action = a:action
	let settings = b:wheel_settings
	let settings.ctx_key = action
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
		let b:wheel_stack.selected[0] = []
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
	let settings.ctx_key = action
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
	let settings.ctx_key = action
	let mode = b:wheel_settings.mode
	call wheel#line#paste_{mode} (action, 'open')
endfun
