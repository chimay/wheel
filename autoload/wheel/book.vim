" vim: set ft=vim fdm=indent iskeyword&:

" Layers stack / ring in each mandala buffer
"
" A book contains sheets, leaves, layers

" second implementation
"
" the stack contain the current mandala lines & settings

" Script constants

if ! exists('s:mandala_options')
	let s:mandala_options = wheel#crystal#fetch('mandala/options')
	lockvar s:mandala_options
endif

if ! exists('s:map_keys')
	let s:map_keys = wheel#crystal#fetch('map/keys')
	lockvar s:map_keys
endif

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

if ! exists('s:mandala_autocmds_events')
	let s:mandala_autocmds_events = wheel#crystal#fetch('mandala/autocmds/events')
	lockvar s:mandala_autocmds_events
endif

if ! exists('s:mandala_vars')
	let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
	lockvar s:mandala_vars
endif

" Init stack

fun! wheel#book#init ()
	" Init stack and buffer variables
	call wheel#mandala#init ()
	if ! exists('b:wheel_stack')
		let b:wheel_stack = {}
		let stack = b:wheel_stack
		" index of current leaf
		let stack.current = -1
		let stack.leaves = []
	endif
endfun

" State

fun! wheel#book#stack (...)
	" Return stack of field given by optional argument
	" Return all book (leaves stack) if no argument is given
	" Useful for debugging
	if a:0 == 0
		return b:wheel_stack.leaves
	endif
	let stack = b:wheel_stack
	let fieldname = a:1
	let field_stack = []
	for elem in stack.leaves
		let shadow = deepcopy(elem[fieldname])
		call add(field_stack, shadow)
	endfor
	return field_stack
endfun

fun! wheel#book#previous (...)
	" Return previous field given by optional argument
	" Return previous leaf if no argument is given
	let stack = b:wheel_stack
	let length = wheel#book#length ()
	let previous = wheel#gear#circular_minus (stack.current)
	if a:0 == 0
		return stack.leaves[previous]
	endif
	let fieldname = a:1
	return stack.leaves[previous][fieldname]
endfun

