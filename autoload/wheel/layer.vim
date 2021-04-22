" vim: ft=vim fdm=indent:

" Layers stack / ring in mandala buffer

" Script constants

if ! exists('s:mandala_options')
	let s:mandala_options = wheel#crystal#fetch('mandala/options')
	lockvar s:mandala_options
endif

if ! exists('s:normal_map_keys')
	let s:normal_map_keys = wheel#crystal#fetch('normal/map/keys')
	lockvar s:normal_map_keys
endif

if ! exists('s:insert_map_keys')
	let s:insert_map_keys = wheel#crystal#fetch('insert/map/keys')
	lockvar s:insert_map_keys
endif

if ! exists('s:visual_map_keys')
	let s:visual_map_keys = wheel#crystal#fetch('visual/map/keys')
	lockvar s:visual_map_keys
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
	" normal maps
	call wheel#gear#unmap(s:normal_map_keys, 'n')
	" insert maps
	call wheel#gear#unmap(s:insert_map_keys, 'i')
endfun

fun! wheel#layer#clear_autocmds ()
	" Clear mandala local autocommands
	let ac_group = s:mandala_autocmds_group
	for event in s:mandala_autocmds_events
		let group_event_pattern = '#' . ac_group . '#' . event . '#<buffer>'
		if exists(group_event_pattern)
			exe 'autocmd!' ac_group event '<buffer>'
		endif
	endfor
endfun

fun! wheel#layer#clear_vars ()
	" Clear mandala local variables, except the layer stack
	call wheel#gear#unlet(s:mandala_vars)
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
	let ampersands = {}
	for option in s:mandala_options
		let runme = 'let ampersands.' . option . '=' . '&' . option
		execute runme
	endfor
	return ampersands
endfun

fun! wheel#layer#save_maps ()
	" Save maps
	let mapdict = { 'normal' : {}, 'insert' : {}, 'visual' : {}}
	for key in s:normal_map_keys
		let mapdict.normal[key] = maparg(key, 'n')
	endfor
	for key in s:insert_map_keys
		let mapdict.insert[key] = maparg(key, 'i')
	endfor
	for key in s:visual_map_keys
		let mapdict.visual[key] = maparg(key, 'v')
	endfor
	return mapdict
endfun

fun! wheel#layer#save_autocmds ()
	" Save autocommands
	let autodict = {}
	let ac_group = s:mandala_autocmds_group
	for event in s:mandala_autocmds_events
		let autodict[event] = wheel#gear#autocmds (ac_group, event)
	endfor
	return autodict
endfun

" Restoring things

fun! wheel#layer#restore_options (options)
	" Restore options
	let options = a:options
	for optname in s:mandala_options
		let runme = 'let &' . optname . '=' . string(options[optname])
		execute runme
	endfor
endfun

fun! wheel#layer#restore_maps (mapdict)
	" Restore maps
	let mapdict = a:mapdict
	for key in keys(mapdict.normal)
		if ! empty(mapdict.normal[key])
			exe 'silent! nnoremap <buffer>' key mapdict.normal[key]
		else
			exe 'silent! nunmap <buffer>' key
		endif
	endfor
	for key in keys(mapdict.insert)
		if ! empty(mapdict.insert[key])
			exe 'silent! inoremap <buffer>' key mapdict.insert[key]
		else
			exe 'silent! iunmap <buffer>' key
		endif
	endfor
	for key in keys(mapdict.visual)
		if ! empty(mapdict.visual[key])
			exe 'silent! vnoremap <buffer>' key mapdict.visual[key]
		else
			exe 'silent! vunmap <buffer>' key
		endif
	endfor
endfun

fun! wheel#layer#restore_autocmds (autodict)
	" Restore autocommands
	let autodict = a:autodict
	let ac_group = s:mandala_autocmds_group
	for event in s:mandala_autocmds_events
		exe 'autocmd!' ac_group event '<buffer>'
		let autocmds = autodict[event]
		if ! empty(autocmds)
			for autocom in autocmds
				exe 'autocmd' ac_group event '<buffer>' autocom
			endfor
		endif
	endfor
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
	call wheel#layer#restore_options (layer.options)
	" mappings
	let mappings = deepcopy(layer.mappings)
	call wheel#layer#restore_maps (mappings)
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
