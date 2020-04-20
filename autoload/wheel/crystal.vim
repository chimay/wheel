" vim: ft=vim fdm=indent:

" Internal Variables

" Wheel levels

if ! exists('s:referen_levels')
	if exists(':const')
		const s:referen_levels = ['wheel', 'torus', 'circle', 'location']
	else
		let s:referen_levels = ['wheel', 'torus', 'circle', 'location']
		lockvar s:referen_levels
	endif
endif

if ! exists('s:referen_coordin')
	let s:referen_coordin = [ 'torus', 'circle', 'location']
	lockvar s:referen_coordin
endif

if ! exists('s:referen_list_keys')
	let s:referen_list_keys =
				\{ 'wheel' : 'toruses',
				\ 'torus' : 'circles',
				\ 'circle' : 'locations'}
	lockvar s:referen_list_keys
endif

" Golden ratio

if ! exists('s:golden_ratio')
	let s:golden_ratio = (1 + sqrt(5)) / 2
	lockvar s:golden_ratio
endif

" Patterns

if ! exists('s:selected_mark')
	let s:selected_mark = '* '
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = '\m^\* '
	lockvar s:selected_pattern
endif

" Menus

if ! exists('s:menu_add')
	let s:menu_add = {
				\ 'Add a new torus' : 'wheel#tree#add_torus',
				\ 'Add a new circle' : 'wheel#tree#add_circle',
				\ 'Add here as new location' : 'wheel#tree#add_here',
				\ 'Add a new file' : 'wheel#tree#add_file',
				\ 'Add a new buffer' : 'wheel#tree#add_buffer',
				\}
	lockvar s:menu_add
endif

if ! exists('s:menu_rename')
	let s:menu_rename = {
				\ 'Rename torus' : "wheel#tree#rename('torus')",
				\ 'Rename circle' : "wheel#tree#rename('circle')",
				\ 'Rename location' : "wheel#tree#rename('location')",
				\ 'Rename file' : 'wheel#tree#rename_file',
				\}
	lockvar s:menu_rename
endif

if ! exists('s:menu_delete')
	let s:menu_delete = {
				\ 'Delete torus' : "wheel#tree#delete('torus')",
				\ 'Delete circle' : "wheel#tree#delete('circle')",
				\ 'Delete location' : "wheel#tree#delete('location')",
				\}
	lockvar s:menu_delete
endif

