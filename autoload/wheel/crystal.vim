" vim: ft=vim fdm=indent:

" Internal Variables made crystal clear

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
	let s:referen_coordin = ['torus', 'circle', 'location']
	lockvar s:referen_coordin
endif

if ! exists('s:referen_list_keys')
	let s:referen_list_keys =
				\{
				\ 'wheel' : 'toruses',
				\ 'torus' : 'circles',
				\ 'circle' : 'locations',
				\ }
	lockvar s:referen_list_keys
endif

" Golden ratio

if ! exists('s:golden_ratio')
	let s:golden_ratio = (1 + sqrt(5)) / 2
	lockvar s:golden_ratio
endif

" Strings

if ! exists('s:separator_field')
	let s:separator_field = ' | '
	lockvar s:separator_field
endif

if ! exists('s:separator_level')
	let s:separator_level = ' > '
	lockvar s:separator_level
endif

if ! exists('s:selected_mark')
	let s:selected_mark = '* '
	lockvar s:selected_mark
endif

if ! exists('s:selected_pattern')
	let s:selected_pattern = '\m^\* '
	lockvar s:selected_pattern
endif

" Folds

if ! exists('s:fold_markers')
	let s:fold_markers = ['>', '<']
	lockvar s:fold_markers
endif

if ! exists('s:fold_one')
	let s:fold_one = ' ' . s:fold_markers[0] . '1'
	lockvar s:fold_one
endif

if ! exists('s:fold_two')
	let s:fold_two = ' ' . s:fold_markers[0] . '2'
	lockvar s:fold_two
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

if ! exists('s:menu_disc')
	let s:menu_disc = {
				\ 'Save wheel' : 'wheel#disc#write_all()',
				\ 'Load wheel' : 'wheel#disc#read_all()',
				\}
	lockvar s:menu_disc
endif

if ! exists('s:menu_navigation')
	let s:menu_navigation = {
				\ 'Go to torus' : "wheel#sailing#switch('torus')",
				\ 'Go to circle' : "wheel#sailing#switch('circle')",
				\ 'Go to location' : "wheel#sailing#switch('location')",
				\ 'Go to location in index' : 'wheel#sailing#helix',
				\ 'Go to circle in index' : 'wheel#sailing#grid',
				\ 'Go to element in wheel tree' : 'wheel#sailing#tree',
				\ 'Go to location in history' : 'wheel#sailing#history',
				\ 'Go to matching line (occur)' : 'wheel#sailing#occur',
				\ 'Go to grep result' : 'wheel#sailing#grep()',
				\ 'Go to outline result' : 'wheel#sailing#outline()',
				\ 'Go to tag' : 'wheel#sailing#symbol()',
				\ 'Go to most recently used file (mru)' : 'wheel#sailing#attic',
				\ 'Go to result of locate search' : 'wheel#sailing#locate',
				\ 'Go to result of find search' : 'wheel#sailing#find',
				\}
	lockvar s:menu_navigation
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

if ! exists('s:menu_reorganize')
	let s:menu_reorganize = {
				\ 'Reorder toruses' : "wheel#shape#reorder('torus')",
				\ 'Reorder circles' : "wheel#shape#reorder('circle')",
				\ 'Reorder locations' : "wheel#shape#reorder('location')",
				\ 'Reorganize wheel' : 'wheel#shape#reorganize',
				\}
	lockvar s:menu_reorganize
endif

if ! exists('s:menu_yank')
	let s:menu_yank = {
				\ 'Yank wheel in list mode' : "wheel#clipper#yank('list')",
				\ 'Yank wheel in plain mode' : "wheel#clipper#yank('plain')",
				\}
	lockvar s:menu_yank
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

" List of menu variables

if ! exists('s:menu_list')
	let s:menu_list = [
				\ 'add',
				\ 'rename',
				\ 'delete',
				\ 'disc',
				\ 'navigation',
				\ 'alternate',
				\ 'reorganize',
				\ 'yank',
				\ 'tabs',
				\ 'windows',
				\ 'tabnwin',
				\]
	lockvar s:menu_list
endif

" Main menu

if ! exists('s:menu_main')
	let s:menu_main = {}
	for name in s:menu_list
		call extend(s:menu_main, s:menu_{name})
	endfor
	lockvar s:menu_main
endif

" Meta menu

if ! exists('s:menu_meta')
	let s:menu_meta = {
				\ 'Add' : "wheel#hub#submenu('add')",
				\ 'Rename' : "wheel#hub#submenu('rename')",
				\ 'Delete' : "wheel#hub#submenu('delete')",
				\ 'Disc' : "wheel#hub#submenu('disc')",
				\ 'Navigation' : "wheel#hub#submenu('navigation')",
				\ 'Alternate' : "wheel#hub#submenu('alternate')",
				\ 'Tabs' : "wheel#hub#submenu('tabs')",
				\ 'Window layouts' : "wheel#hub#submenu('windows')",
				\ 'Mix of tabs & windows' : "wheel#hub#submenu('tabnwin')",
				\ 'Reorganize' : "wheel#hub#submenu('reorganize')",
				\ 'Yank' : "wheel#hub#submenu('yank')",
				\}
	lockvar s:menu_meta
endif

" Contextual menus

if ! exists('s:context_sailing')
	let s:context_sailing = {
				\ 'Open' : "wheel#boomerang#sailing('current')",
				\ 'Open in tab(s)' : "wheel#boomerang#sailing('tab')",
				\ 'Open in horizontal split(s)' : "wheel#boomerang#sailing('horizontal_split')",
				\ 'Open in vertical split(s)' : "wheel#boomerang#sailing('vertical_split')",
				\ 'Open in horizontal golden split(s)' : "wheel#boomerang#sailing('horizontal_golden')",
				\ 'Open in vertical golden split(s)' : "wheel#boomerang#sailing('vertical_golden')",
				\}
	lockvar s:context_sailing
endif

if ! exists('s:context_grep')
	let s:context_grep = {
				\ 'Open quickfix' : "wheel#boomerang#grep('quickfix')",
				\}
	call extend(s:context_grep, s:context_sailing)
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
