" vim: ft=vim fdm=indent:

" Layers stack on wheel buffers

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#glyph#fetch('selected/mark')
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#glyph#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

" Stack

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
	let stack = b:wheel_stack
	" Selected lines
	let selected = stack.selected
	if ! exists('b:wheel_selected') || empty(b:wheel_selected)
		call wheel#line#toggle ()
	endif
	call insert(selected, b:wheel_selected)
	" Content stack
	let contents = stack.contents
	if ! exists('b:wheel_lines') || empty(b:wheel_lines)
		let lines = getline(1, '$')
	else
		let lines = b:wheel_lines
	endif
	call insert(contents, lines)
	" Buffer settings
	let settings = stack.settings
	if exists('b:wheel_settings')
		call insert(settings, b:wheel_settings)
	else
		call insert(settings, {})
	endif
	" Map stack
	let mappings = stack.mappings
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
	let stack = b:wheel_stack
	" Restore content
	let contents = stack.contents
	if empty(contents)
		return
	endif
	let lines = wheel#chain#pop (contents)
	call wheel#mandala#replace (lines)
	let b:wheel_lines = lines
	" Restore settings
	let settings = stack.settings
	let b:wheel_settings = wheel#chain#pop (settings)
	" Restore mappings
	let mappings = stack.mappings
	if ! empty(mappings)
		let mapdict = wheel#chain#pop (mappings)
		exe 'nnoremap <buffer> <cr> ' . mapdict.enter
		exe 'nnoremap <buffer> g<cr> ' . mapdict.g_enter
	endif
	" Restore selection
	let selected = stack.selected
	let b:wheel_selected = wheel#chain#pop(selected)
	call wheel#line#sync_select ()
endfun

fun! wheel#layer#call (settings)
	" Calls function corresponding to menu line
	" settings is a dictionary, whose keys can be :
	" - menu : name of a menu variable in storage.vim
	" - close : whether to close wheel buffer
	" - travel : whether to apply action in previous buffer
	" - deselect : whether to deselect all line before calling function
	let settings = a:settings
	let menu = wheel#glyph#fetch (settings.menu)
	let close = settings.close
	let travel = settings.travel
	" Deselect
	if settings.deselect
		let position = getcurpos()
		call wheel#line#deselect ()
		call setpos('.', position)
	endif
	" Cursor line
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	let key = cursor_line
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

fun! wheel#layer#overlay (settings)
	" Define local maps for overlay
	let settings = a:settings
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#layer#call('
	let post = ')<cr>'
	let settings.close = 1
	exe map . '<cr>' . pre . string(settings) . post
	let settings.close = 0
	exe map . 'g<cr>' . pre . string(settings) . post
	exe map . '<space>' . pre . string(settings) . post
	" Go back
	nnoremap <buffer> <backspace> :call wheel#layer#pop ()<cr>
endfun

fun! wheel#layer#staircase (settings)
	" Replace buffer content by a new layer
	" Reuse current wheel buffer
	" Define menu maps
	let settings = a:settings
	let dictname = settings.menu
	call wheel#layer#push ()
	let dict = wheel#glyph#fetch (dictname)
	let menu = sort(keys(dict))
	call wheel#mandala#replace (menu)
	call wheel#layer#overlay (settings)
	let b:wheel_settings = settings
endfun
