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
	let length = len(stack.leaves)
	let previous = wheel#gear#circular_minus (stack.current, length)
	if a:0 == 0
		return stack.leaves[previous]
	endif
	let fieldname = a:1
	return stack.leaves[previous][fieldname]
endfun

" Clearing things

fun! wheel#book#clear_options ()
	" Clear mandala local options
	setlocal nofoldenable
endfun

fun! wheel#book#clear_maps ()
	" Clear mandala local maps
	call wheel#gear#unmap(s:map_keys)
endfun

fun! wheel#book#clear_autocmds ()
	" Clear mandala local autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	call wheel#gear#clear_autocmds (group, events)
endfun

fun! wheel#book#clear_vars ()
	" Clear mandala local variables, except the layer stack
	call wheel#gear#unlet (s:mandala_vars)
endfun

fun! wheel#book#fresh ()
	" Fresh empty layer : clear mandala local data
	call wheel#book#clear_options ()
	call wheel#book#clear_maps ()
	call wheel#book#clear_autocmds ()
	call wheel#book#clear_vars ()
	" delete lines -> underscore _ = no storing register
	silent! 1,$ delete _
endfun

" Saving things

fun! wheel#book#save_options ()
	" Save options
	return wheel#gear#save_options (s:mandala_options)
endfun

fun! wheel#book#save_maps ()
	" Save maps
	return wheel#gear#save_maps (s:map_keys)
endfun

fun! wheel#book#save_autocmds ()
	" Save autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	return wheel#gear#save_autocmds (group, events)
endfun

" Restoring things

fun! wheel#book#restore_autocmds (autodict)
	" Restore autocommands
	let group = s:mandala_autocmds_group
	call wheel#gear#restore_autocmds (group, a:autodict)
endfun

" Sync

fun! wheel#book#syncdown ()
	" Sync current element of the stack to mandala state : vars, options, maps
	let stack = b:wheel_stack
	let length = length(stack.leaves)
	if length == 0)
		echomsg 'wheel layer sync stack -> mandala : empty stack'
		return v:false
	endif
	let top = stack.top
	let layer = stack.layers[top]
	" pseudo filename
	let pseudo_file = layer.filename
	exe 'silent file' pseudo_file
	" options
	call wheel#gear#restore_options (layer.options)
	" mappings
	let mappings = deepcopy(layer.mappings)
	call wheel#gear#restore_maps (mappings)
	" autocommands
	let autodict = copy(layer.autocmds)
	call wheel#layer#restore_autocmds (autodict)
	" lines, without filtering
	let b:wheel_lines = copy(layer.lines)
	" filtered mandala content
	" layer.filtered should contain also the original first line, so we have
	" to delete the first line added by :put in the replace routine
	call wheel#mandala#replace (layer.filtered, 'delete')
	" cursor position
	call wheel#gear#restore_cursor (layer.position)
	" address linked to cursor line & context
	let b:wheel_address = copy(layer.address)
	" selection
	let b:wheel_selected = deepcopy(layer.selected)
	" settings
	let b:wheel_settings = deepcopy(layer.settings)
	" reload
	let b:wheel_reload = layer.reload
	" Tell (neo)vim the buffer is to be considered not modified
	setlocal nomodified
endfun

