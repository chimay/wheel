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
				\ 'Switch to most recently used file (mru)' : 'wheel#mandala#attic',
				\ 'Switch to result of locate search' : 'wheel#mandala#locate',
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

if ! exists('s:tabs')
	let s:tabs = {
				\ 'Toruses on tabs' : "wheel#mosaic#tabs('torus')",
				\ 'Circles on tabs' : "wheel#mosaic#tabs('circle')",
				\ 'Locations on tabs' : "wheel#mosaic#tabs('location')",
				\}
	lockvar s:tabs
endif

if ! exists('s:windows')
	let s:windows = {
				\ 'Toruses on horizontal splits' : "wheel#mosaic#split('torus')",
				\ 'Circles on horizontal splits' : "wheel#mosaic#split('circle')",
				\ 'Locations on horizontal splits' : "wheel#mosaic#split('location')",
				\ 'Toruses on vertical splits' : "wheel#mosaic#split('torus', 'vertical')",
				\ 'Circles on vertical splits' : "wheel#mosaic#split('circle', 'vertical')",
				\ 'Locations on vertical splits' : "wheel#mosaic#split('location', 'vertical')",
				\ 'Toruses on splits, main left layout' : "wheel#mosaic#split('torus', 'main_left')",
				\ 'Circles on splits, main left layout' : "wheel#mosaic#split('circle', 'main_left')",
				\ 'Locations on splits, main left layout' : "wheel#mosaic#split('location', 'main_left')",
				\ 'Toruses on splits, main top layout' : "wheel#mosaic#split('torus', 'main_top')",
				\ 'Circles on splits, main top layout' : "wheel#mosaic#split('circle', 'main_top')",
				\ 'Locations on splits, main top layout' : "wheel#mosaic#split('location', 'main_top')",
				\ 'Toruses on splits, golden horizontal' : "wheel#mosaic#golden('torus', 'horizontal')",
				\ 'Circles on splits, golden horizontal' : "wheel#mosaic#golden('circle', 'horizontal')",
				\ 'Locations on splits, golden horizontal' : "wheel#mosaic#golden('location', 'horizontal')",
				\ 'Toruses on splits, golden vertical' : "wheel#mosaic#golden('torus', 'vertical')",
				\ 'Circles on splits, golden vertical' : "wheel#mosaic#golden('circle', 'vertical')",
				\ 'Locations on splits, golden vertical' : "wheel#mosaic#golden('location', 'vertical')",
				\ 'Toruses on splits, golden left layout' : "wheel#mosaic#golden('torus', 'main_left')",
				\ 'Circles on splits, golden left layout' : "wheel#mosaic#golden('circle', 'main_left')",
				\ 'Locations on splits, golden left layout' : "wheel#mosaic#golden('location', 'main_left')",
				\ 'Toruses on splits, golden top layout' : "wheel#mosaic#golden('torus', 'main_top')",
				\ 'Circles on splits, golden top layout' : "wheel#mosaic#golden('circle', 'main_top')",
				\ 'Locations on splits, golden top layout' : "wheel#mosaic#golden('location', 'main_top')",
				\ 'Toruses on splits, grid layout' : "wheel#mosaic#split_grid('torus')",
				\ 'Circles on splits, grid layout' : "wheel#mosaic#split_grid('circle')",
				\ 'Locations on splits, grid layout' : "wheel#mosaic#split_grid('location')",
				\ 'Toruses on splits, transposed grid layout' : "wheel#mosaic#split_transposed_grid('torus')",
				\ 'Circles on splits, transposed grid layout' : "wheel#mosaic#split_transposed_grid('circle')",
				\ 'Locations on splits, transposed grid layout' : "wheel#mosaic#split_transposed_grid('location')",
				\ 'Rotate windows clockwise' : 'wheel#mosaic#rotate_clockwise()',
				\ 'Rotate windows counter-clockwise' : 'wheel#mosaic#rotate_counter_clockwise()',
				\}
	lockvar s:windows
endif

if ! exists('s:tabnwin')
	let s:tabnwin = {
				\ 'Mix : toruses on tabs & circles on splits' : "wheel#pyramid#steps('torus')",
				\ 'Mix : circles on tabs & locations on splits' : "wheel#pyramid#steps('circle')",
				\ 'Zoom : one tab, one window' : 'wheel#mosaic#zoom()',
				\}
	lockvar s:tabnwin
endif

if ! exists('s:reorganize')
	let s:reorganize = {
				\ 'Reorder toruses' : "wheel#mandala#reorder('torus')",
				\ 'Reorder circles' : "wheel#mandala#reorder('circle')",
				\ 'Reorder locations' : "wheel#mandala#reorder('location')",
				\ 'Reorganize wheel' : 'wheel#mandala#reorganize',
				\}
	lockvar s:reorganize
endif

if ! exists('s:search')
	let s:search = {
				\ 'Search in circle files' : 'wheel#mandala#grep()',
				\ 'Outline : folds headers in circle files' : 'wheel#mandala#outline()',
				\}
	lockvar s:search
endif

if ! exists('s:yank')
	let s:yank = {
				\ 'Yank wheel in list mode' : "wheel#mandala#yank('list')",
				\ 'Yank wheel in plain mode' : "wheel#mandala#yank('plain')",
				\}
	lockvar s:yank
endif

" Main menu

if ! exists('s:main')
	let s:main = {}
	call extend(s:main, s:add)
	call extend(s:main, s:rename)
	call extend(s:main, s:delete)
	call extend(s:main, s:switch)
	call extend(s:main, s:alternate)
	call extend(s:main, s:tabs)
	call extend(s:main, s:windows)
	call extend(s:main, s:tabnwin)
	call extend(s:main, s:reorganize)
	call extend(s:main, s:search)
	call extend(s:main, s:yank)
	lockvar s:main
endif

" Meta menu

if ! exists('s:meta')
	let s:meta = {
				\ 'Add' : "wheel#hub#menu('s:add')",
				\ 'Rename' : "wheel#hub#menu('s:rename')",
				\ 'Delete' : "wheel#hub#menu('s:delete')",
				\ 'Switch' : "wheel#hub#menu('s:switch')",
				\ 'Alternate' : "wheel#hub#menu('s:alternate')",
				\ 'Tabs' : "wheel#hub#menu('s:tabs')",
				\ 'Window layouts' : "wheel#hub#menu('s:windows')",
				\ 'Mix of tabs & windows' : "wheel#hub#menu('s:tabnwin')",
				\ 'Reorganize' : "wheel#hub#menu('s:reorganize')",
				\ 'Search in files' : "wheel#hub#menu('s:search')",
				\ 'Yank' : "wheel#hub#menu('s:yank')",
				\}
	lockvar s:meta
endif

" All menus keys & values : main & meta

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
	call wheel#mandala#template ()
	nnoremap <buffer> <cr> :call wheel#hub#call()<cr>
	let menu = sort(keys({a:pointer}))
	call wheel#mandala#fill(menu)
endfun

fun! wheel#hub#meta ()
	" Meta hub menu in wheel buffer
	call wheel#hub#menu('s:meta')
endfun

fun! wheel#hub#main ()
	" Main hub menu in wheel buffer
	call wheel#hub#menu('s:main')
endfun
