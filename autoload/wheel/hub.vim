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
				\ 'Rename torus' : "wheel#tree#rename('torus')",
				\ 'Rename circle' : "wheel#tree#rename('circle')",
				\ 'Rename location' : "wheel#tree#rename('location')",
				\ 'Rename file' : 'wheel#tree#rename_file',
				\}
	lockvar s:rename
endif

if ! exists('s:delete')
	let s:delete = {
				\ 'Delete torus' : "wheel#tree#delete('torus')",
				\ 'Delete circle' : "wheel#tree#delete('circle')",
				\ 'Delete location' : "wheel#tree#delete('location')",
				\}
	lockvar s:delete
endif

if ! exists('s:jump')
	let s:jump = {
				\ 'Jump to torus' : "wheel#mandala#jump('torus')",
				\ 'Jump to circle' : "wheel#mandala#jump('circle')",
				\ 'Jump to location' : "wheel#mandala#jump('location')",
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
				\ 'Display toruses on tabs' : "wheel#mosaic#tabs('torus')",
				\ 'Display circles on tabs' : "wheel#mosaic#tabs('circle')",
				\ 'Display locations on tabs' : "wheel#mosaic#tabs('location')",
				\}
	lockvar s:tabwin
endif

if ! exists('s:reorder')
	let s:reorder = {
				\ 'Reorder toruses' : "wheel#mandala#reorder('torus')",
				\ 'Reorder circles' : "wheel#mandala#reorder('circle')",
				\ 'Reorder locations' : "wheel#mandala#reorder('location')",
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
				\ 'Add menu' : "wheel#hub#('add')",
				\ 'Rename menu' : "wheel#hub#('rename')",
				\ 'Delete menu' : "wheel#hub#('delete')",
				\ 'Jump menu' : "wheel#hub#('jump')",
				\ 'Alternate menu' : "wheel#hub#('alternate')",
				\ 'Tabs & Windows menu' : "wheel#hub#('tabwin')",
				\ 'Reorder menu' : "wheel#hub#('reorder')",
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
	let value = s:all[key]
	call wheel#mandala#close ()
	if value =~ ')'
		exe 'call ' . value
	else
		exe 'call ' . value . '()'
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
