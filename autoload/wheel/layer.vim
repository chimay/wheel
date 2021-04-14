" vim: ft=vim fdm=indent:

" Layers stack on mandala buffer
"
" Beware : index 0 in fields are at the top of the stack
" e.g. : b:wheel_stack.field[0]

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
		for field in s:layer_stack_fields
			let b:wheel_stack[field] = []
		endfor
	endif
	if ! exists('b:wheel_lines')
		let b:wheel_lines = []
	endif
	if ! exists('b:wheel_selected')
		let b:wheel_selected = []
	endif
endfun

" Maximum stack size

fun! wheel#layer#truncate ()
	" Truncate layer stack
	let maxim = g:wheel_config.maxim.layers - 1
	let stack = b:wheel_stack
	for field in s:layer_stack_fields
		let stack[field] = stack[field][:maxim]
	endfor
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
	" Truncate the stack to max size
	call wheel#layer#truncate ()
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

fun! wheel#layer#push (mandala_type)
	" Push buffer content to the stack
	" Save modified local maps
	call wheel#layer#init ()
	let stack = b:wheel_stack
	" Pseudo filename
	let filename = stack.filename
	call insert(filename, expand('%'))
	" Local options
	let opts = stack.opts
	let ampersands = wheel#layer#save_options ()
	call insert(opts, ampersands)
	" lines content, without filtering
	let lines = stack.lines
	if empty(b:wheel_lines)
		let buflines = getline(2, '$')
	else
		let buflines = b:wheel_lines
	endif
	call insert(lines, buflines)
	" filtered content
	let filtered = stack.filtered
	let now = getline(1, '$')
	call insert(filtered, now)
	" Cursor position
	let position = stack.position
	call insert(position, getcurpos())
	" Selected lines
	let selected = stack.selected
	if empty(b:wheel_selected)
		let address = wheel#line#address()
		echomsg 'address :' address
		let b:wheel_selected = [address]
	endif
	call insert(selected, b:wheel_selected)
	" Buffer settings
	let settings = stack.settings
	if exists('b:wheel_settings')
		call insert(settings, b:wheel_settings)
	else
		call insert(settings, {})
	endif
	" Buffer mappings
	let mappings = stack.mappings
	let mapdict = wheel#layer#save_maps ()
	call insert(mappings, mapdict)
endfun

fun! wheel#layer#pop ()
	" Pop buffer content from the stack
	" Restore modified local maps
	if ! exists('b:wheel_stack')
		return
	endif
	let stack = b:wheel_stack
	" Pseudo filename
	let filename = stack.filename
	if empty(filename) || empty(filename[0])
		echomsg 'wheel layer pop : empty stack.'
		return
	endif
	let pseudo_file = wheel#chain#pop (filename)
	exe 'silent file' pseudo_file
	" Local options
	let opts = stack.opts
	let ampersands = wheel#chain#pop (opts)
	call wheel#layer#restore_options (ampersands)
	" lines mandala content, without filtering
	let lines = stack.lines
	let b:wheel_lines = wheel#chain#pop (lines)
	" filtered mandala content
	let filtered = stack.filtered
	let now = wheel#chain#pop (filtered)
	call wheel#mandala#replace (now, 'delete')
	" Restore cursor position
	let position = stack.position
	let pos = wheel#chain#pop (position)
	call wheel#gear#restore_cursor (pos)
	" Restore settings
	let settings = stack.settings
	let b:wheel_settings = wheel#chain#pop (settings)
	" Restore mappings
	let mappings = stack.mappings
	let mapdict = wheel#chain#pop(mappings)
	call wheel#layer#restore_maps (mapdict)
	" Restore selection
	let selected = stack.selected
	let b:wheel_selected = wheel#chain#pop(selected)
	" Empty selection if only one element
	if len(b:wheel_selected) == 1
		call wheel#line#deselect ()
	endif
	" Tell (n)vim the buffer is to be considered not modified
	setlocal nomodified
endfun
