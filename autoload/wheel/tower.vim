" vim: ft=vim fdm=indent:

" Menu layer

" Script vars

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#crystal#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

" Functions

fun! wheel#tower#call (settings)
	" Calls function whose value is given by the key on cursor line
	" settings is a dictionary, whose keys can be :
	" - dict : name of a dictionary variable in storage.vim
	" - close : whether to close wheel buffer
	" - travel : whether to apply action in previous buffer
	let settings = a:settings
	let dict = wheel#crystal#fetch (settings.linefun)
	let close = settings.close
	let travel = settings.travel
	" Cursor line
	let cursor_line = getline('.')
	let cursor_line = substitute(cursor_line, s:selected_pattern, '', '')
	if empty(cursor_line)
		echomsg 'Wheel layer call : you selected an empty line'
		return
	endif
	let key = cursor_line
	if ! has_key(dict, key)
		normal! zv
		echomsg 'Wheel layer call : key not found'
		return
	endif
	" Close & travel
	if close
		call wheel#mandala#close ()
	elseif travel
		let mandala = win_getid()
		wincmd p
	endif
	" Call
	let value = dict[key]
	if value =~ '\m)'
		exe 'call ' . value
	else
		call {value}()
	endif
	" Goto mandala if needed
	if ! close && travel
		call win_gotoid (mandala)
	endif
endfun

fun! wheel#tower#overlay (settings)
	" Define local maps for overlay
	let settings = a:settings
	let map  =  'nnoremap <buffer> '
	let pre  = ' :call wheel#tower#call('
	let post = ')<cr>'
	" Open / Close : default in settings
	exe map . '<cr>' . pre . string(settings) . post
	" Open
	let settings.close = 0
	exe map . 'g<cr>' . pre . string(settings) . post
	exe map . '<space>' . pre . string(settings) . post
	" Go back
	nnoremap <buffer> <backspace> :call wheel#layer#pop ()<cr>
endfun

fun! wheel#tower#staircase (settings)
	" Replace buffer content by a {line -> fun} layer
	" Reuse current wheel buffer
	" Define dict maps
	let settings = a:settings
	let dictname = settings.linefun
	call wheel#layer#push ()
	let dict = wheel#crystal#fetch (dictname)
	let lines = sort(keys(dict))
	call wheel#mandala#replace (lines, 'blank')
	call wheel#tower#overlay (settings)
	let b:wheel_settings = settings
	call cursor(1, 1)
endfun
