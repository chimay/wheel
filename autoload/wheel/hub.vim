" vim: ft=vim fdm=indent:

" Menus

if ! exists('s:jump')
	let s:jump = {
				\ 'Jump to torus' : 'wheel#mandala#toruses',
				\ 'Jump to circle' : 'wheel#mandala#circles',
				\ 'Jump to location' : 'wheel#mandala#locations',
				\ 'Jump to location in index' : 'wheel#mandala#helix',
				\ 'Jump to circle in index' : 'wheel#mandala#grid',
				\ 'Jump to element in wheel tree' : 'wheel#mandala#tree',
				\ 'Jump to location in history' : 'wheel#mandala#history',
				\}
	lockvar s:jump
endif

if ! exists('s:reorder')
	let s:reorder = {
				\ 'Reorder toruses' : 'wheel#mandala#reorder_toruses',
				\ 'Reorder circles' : 'wheel#mandala#reorder_circles',
				\ 'Reorder locations' : 'wheel#mandala#reorder_locations',
				\}
	lockvar s:reorder
endif

if ! exists('s:meta')
	let s:meta = copy(s:jump)
	call extend(s:meta, s:reorder)
	lockvar s:meta
endif

" Helpers

fun! wheel#hub#call ()
	" Calls s:meta[key]
	let key = getline('.')
	call wheel#mandala#close ()
	exe 'call ' . s:meta[key] . '()'
endfun

" Menus

fun! wheel#hub#menu (pointer)
	" Meta hub menu in wheel buffer
	let string = 'wheel-menu-' . a:pointer
	call wheel#mandala#open (string)
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
	nnoremap <buffer> <cr> :call wheel#hub#call()<cr>
	let menu = sort(keys({a:pointer}))
	call append('.', menu)
endfun

fun! wheel#hub#meta ()
	" Meta hub menu in wheel buffer
	call wheel#hub#menu('s:meta')
endfun

fun! wheel#hub#choose ()
	" Jump hub menu in wheel buffer
	call wheel#hub#menu('s:jump')
endfun

fun! wheel#hub#reorder ()
endfun
