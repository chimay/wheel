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

if ! exists('s:switch')
	let s:switch = {
				\ 'Switch to torus' : "wheel#mandala#switch('torus')",
				\ 'Switch to circle' : "wheel#mandala#switch('circle')",
				\ 'Switch to location' : "wheel#mandala#switch('location')",
				\ 'Switch to location in index' : 'wheel#mandala#helix',
				\ 'Switch to circle in index' : 'wheel#mandala#grid',
				\ 'Switch to element in wheel tree' : 'wheel#mandala#tree',
				\ 'Switch to location in history' : 'wheel#mandala#history',
				\}
	lockvar s:switch
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
				\ 'Display toruses on horizontal splits' : "wheel#mosaic#hor_split('torus')",
				\ 'Display circles on horizontal splits' : "wheel#mosaic#hor_split('circle')",
				\ 'Display locations on horizontal splits' : "wheel#mosaic#hor_split('location')",
				\ 'Display toruses on vertical splits' : "wheel#mosaic#ver_split('torus')",
				\ 'Display circles on vertical splits' : "wheel#mosaic#ver_split('circle')",
				\ 'Display locations on vertical splits' : "wheel#mosaic#ver_split('location')",
				\ 'Mix : toruses on tabs and circles on splits' : "wheel#pyramid#steps('torus')",
				\ 'Mix : circles on tabs and locations on splits' : "wheel#pyramid#steps('circle')",
				\}
	lockvar s:tabwin
endif

if ! exists('s:reorganize')
	let s:reorder = {
				\ 'Reorder toruses' : "wheel#mandala#reorder('torus')",
				\ 'Reorder circles' : "wheel#mandala#reorder('circle')",
				\ 'Reorder locations' : "wheel#mandala#reorder('location')",
				\ 'Reorganize wheel' : 'wheel#mandala#reorganize',
				\}
	lockvar s:reorder
endif

" Main menu

if ! exists('s:main')
	let s:main = {}
	call extend(s:main, s:add)
	call extend(s:main, s:rename)
	call extend(s:main, s:delete)
	call extend(s:main, s:switch)
	call extend(s:main, s:alternate)
	call extend(s:main, s:tabwin)
	call extend(s:main, s:reorganize)
	lockvar s:main
endif

" Meta menu

if ! exists('s:meta')
	let s:meta = {
				\ 'Add menu' : "wheel#hub#menu('s:add')",
				\ 'Rename menu' : "wheel#hub#menu('s:rename')",
				\ 'Delete menu' : "wheel#hub#menu('s:delete')",
				\ 'Switch menu' : "wheel#hub#menu('s:switch')",
				\ 'Alternate menu' : "wheel#hub#menu('s:alternate')",
				\ 'Tabs & Windows menu' : "wheel#hub#menu('s:tabwin')",
				\ 'Reorganize menu' : "wheel#hub#menu('s:reorganize')",
				\}
	lockvar s:meta
endif

" All

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
	if value =~ '\m)'
		exe 'call ' . value
	else
		exe 'call ' . value . '()'
	endif
endfun

" Buffer menus

fun! wheel#hub#menu (pointer)
	" Hub menu in wheel buffer
	let type = substitute(a:pointer, 's:', '', '')
	let string = 'wheel-menu-' . type
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
