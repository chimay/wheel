" vim: ft=vim fdm=indent:

" Layers stack / ring in each mandala buffer

" other name ideas :
" sheet

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

fun! wheel#layer#init ()
	" Init stack and buffer variables
	" Last inserted layer is at index 0
	call wheel#mandala#init ()
	if ! exists('b:wheel_stack')
		let b:wheel_stack = {}
		let stack = b:wheel_stack
		" index of top layer
		let stack.top = -1
		let stack.layers = []
	endif
endfun

" State

fun! wheel#layer#length ()
	" Layer stack length
	return len(b:wheel_stack.layers)
endfun

fun! wheel#layer#bottom ()
	" Return layer index to be popped or replaced in stack
	let top = b:wheel_stack.top
	let length = wheel#layer#length ()
	let bottom = wheel#gear#circular_minus (top, length)
	return bottom
endfun

fun! wheel#layer#stack (...)
	" Return stack of fieldname given by argument
	" Return layer stack if no argument is given
	" Useful for debugging
	if a:0 == 0
		return b:wheel_stack.layers
	endif
	let stack = b:wheel_stack
	let fieldname = a:1
	let field_stack = []
	for elem in stack.layers
		let shadow = deepcopy(elem[fieldname])
		call add(field_stack, shadow)
	endfor
	return field_stack
endfun

fun! wheel#layer#top_field (...)
	" Return field given by fieldname at top of stack
	" Return top of stack if no argument is given
	let stack = b:wheel_stack
	if a:0 == 0
		return stack.layers[stack.top]
	endif
	let fieldname = a:1
	return stack.layers[stack.top][fieldname]
endfun

" Clearing things

fun! wheel#layer#clear_options ()
	" Clear mandala local options
	setlocal nofoldenable
endfun

fun! wheel#layer#clear_maps ()
	" Clear mandala local maps
	call wheel#gear#unmap(s:map_keys)
endfun

fun! wheel#layer#clear_autocmds ()
	" Clear mandala local autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	call wheel#gear#clear_autocmds (group, events)
endfun

fun! wheel#layer#clear_vars ()
	" Clear mandala local variables, except the layer stack
	call wheel#gear#unlet (s:mandala_vars)
endfun

fun! wheel#layer#fresh ()
	" Fresh empty layer : clear mandala local data
	call wheel#layer#clear_options ()
	call wheel#layer#clear_maps ()
	call wheel#layer#clear_autocmds ()
	call wheel#layer#clear_vars ()
	" delete lines -> underscore _ = no storing register
	silent! 1,$ delete _
endfun

" Saving things

fun! wheel#layer#save_options ()
	" Save options
	return wheel#gear#save_options (s:mandala_options)
endfun

fun! wheel#layer#save_maps ()
	" Save maps
	return wheel#gear#save_maps (s:map_keys)
endfun

fun! wheel#layer#save_autocmds ()
	" Save autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	return wheel#gear#save_autocmds (group, events)
endfun

" Restoring things

fun! wheel#layer#restore_autocmds (autodict)
	" Restore autocommands
	let group = s:mandala_autocmds_group
	call wheel#gear#restore_autocmds (group, a:autodict)
endfun

" Sync & swap

fun! wheel#layer#sync ()
	" Sync top of the stack to mandala state : vars, options, maps
	if wheel#layer#length () == 0
		echomsg 'wheel layer sync : empty stack.'
		return v:false
	endif
	let stack = b:wheel_stack
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

fun! wheel#layer#swap ()
	" Swap mandala state and top of stack
	call wheel#layer#init ()
	let stack = b:wheel_stack
	" -- Mandala state -> swap space
	let swap = {}
	" pseudo filename
	let swap.filename = expand('%')
	" options
	let swap.options = wheel#layer#save_options ()
	" mappings
	let swap.mappings = wheel#layer#save_maps ()
	" autocommands
	let swap.autocmds = wheel#layer#save_autocmds ()
	" lines, without filtering
	if empty(b:wheel_lines)
		let begin = wheel#mandala#first_data_line ()
		let swap.lines = getline(begin, '$')
	else
		let swap.lines = copy(b:wheel_lines)
	endif
	" filtered content
	let swap.filtered = getline(1, '$')
	" cursor position
	let swap.position = getcurpos()
	" address of cursor line
	" useful for boomerang = context menus
	let swap.address = wheel#line#address()
	" selected lines
	let swap.selected = deepcopy(b:wheel_selected)
	" settings
	if exists('b:wheel_settings')
		let swap.settings = b:wheel_settings
	else
		let swap.settings = {}
	endif
	" reload
	if exists('b:wheel_reload')
		let swap.reload = b:wheel_reload
	else
		let swap.reload = ''
	endif
	" -- Stack top -> mandala state
	call wheel#layer#sync ()
	" -- Swap space -> top of stack
	let stack.layers[stack.top] = swap
