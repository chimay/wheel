" vim: ft=vim fdm=indent:

" Layers stack / ring in mandala buffer

" Script vars

if ! exists('s:mandala_vars')
	let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
	lockvar s:mandala_vars
endif

if ! exists('s:mandala_options')
	let s:mandala_options = wheel#crystal#fetch('mandala/options')
	lockvar s:mandala_options
endif

if ! exists('s:layer_stack_fields')
	let s:layer_stack_fields = wheel#crystal#fetch('layer/stack/fields')
	lockvar s:layer_stack_fields
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

" Init stack

fun! wheel#layer#init ()
	" Init stack and buffer variables
	" Last inserted layer is at index 0
	if ! exists('b:wheel_stack')
		let b:wheel_stack = {}
		" index of top layer
		let b:wheel_stack.top = -1
		" stack length
		let b:wheel_stack.length = 0
		" other fields
		for fieldname in s:layer_stack_fields
			let b:wheel_stack[fieldname] = []
		endfor
	endif
	if ! exists('b:wheel_lines')
		let b:wheel_lines = []
	endif
	if ! exists('b:wheel_selected')
		let b:wheel_selected = []
	endif
endfun

" Indexes

fun! wheel#layer#pushed_length ()
	" Return layer stack length after push
	let length = b:wheel_stack.length
	let maxim = g:wheel_config.maxim.layers
	if length < maxim
		let length += 1
	else
		let length = maxim
	endif
	return length
endfun

fun! wheel#layer#popped_top ()
	" Return layer stack length after push
	let top = b:wheel_stack.top
	let length = b:wheel_stack.length
	if top >= length
		let top = length - 1
	endif
	return top
endfun

fun! wheel#layer#bottom ()
	" Return layer index to be popped or replaced in stack
	let top = b:wheel_stack.top
	let length = b:wheel_stack.length
	let top = wheel#gear#circular_minus (top, length)
	return top
endfun

fun! wheel#layer#pushed_top ()
	" Return top layer index after push
	let top = b:wheel_stack.top
	let length = b:wheel_stack.length
	let maxim = g:wheel_config.maxim.layers
	if length < maxim
		return top
	else
		return wheel#layer#bottom ()
	endif
endfun

" Clearing things

fun! wheel#layer#clear_vars ()
	" Clear mandala variables, except the layer stack
	call wheel#gear#unlet(s:mandala_vars)
endfun

fun! wheel#layer#clear_maps ()
	" Clear mandala maps
	" normal maps
	call wheel#gear#unmap(s:normal_map_keys, 'n')
	" insert maps
	call wheel#gear#unmap(s:insert_map_keys, 'i')
endfun

fun! wheel#layer#fresh ()
	" Fresh empty layer : clear mandala lines, vars & maps
	" Reset buffer variables
	" Fresh filter and so on
	call wheel#layer#clear_vars ()
	call wheel#layer#clear_maps ()
	" Delete lines -> _ no storing register
	1,$ delete _
endfun

" Saving things

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

fun! wheel#layer#save_options ()
	" Save options
	let ampersands = {}
	for opt in s:mandala_options
		let runme = 'let ampersands.' . opt . '=' . '&' . opt
		execute runme
	endfor
	return ampersands
endfun

" Restoring things

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

fun! wheel#layer#restore_options (options)
	" Restore options
	let options = a:options
	for opt in s:mandala_options
		let runme = 'let &' . opt . '=' . string(options[opt])
		execute runme
	endfor
endfun

" Push & pop to stack

fun! wheel#layer#push_field (field, element)
	" Push element to stack field
	let field = a:field
	let element = a:element
	let top = b:wheel_stack.top
	let length = b:wheel_stack.length
	let maxim = g:wheel_config.maxim.layers
	if length < maxim
		call insert(field, element, top)
	else
		let newtop = wheel#layer#bottom ()
		let field[newtop] = element
	endif
endfun

fun! wheel#layer#pop_field (field)
	" Pop top of stack field
	let field = a:field
	let top = b:wheel_stack.top
	if ! empty(field)
		call remove(field, top)
	endif
endfun

