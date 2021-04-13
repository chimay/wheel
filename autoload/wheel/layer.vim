" vim: ft=vim fdm=indent:

" Layers stack on mandala buffer

" Script vars

if ! exists('s:mandala_vars')
	let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
	lockvar s:mandala_vars
endif

if ! exists('s:stack_fields')
	let s:stack_fields = wheel#crystal#fetch('stack/fields')
	lockvar s:stack_fields
endif

if ! exists('s:normal_map_keys')
	let s:normal_map_keys = wheel#crystal#fetch('normal/map/keys')
	lockvar s:normal_map_keys
endif

if ! exists('s:insert_map_keys')
	let s:insert_map_keys = wheel#crystal#fetch('insert/map/keys')
	lockvar s:insert_map_keys
endif

" Init stack

fun! wheel#layer#init ()
	" Init stack
	" Last inserted layer is at index 0
	if ! exists('b:wheel_stack')
		let b:wheel_stack = {}
		for field in s:stack_fields
			let b:wheel_stack[field] = []
		endfor
	endif
endfun

" Maximum stack size

fun! wheel#layer#truncate ()
	" Truncate layer stack
	let maxim = g:wheel_config.maxim.layers - 1
	let stack = b:wheel_stack
	for field in s:stack_fields
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
	" Delete lines -> no storing register
	1,$ delete _
	" Truncate the stack to max size
	call wheel#layer#truncate ()
endfun

" Saving things

fun! wheel#layer#save_maps ()
	" Save maps
	let mapdict = { 'normal' : {}, 'insert' : {}}
	for key in s:normal_map_keys
		let mapdict.normal[key] = maparg(key, 'n')
	endfor
	for key in s:insert_map_keys
		let mapdict.insert[key] = maparg(key, 'i')
	endfor
	return mapdict
endfun

" Restoring things

fun! wheel#layer#restore_maps (mapdict)
	" Restore maps
	let mapdict = a:mapdict
	for key in keys(mapdict.normal)
		if ! empty(key)
			exe 'silent nnoremap <buffer>' key mapdict.normal[key]
		else
			exe 'silent nunmap <buffer>' key
		endif
	endfor
endfun

" Mandala pseudo folders

fun! wheel#layer#pseudo_folders (mandala_type)
	" Set filename to pseudo folders /wheel/<type>
	" Useful as information
	" We also need a name when writing, even with BufWriteCmd
	" Add unique buf id, so (n)vim does not complain about
	" existing filename
	let type = a:mandala_type
	let current = g:wheel_buffers.current
	let iden = g:wheel_buffers.iden[current]
	let pseudo_folders = '/wheel/' . iden . '/' . type
	exe 'silent file' pseudo_folders
	return pseudo_folders
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
	call wheel#layer#pseudo_folders (a:mandala_type)
	" Local options
	let opts = stack.opts
	let ampersands = {}
	let ampersands.buftype = &buftype
	call insert(opts, ampersands)
	" lines content, without filtering
	let lines = stack.lines
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
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
	if ! exists('b:wheel_selected') || empty(b:wheel_selected)
		let b:wheel_selected = [wheel#line#address()]
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
	" Map to go back
	nnoremap <buffer> <backspace> :call wheel#layer#pop ()<cr>
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
	let &buftype = ampersands.buftype
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