endfun

" Push & pop

fun! wheel#layer#push ()
	" Push buffer content to the stack
	" save modified local maps
	call wheel#layer#init ()
	let stack = b:wheel_stack
	let length = wheel#layer#length ()
	let maxim = g:wheel_config.maxim.layers
	if length == 0
		let stack.top = 0
	endif
	if length < maxim
		" insert new layer before top
		" the top index will reflect the new element,
		" no need to update it
		call insert(stack.layers, {}, stack.top)
	else
		" new layer will replace the bottom
		let stack.top = wheel#layer#bottom ()
	endif
	" layer to fill / update
	let layer = stack.layers[stack.top]
	" pseudo filename
	let layer.filename = expand('%')
	" options
	let layer.options = wheel#layer#save_options ()
	" mappings
	let layer.mappings = wheel#layer#save_maps ()
	" autocommands
	let layer.autocmds = wheel#layer#save_autocmds ()
	" lines, without filtering
	if empty(b:wheel_lines)
		let begin = wheel#mandala#first_data_line ()
		let layer.lines = getline(begin, '$')
	else
		let layer.lines = copy(b:wheel_lines)
	endif
	" filtered content
	let layer.filtered = getline(1, '$')
	" cursor position
	let layer.position = getcurpos()
	" address of cursor line
	" useful for boomerang = context menus
	let layer.address = wheel#line#address()
	" selected lines
	if exists('b:wheel_selected')
		let layer.selected = deepcopy(b:wheel_selected)
	else
		let layer.selected = []
	endif
	" settings
	if exists('b:wheel_settings')
		let layer.settings = deepcopy(b:wheel_settings)
	else
		let layer.settings = {}
	endif
	" reload
	if exists('b:wheel_reload')
		let layer.reload = b:wheel_reload
	else
		let layer.reload = ''
	endif
endfun

fun! wheel#layer#pop ()
	" Pop top of stack to the mandala state
	let length = wheel#layer#length ()
	if length == 0
		echomsg 'wheel layer pop : empty stack.'
		return v:false
	endif
	" pop
	call wheel#layer#sync ()
	let stack = b:wheel_stack
	call remove(stack.layers, stack.top)
	" update length
	let length = wheel#layer#length ()
	" update top index
	if stack.top >= length
		let stack.top = length - 1
	endif
	call wheel#status#layer ()
endfun

" Forward & backward

fun! wheel#layer#forward ()
	" Go forward in layer stack
	let length = wheel#layer#length ()
	if length == 0
		echomsg 'wheel layer forward : empty stack.'
		return v:false
	endif
	let stack = b:wheel_stack
	let top = stack.top
	let length = wheel#layer#length ()
	let stack.top = wheel#gear#circular_minus (top, length)
	call wheel#layer#swap ()
	call wheel#status#layer ()
endfun

fun! wheel#layer#backward ()
	" Go backward in layer stack
	let length = wheel#layer#length ()
	if length == 0
		echomsg 'wheel layer backward : empty stack.'
		return v:false
	endif
	call wheel#layer#swap ()
	let top = b:wheel_stack.top
	let length = wheel#layer#length ()
	let b:wheel_stack.top = wheel#gear#circular_plus (top, length)
	call wheel#status#layer ()
endfun

" Switch

fun! wheel#layer#switch (...)
	" Switch to layer with completion
	if wheel#layer#length () == 0
		echomsg 'wheel layer switch : empty layer stack.'
		return v:false
	endif
	let prompt = 'Switch to layer : '
	let complete =  'customlist,wheel#completelist#layer'
	if a:0 > 0
		let name = a:1
	else
		let name = input(prompt, '', complete)
	endif
	let name = wheel#mandala#pseudo (name)
	let filenames = wheel#layer#stack ('filename')
	let stack = b:wheel_stack
	let top = index(filenames, name)
	if top < 0
		return v:false
	endif
	let stack.top = top
	call wheel#layer#swap ()
	call wheel#status#layer ()
endfun
