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
	call wheel#line#sync_select ()
	" Restore mappings
	let mappings = b:wheel_stack.mappings
	if ! empty(mappings)
		let mapdict = wheel#chain#pop (mappings)
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
	let menu = wheel#glyph#fetch (conf.menu)
	let close = conf.close
	let travel = conf.travel
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

fun! wheel#layer#door_maps (dictname)
	" Define local maps for first layer
	nnoremap <buffer> <tab> :call wheel#layer#staircase (dictname)
endfun

fun! wheel#layer#roof_maps (dictname)
	" Define local maps for second layer
	let dictname = a:dictname
	let conf = {'menu' : dictname, 'close' : 1, 'travel' : 1}
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#layer#call('
	let post = ')<cr>'
	exe map . '<cr>' . pre . string(conf) . post
	let conf.close = 0
	exe map . 'g<cr>' . pre . string(conf) . post
	exe map . '<space>' . pre . string(conf) . post
	let conf.travel = 0
	exe map . '<tab>' . pre . string(conf) . post
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
	call wheel#layer#roof_maps (dictname)
	nnoremap <buffer> <backspace> :call wheel#layer#pop ()<cr>
endfun
