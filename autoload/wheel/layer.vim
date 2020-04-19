" vim: ft=vim fdm=indent:

fun! wheel#layer#push ()
	" Push buffer content to the stack
	" Save modified local maps
	if ! exists('b:wheel_stack')
		let b:wheel_stack = {}
		let b:wheel_stack.contents = []
		let b:wheel_stack.selected = []
		let b:wheel_stack.settings = []
		let b:wheel_stack.mappings = []
	endif
	" Content stack
	let contents = b:wheel_stack.contents
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let lines = getline(1, '$')
	else
		let lines = b:wheel_lines
	endif
	call insert(contents, lines)
	" Selected lines
	let selected = b:wheel_stack.selected
	if exists('b:wheel_selected')
		call insert(selected, b:wheel_selected)
	else
		call insert(selected, [wheel#line#coordin ()])
	endif
	" Buffer settings
	let settings = b:wheel_stack.settings
	if exists('b:wheel_settings')
		call insert(settings, b:wheel_settings)
	else
		call insert(settings, {})
	endif
	" Map stack
	let mappings = b:wheel_stack.mappings
	let enter = maparg('<enter>', 'n')
	let g_enter = maparg('g<enter>', 'n')
	let mapdict = {'enter': enter, 'g_enter': g_enter}
	call insert(mappings, mapdict)
	" Reset b:wheel_lines to filter the new content
	if exists('b:wheel_lines')
		unlet b:wheel_lines
	endif
endfun

fun! wheel#layer#pop ()
	" Pop buffer content from the stack
	" Restore modified local maps
	if ! exists('b:wheel_stack')
		return
	endif
	" Restore content
	let contents = b:wheel_stack.contents
	if empty(contents)
		return
	endif
	let lines = wheel#chain#pop (contents)
	call wheel#mandala#replace (lines)
	let b:wheel_lines = lines
	" Restore settings
	let settings = b:wheel_stack.settings
	let b:wheel_settings = wheel#chain#pop (settings)
	" Restore mappings
	let mappings = b:wheel_stack.mappings
	if ! empty(mappings)
		let mapdict = wheel#chain#pop (mappings)
		exe 'nnoremap <buffer> <cr> ' . mapdict.enter
		exe 'nnoremap <buffer> g<cr> ' . mapdict.g_enter
	endif
	" Don’t restore selection markers by default
endfun

fun! wheel#layer#call (settings)
	" Calls function corresponding to menu line
	" settings is a dictionary, whose keys can be :
	" - menu : name of a menu variable in storage.vim
	" - close : whether to close wheel buffer
	" - travel : whether to apply action in previous buffer
	let settings = a:settings
	let menu = wheel#glyph#fetch (settings.menu)
	let close = settings.close
	let travel = settings.travel
	let key = getline('.')
	if close
		call wheel#mandala#close ()
	elseif travel
		let mandala = win_getid()
		wincmd p
	endif
	let value = menu[key]
	if value =~ '\m)'
		exe 'call ' . value
	else
		call {value}()
	endif
	if ! close && travel
		call win_gotoid (mandala)
	endif
endfun

fun! wheel#layer#staircase (dictname)
	" Replace buffer content by a new layer
	" Reuse current wheel buffer
	" Define menu maps
	let dictname = a:dictname
	call wheel#layer#push ()
	let dict = wheel#glyph#fetch (dictname)
	let menu = sort(keys(dict))
	call wheel#mandala#replace (menu)
	nnoremap <buffer> <backspace> :call wheel#layer#pop ()<cr>
endfun
