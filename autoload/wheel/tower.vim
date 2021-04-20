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

fun! wheel#tower#overlay (settings)
	" Define local maps for overlay
	let settings = copy(a:settings)
	call wheel#mandala#template ()
	" Menu specific maps
	let map  =  'nnoremap <silent> <buffer> '
	let pre  = ' :call wheel#line#menu('
	let post = ')<cr>'
	" Open / Close : default in settings
	exe map . '<cr>' . pre . string(settings) . post
	exe map . '<tab>' . pre . string(settings) . post
	" Leave the mandala Open
	let settings.close = v:false
	exe map . 'g<cr>' . pre . string(settings) . post
	exe map . '<space>' . pre . string(settings) . post
endfun

fun! wheel#tower#staircase (settings)
	" Replace buffer content by a {line -> fun} layer
	" Reuse current mandala buffer
	" Define dict maps
	let settings = a:settings
	let dictname = settings.linefun
	if ! wheel#mandala#is_empty ()
		call wheel#layer#push ()
		call wheel#layer#fresh ()
	endif
	call wheel#layer#init ()
	let dict = wheel#crystal#fetch (dictname)
	let lines = sort(keys(dict))
	call wheel#mandala#pseudo_filename (dictname)
	call wheel#mandala#replace (lines, 'blank')
	call wheel#tower#overlay (settings)
	let b:wheel_settings = settings
	let b:wheel_lines = lines
	call cursor(1, 1)
endfun
