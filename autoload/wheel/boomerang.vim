" vim: ft=vim fdm=indent:

" Context menus, acting back on a wheel buffer

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

" Sync buffer variables & top of stack

fun! wheel#boomerang#sync ()
	" Sync buffer variables with top of stack
	" Selection
	let stack = b:wheel_stack
	if ! empty(stack.selected)
		let b:wheel_selected = deepcopy(stack.selected[0])
	endif
	" If selection is empty, take the old cursor line
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
	let full = b:wheel_stack.full[-1]
	let current = b:wheel_stack.current[-1]
	for elem in b:wheel_selected
		call wheel#chain#remove_element (elem, full)
		call wheel#chain#remove_element (elem, current)
		" if manually selected with space
		let elem = s:selected_mark . elem
		call wheel#chain#remove_element (elem, full)
		call wheel#chain#remove_element (elem, current)
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
	if ! has_key(optional, 'close')
		" Close = v:false by default, to be able to catch wheel buffer variables
		let optional.close = v:false
	endif
	if ! has_key(optional, 'travel')
		let optional.travel = v:false
	endif
	if ! exists('b:wheel_selected') || empty(b:wheel_selected)
		if empty(wheel#line#address ())
			echomsg 'Wheel boomerang menu : empty selection'
			return
		endif
	endif
	let dictname = 'context/' . a:dictname
	let settings = {'linefun' : dictname, 'close' : optional.close, 'travel' : optional.travel}
	call wheel#tower#staircase(settings)
	call wheel#boomerang#sync ()
	" Let wheel#line#menu handle open / close
	let b:wheel_settings.close = v:false
	" No more layers
	" Tab mapping will be restored by wheel#layer#pop if we go back
	nunmap <buffer> <tab>
endfun

" Applications

fun! wheel#boomerang#sailing (action)
	" Sailing actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.context_action = 'sailing'
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
		let settings.context_action = action
		" To inform wheel#line#sailing
		" that a loop on selected elements is necessary ;
		" it does not perform it if target == 'current'
		let settings.target = 'none'
		call wheel#boomerang#remove_selected ()
		call wheel#line#sailing (settings)
		let b:wheel_stack.selected[-1] = []
	endif
endfun

fun! wheel#boomerang#tabwins (action)
	" Buffers visible in tabs & wins
	let action = a:action
	let settings = b:wheel_settings
	let settings.context_action = action
	if action == 'open'
		let settings.target = 'current'
		call wheel#line#sailing (settings)
		return v:true
	elseif action == 'tabclose'
		" To inform wheel#line#sailing
		" that a loop on selected elements is necessary ;
		" it does not perform it if target == 'current'
		let settings.target = 'none'
		call wheel#boomerang#remove_selected ()
		call reverse(b:wheel_selected)
		call wheel#line#sailing (settings)
		let b:wheel_stack.selected[-1] = []
		return v:true
	endif
	return v:false
endfun

fun! wheel#boomerang#grep (action)
	" Grep actions
	let action = a:action
	let settings = b:wheel_settings
	let settings.context_action = action
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
	let settings.context_action = action
	let mode = b:wheel_settings.mode
	call wheel#line#paste_{mode} (action, 'open')
endfun
