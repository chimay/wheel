" vim: set ft=vim fdm=indent iskeyword&:

" Menu layer

" Script constants

if ! exists('s:selected_mark')
	let s:selected_mark = wheel#crystal#fetch('selected/mark')
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = wheel#crystal#fetch('selected/pattern')
	lockvar s:selected_pattern
endif

" Functions

fun! wheel#tower#maps (settings)
	" Define local maps for overlay
	let settings = copy(a:settings)
	call wheel#mandala#template ()
	" Menu specific maps
	let map = 'nnoremap <silent> <buffer> '
	let pre = ' :call wheel#loop#context_menu('
	let post = ')<cr>'
	" Open / Close : default in settings
	exe map .. '<cr>' .. pre .. string(settings) .. post
	exe map .. '<tab>' .. pre .. string(settings) .. post
	" Leave the mandala Open
	let settings.close = v:false
	exe map .. 'g<cr>' .. pre .. string(settings) .. post
	exe map .. '<space>' .. pre .. string(settings) .. post
endfun

fun! wheel#tower#staircase (settings)
	" Replace buffer content by a {line -> fun} layer
	" Reuse current mandala buffer
	" Define dict maps
	let settings = a:settings
	let dictname = settings.linefun
	call wheel#book#fresh ()
	let items = wheel#crystal#fetch (dictname)
	let lines = wheel#matrix#items2keys (items)
	call wheel#mandala#filename (dictname)
	call wheel#mandala#replace (lines, 'blank')
	call wheel#tower#maps (settings)
	let b:wheel_settings = settings
	let b:wheel_lines = lines
	call cursor(1, 1)
	call wheel#book#syncup ()
	call wheel#status#leaf ()
endfun
