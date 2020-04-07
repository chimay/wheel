" vim: ft=vim fdm=indent:

" Menus

if ! exists('s:add')
	let s:add = {
				\ 'Add a new torus' : 'wheel#tree#add_torus',
				\ 'Add a new circle' : 'wheel#tree#add_circle',
				\ 'Add here as new location' : 'wheel#tree#add_here',
				\ 'Add a new file' : 'wheel#tree#add_file',
				\ 'Add a new buffer' : 'wheel#tree#add_buffer',
				\}
	lockvar s:add
endif

if ! exists('s:rename')
	let s:rename = {
				\ 'Rename torus' : 'wheel#tree#rename_torus',
				\ 'Rename circle' : 'wheel#tree#rename_circle',
				\ 'Rename location' : 'wheel#tree#rename_location',
				\ 'Rename file' : 'wheel#tree#rename_file',
				\}
	lockvar s:rename
endif

if ! exists('s:delete')
	let s:delete = {
				\ 'Delete torus' : 'wheel#tree#delete_torus',
				\ 'Delete circle' : 'wheel#tree#delete_circle',
				\ 'Delete location' : 'wheel#tree#delete_location',
				\}
	lockvar s:delete
endif

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

if ! exists('s:alternate')
	let s:alternate = {
				\ 'Alternate' : 'wheel#pendulum#alternate',
				\ 'Alternate in same torus' : 'wheel#pendulum#alternate_same_torus',
				\ 'Alternate in same circle' : 'wheel#pendulum#alternate_same_circle',
				\ 'Alternate in other torus' : 'wheel#pendulum#alternate_other_torus',
				\ 'Alternate in other circle' : 'wheel#pendulum#alternate_other_circle',
				\ 'Alternate in same torus, other circle' : 'wheel#pendulum#alternate_same_torus_other_circle',
				\}
	lockvar s:alternate
endif

if ! exists('s:tabwin')
	let s:tabwin = {
				\ 'One torus per tab' : "wheel#mosaictabs('torus')",
				\ 'One circle per tab' : "wheel#mosaictabs('circle')",
				\ 'One location per tab' : "wheel#mosaictabs('location')",
				\}
	lockvar s:tabwin
endif

if ! exists('s:reorder')
	let s:reorder = {
				\ 'Reorder toruses' : 'wheel#mandala#reorder_toruses',
				\ 'Reorder circles' : 'wheel#mandala#reorder_circles',
				\ 'Reorder locations' : 'wheel#mandala#reorder_locations',
				\}
	lockvar s:reorder
endif

if ! exists('s:main')
	let s:main = {}
	call extend(s:main, s:add)
	call extend(s:main, s:rename)
	call extend(s:main, s:delete)
	call extend(s:main, s:jump)
	call extend(s:main, s:alternate)
	call extend(s:main, s:tabwin)
	call extend(s:main, s:reorder)
	lockvar s:main
endif

if ! exists('s:meta')
	let s:meta = {
				\ 'Add menu' : 'wheel#hub#add',
				\ 'Rename menu' : 'wheel#hub#rename',
				\ 'Delete menu' : 'wheel#hub#delete',
				\ 'Jump menu' : 'wheel#hub#jump',
				\ 'Alternate menu' : 'wheel#hub#alternate',
				\ 'Reorder menu' : 'wheel#hub#reorder',
				\}
	lockvar s:meta
endif

if ! exists('s:all')
	let s:all = copy(s:main)
	call extend(s:all, s:meta)
	lockvar s:all
endif

" Helpers

fun! wheel#hub#call ()
	" Calls function corresponding to current menu line
	let key = getline('.')
	call wheel#mandala#close ()
	if key =~ ')'
		exe 'call ' . s:all[key]
	else
		exe 'call ' . s:all[key] . '()'
	endif
endfun

" Buffer menus

fun! wheel#hub#menu (pointer)
	" Hub menu in wheel buffer
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

fun! wheel#hub#main ()
	" Main hub menu in wheel buffer
	call wheel#hub#menu('s:main')
endfun

fun! wheel#hub#add ()
	" Jump hub menu in wheel buffer
	call wheel#hub#menu('s:add')
endfun

fun! wheel#hub#rename ()
	" Jump hub menu in wheel buffer
	call wheel#hub#menu('s:rename')
endfun

fun! wheel#hub#delete ()
	" Jump hub menu in wheel buffer
	call wheel#hub#menu('s:delete')
endfun

fun! wheel#hub#jump ()
	" Jump hub menu in wheel buffer
	call wheel#hub#menu('s:jump')
endfun

fun! wheel#hub#alternate ()
	" alternate hub menu in wheel buffer
	call wheel#hub#menu('s:alternate')
endfun

fun! wheel#hub#reorder ()
	" Reorder hub menu in wheel buffer
	call wheel#hub#menu('s:reorder')
endfun