fun! wheel#layer#sync ()
	" Sync top of the stack -> mandala vars, options, maps
	if b:wheel_stack.length == 0
		return v:false
	endif
	let stack = b:wheel_stack
	let top = stack.top
	" Pseudo filename
	let filename = stack.filename
	if empty(filename) || empty(filename[0])
		echomsg 'wheel layer pop : empty stack.'
		return v:false
	endif
	let pseudo_file = filename[top]
	exe 'silent file' pseudo_file
	" Local options
	let options = stack.options
	let ampersands = options[top]
	call wheel#layer#restore_options (ampersands)
	" all mandala content, without filtering
	let lines = stack.lines
	let b:wheel_lines = lines[top]
	" filtered mandala content
	let filtered = stack.filtered
	call wheel#mandala#replace (filtered[top], 'delete')
	" Restore cursor position
	let position = stack.position
	call wheel#gear#restore_cursor (position[top])
	" Restore selection
	let selected = stack.selected
	let b:wheel_selected = selected[top]
	" Restore settings
	let settings = stack.settings
	let b:wheel_settings = settings[top]
	" Restore mappings
	let mappings = stack.mappings
	call wheel#layer#restore_maps (mappings[top])
	" Empty selection if only one element
	if len(b:wheel_selected) == 1
		call wheel#line#deselect ()
	endif
	" Reload
	let reload = stack.reload
	let b:wheel_reload = reload[top]
	" Tell (neo)vim the buffer is to be considered not modified
	setlocal nomodified
endfun

fun! wheel#layer#push ()
	" Push buffer content to the stack
	" save modified local maps
	call wheel#layer#init ()
	let stack = b:wheel_stack
	if stack.top < 0
		let stack.top = 0
	endif
	" pseudo filename
	let filename = stack.filename
	call wheel#layer#push_field (filename, expand('%'))
	" local options
	let options = stack.options
	let ampersands = wheel#layer#save_options ()
	call wheel#layer#push_field (options, ampersands)
	" lines content, without filtering
	let lines = stack.lines
	if empty(b:wheel_lines)
		let buflines = getline(2, '$')
	else
		let buflines = b:wheel_lines
	endif
	call wheel#layer#push_field (lines, buflines)
	" filtered content
	let filtered = stack.filtered
	call wheel#layer#push_field (filtered, getline(1, '$'))
	" cursor position
	let position = stack.position
	call wheel#layer#push_field (position, getcurpos())
	" selected lines
	let selected = stack.selected
	if empty(b:wheel_selected)
		let address = wheel#line#address()
		let b:wheel_selected = [address]
	endif
	call wheel#layer#push_field (selected, b:wheel_selected)
	" buffer settings
	let settings = stack.settings
	if exists('b:wheel_settings')
		call wheel#layer#push_field (settings, b:wheel_settings)
	else
		call wheel#layer#push_field (settings, {})
	endif
	" buffer mappings
	let mappings = stack.mappings
	let mapdict = wheel#layer#save_maps ()
	call wheel#layer#push_field (mappings, mapdict)
	" reload
	let reload = stack.reload
	if exists('b:wheel_reload')
		call wheel#layer#push_field (reload, b:wheel_reload)
	else
		call wheel#layer#push_field (reload, '')
	endif
	" new top index
	let b:wheel_stack.top = wheel#layer#pushed_top ()
	" new length
	let b:wheel_stack.length = wheel#layer#pushed_length ()
endfun

fun! wheel#layer#pop ()
	" Pop buffer content from the stack
	if b:wheel_stack.length == 0
		echomsg 'wheel layer pop : empty stack.'
		return v:false
	endif
	call wheel#layer#sync ()
	for fieldname in s:layer_stack_fields
		let field = b:wheel_stack[fieldname]
		call wheel#layer#pop_field (field)
	endfor
	let b:wheel_stack.length -= 1
	let b:wheel_stack.top = wheel#layer#popped_top ()
endfun

fun! wheel#layer#rotate_right ()
	" Rotate layer stack to the right
	let top = b:wheel_stack.top
	let length = b:wheel_stack.length
	let b:wheel_stack.top = wheel#gear#circular_plus (top, length)
	call wheel#layer#sync ()
endfun

fun! wheel#layer#rotate_left ()
	" Rotate layer stack to the left
	let top = b:wheel_stack.top
	let length = b:wheel_stack.length
	let b:wheel_stack.top = wheel#gear#circular_minus (top, length)
	call wheel#layer#sync ()
endfun
