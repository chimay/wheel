" vim: ft=vim fdm=indent:

" Layers stack on mandala buffer

" Stack

fun! wheel#layer#init ()
	" Init stack
	" Last inserted layer is at index 0
	if ! exists('b:wheel_stack')
		let b:wheel_stack = {}
		" Full mandala content, without filtering
		let b:wheel_stack.full = []
		" Current mandala content
		let b:wheel_stack.current = []
		" Cursor position
		let b:wheel_stack.positions = []
		" Selected lines
		let b:wheel_stack.selected = []
		" Buffer settings
		let b:wheel_stack.settings = []
		" Buffer mappings
		let b:wheel_stack.mappings = []
	endif
endfun

" Maximum stack size

fun! wheel#layer#truncate ()
	" Truncate layer stack
	let maxim = g:wheel_config.maxim.layers - 1
	let stack = b:wheel_stack
	let stack.full = stack.full[:maxim]
	let stack.current = stack.current[:maxim]
	let stack.positions = stack.positions[:maxim]
	let stack.selected = stack.selected[:maxim]
	let stack.settings = stack.settings[:maxim]
	let stack.mappings = stack.mappings[:maxim]
 endfun

" Clearing things

fun! wheel#layer#clear_vars ()
	" Clear mandala variables
	let varlist = [
				\ 'b:wheel_lines',
				\ 'b:wheel_selected',
				\ ]
	call wheel#gear#unlet(varlist)
endfun

fun! wheel#layer#clear_maps ()
	" Clear mandala maps
	" normal maps
	let normal_keys = [
				\ 'q',
				\ 'j', 'k', '<down>', '<up>',
				\ 'i', 'a',
				\ '<cr>', '<space>', '<tab>',
				\ 't', 's', 'v',
				\ 'S', 'V',
				\ 'g<cr>',
				\ 'gt', 'gs', 'gv',
				\ 'gS', 'gV',
				\ 'p', 'P',
				\ 'gp', 'gP',
				\ 'u', '<c-r>',
				\ ]
	call wheel#gear#unmap(normal_keys, 'n')
	" insert maps
	let insert_keys = [
				\ '<space>', '<c-w>', '<c-u>',
				\ '<esc>', '<cr>',
				\ '<up>', '<down>', '<m-p>', '<m-n>',
				\ '<pageup>', '<pagedown>', '<m-r>', '<m-s>',
				\ ]
	call wheel#gear#unmap(insert_keys, 'i')
endfun

fun! wheel#layer#fresh ()
	" Fresh empty layer : clear mandala lines, vars & maps
	call wheel#layer#clear_vars ()
	call wheel#layer#clear_maps ()
	" Delete lines -> no storing register
	1,$ delete _
	" Truncate the stack to max size
	call wheel#layer#truncate ()
endfun

" Restoring things

fun! wheel#layer#restore_maps (mapdict)
	" Restore maps
	let mapdict = a:mapdict
	if ! empty(mapdict)
		if ! empty(mapdict.enter)
			exe 'nnoremap <buffer> <cr>' mapdict.enter
		endif
		if ! empty(mapdict.g_enter)
			exe 'nnoremap <buffer> g<cr>' mapdict.g_enter
		endif
		if ! empty(mapdict.space)
			exe 'nnoremap <buffer> <space>' mapdict.space
		elseif ! empty(mapdict.enter)
			" if no space map, set it to the same as enter
			exe 'nnoremap <buffer> <space>' mapdict.enter
		endif
		if ! empty(mapdict.tab)
			exe 'nnoremap <buffer> <tab>' mapdict.tab
		elseif ! empty(mapdict.enter)
			" if no tab map, set it to the same as enter
			exe 'nnoremap <buffer> <tab>' mapdict.enter
		endif
	endif
endfun

" Push & pop to stack

fun! wheel#layer#push ()
	" Push buffer content to the stack
	" Save modified local maps
	call wheel#layer#init ()
	let stack = b:wheel_stack
	" Full content, without filtering
	let full = stack.full
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let lines = getline(2, '$')
	else
		let lines = b:wheel_lines
	endif
	call insert(full, lines)
	" Current content
	let current = stack.current
	let now = getline(1, '$')
	call insert(current, now)
	" Cursor position
	let positions = stack.positions
	call insert(positions, getcurpos())
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
	let enter = maparg('<enter>', 'n')
	let g_enter = maparg('g<enter>', 'n')
	let space = maparg('<space>', 'n')
	let tab = maparg('<tab>', 'n')
	let mapdict = {
				\ 'enter': enter,
				\ 'g_enter': g_enter,
				\ 'space' : space,
				\ 'tab' : tab,
				\}
	call insert(mappings, mapdict)
	" Reset buffer variables
	" Fresh filter and so on
	call wheel#layer#clear_vars()
endfun

fun! wheel#layer#pop ()
	" Pop buffer content from the stack
	" Restore modified local maps
	if ! exists('b:wheel_stack')
		return
	endif
	let stack = b:wheel_stack
	" Full mandala content, without filtering
	let full = stack.full
	if empty(full) || empty(full[0])
		echomsg 'wheel layer pop : empty stack.'
		return
	endif
	let b:wheel_lines = wheel#chain#pop (full)
	" Current mandala content
	let current = stack.current
	let now = wheel#chain#pop (current)
	call wheel#mandala#replace (now, 'delete')
	" Restore cursor position
	let positions = stack.positions
	let pos = wheel#chain#pop (positions)
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
endfun