if ! exists('s:menu_switch')
	let s:menu_switch = {
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
	lockvar s:menu_switch
endif

if ! exists('s:menu_alternate')
	let s:menu_alternate = {
				\ 'Alternate anywhere' : 'wheel#pendulum#alternate',
				\ 'Alternate in same torus' : 'wheel#pendulum#alternate_same_torus',
				\ 'Alternate in same circle' : 'wheel#pendulum#alternate_same_circle',
				\ 'Alternate in other torus' : 'wheel#pendulum#alternate_other_torus',
				\ 'Alternate in other circle' : 'wheel#pendulum#alternate_other_circle',
				\ 'Alternate in same torus, other circle' : 'wheel#pendulum#alternate_same_torus_other_circle',
				\}
	lockvar s:menu_alternate
endif

if ! exists('s:menu_tabs')
	let s:menu_tabs = {
				\ 'Toruses on tabs' : "wheel#mosaic#tabs('torus')",
				\ 'Circles on tabs' : "wheel#mosaic#tabs('circle')",
				\ 'Locations on tabs' : "wheel#mosaic#tabs('location')",
				\}
	lockvar s:menu_tabs
endif

if ! exists('s:menu_windows')
	let s:menu_windows = {
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
	lockvar s:menu_windows
endif

if ! exists('s:menu_tabnwin')
	let s:menu_tabnwin = {
				\ 'Mix : toruses on tabs & circles on splits' : "wheel#pyramid#steps('torus')",
				\ 'Mix : circles on tabs & locations on splits' : "wheel#pyramid#steps('circle')",
				\ 'Zoom : one tab, one window' : 'wheel#mosaic#zoom()',
				\}
	lockvar s:menu_tabnwin
endif

if ! exists('s:menu_reorganize')
	let s:menu_reorganize = {
				\ 'Reorder toruses' : "wheel#mandala#reorder('torus')",
				\ 'Reorder circles' : "wheel#mandala#reorder('circle')",
				\ 'Reorder locations' : "wheel#mandala#reorder('location')",
				\ 'Reorganize wheel' : 'wheel#mandala#reorganize',
				\}
	lockvar s:menu_reorganize
endif

if ! exists('s:menu_search')
	let s:menu_search = {
				\ 'Search in circle files' : 'wheel#mandala#grep()',
				\ 'Outline : folds headers in circle files' : 'wheel#mandala#outline()',
				\}
	lockvar s:menu_search
endif

if ! exists('s:menu_yank')
	let s:menu_yank = {
				\ 'Yank wheel in list mode' : "wheel#mandala#yank('list')",
				\ 'Yank wheel in plain mode' : "wheel#mandala#yank('plain')",
				\}
	lockvar s:menu_yank
endif

" Main menu

if ! exists('s:menu_main')
	let s:menu_main = {}
	call extend(s:menu_main, s:menu_add)
	call extend(s:menu_main, s:menu_rename)
	call extend(s:menu_main, s:menu_delete)
	call extend(s:menu_main, s:menu_switch)
	call extend(s:menu_main, s:menu_alternate)
	call extend(s:menu_main, s:menu_tabs)
	call extend(s:menu_main, s:menu_windows)
	call extend(s:menu_main, s:menu_tabnwin)
	call extend(s:menu_main, s:menu_reorganize)
	call extend(s:menu_main, s:menu_search)
	call extend(s:menu_main, s:menu_yank)
	lockvar s:menu_main
endif

" Meta menu

if ! exists('s:menu_meta')
	let s:menu_meta = {
				\ 'Add' : "wheel#hub#submenu('add')",
				\ 'Rename' : "wheel#hub#submenu('rename')",
				\ 'Delete' : "wheel#hub#submenu('delete')",
				\ 'Switch' : "wheel#hub#submenu('switch')",
				\ 'Alternate' : "wheel#hub#submenu('alternate')",
				\ 'Tabs' : "wheel#hub#submenu('tabs')",
				\ 'Window layouts' : "wheel#hub#submenu('windows')",
				\ 'Mix of tabs & windows' : "wheel#hub#submenu('tabnwin')",
				\ 'Reorganize' : "wheel#hub#submenu('reorganize')",
				\ 'Search in files' : "wheel#hub#submenu('search')",
				\ 'Yank' : "wheel#hub#submenu('yank')",
				\}
	lockvar s:menu_meta
endif

" Contextual menus

if ! exists('s:context_switch')
	let s:context_switch = {
				\ 'Switch' : "wheel#boomerang#switch('current')",
				\ 'Switch in tab(s)' : "wheel#boomerang#switch('tab')",
				\ 'Switch in horizontal split(s)' : "wheel#boomerang#switch('horizontal_split')",
				\ 'Switch in vertical split(s)' : "wheel#boomerang#switch('vertical_split')",
				\ 'Switch in horizontal golden split(s)' : "wheel#boomerang#switch('horizontal_golden')",
				\ 'Switch in vertical golden split(s)' : "wheel#boomerang#switch('vertical_golden')",
				\}
	lockvar s:context_switch
endif

if ! exists('s:context_grep')
	let s:context_grep = {
				\ 'Open quickfix' : "wheel#boomerang#grep('quickfix')",
				\}
	call extend(s:context_grep, s:context_switch)
	lockvar s:context_grep
endif

" Public Interface

fun! wheel#crystal#fetch (varname)
	" Return script variable called varname
	" The leading s: can be omitted
	let varname = a:varname
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	if varname =~ '\m^s:'
		return {varname}
	else
		return s:{varname}
	endif
endfun
