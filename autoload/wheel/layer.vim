" vim: ft=vim fdm=indent:

fun! wheel#layer#push ()
	" Push buffer content to the stack
	" Save modified local maps
	if ! exists('b:wheel_stack')
		let b:wheel_stack = {}
		let b:wheel_stack.contents = []
		let b:wheel_stack.selected = []
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
	if ! empty(contents)
		let lines = wheel#chain#pop (contents)
	endif
	call wheel#mandala#replace (lines)
	" Restore mappings
	let mappings = b:wheel_stack.mappings
	if ! empty(mappings)
		let mapdict = wheel#chain#pop (mappings)
		if ! empty(maparg('<cr>', 'n'))
			nunmap <buffer> <cr>
		endif
		if ! empty(maparg('g<cr>', 'n'))
			nunmap <buffer> g<cr>
		endif
		exe 'nnoremap <buffer> <cr> ' . mapdict.enter
		exe 'nnoremap <buffer> g<cr> ' . mapdict.g_enter
	endif
endfun

fun! wheel#layer#call (conf)
	" Calls function corresponding to menu line
	" conf is a dictionary, whose keys can be :
	" - menu : name of a menu variable in storage.vim
	" - close : whether to close wheel buffer
	" - travel : whether to apply action in previous buffer
	let conf = a:conf
	let menu = wheel#storage#fetch (conf.menu)
	let key = getline('.')
	if conf.close
		call wheel#mandala#close ()
	elseif conf.travel
		let mandala = win_getid()
		wincmd p
	endif
	let value = menu[key]
	if value =~ '\m)'
		exe 'call ' . value
	else
		call {value}()
	endif
	if ! conf.close && conf.travel
		call win_gotoid(mandala)
	endif
endfun

fun! wheel#layer#floor (dictname)
	" Replace buffer content by a new layer
	" Reuse current wheel buffer
	let dictname = a:dictname
	call wheel#layer#push ()
	let dict = wheel#storage#fetch (dictname)
	let menu = sort(keys(dict))
	call wheel#mandala#replace (menu)
	call wheel#line#sync_select ()
	nnoremap <buffer> <backspace> :call wheel#layer#pop ()<cr>
endfun
