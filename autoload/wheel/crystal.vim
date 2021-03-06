" vim: ft=vim fdm=indent:

" Internal Constants made crystal clear

" Dictionaries are defined as list of items to preserve the order
" of keys. Useful for menus & context menus

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
	let s:referen_list_keys = {
				\ 'wheel' : 'toruses',
				\ 'torus' : 'circles',
				\ 'circle' : 'locations',
				\ }
	lockvar s:referen_list_keys
endif

" Modes

if ! exists('s:modes_letters')
	let s:modes_letters = {
				\ 'normal': 'n',
				\ 'insert': 'i',
				\ 'visual': 'v',
				\ }
	lockvar s:modes_letters
endif

if ! exists('s:letters_modes')
	let s:letters_modes = {
				\ 'n': 'normal',
				\ 'i': 'insert',
				\ 'v': 'visual',
				\ }
	lockvar s:letters_modes
endif

" Golden ratio

if ! exists('s:golden_ratio')
	let s:golden_ratio = (1 + sqrt(5)) / 2
	lockvar s:golden_ratio
endif

" Mandala patterns

if ! exists('s:is_mandala')
	" mandala filename pattern
	let s:is_mandala = '\m/wheel/[0-9]\+/'
	lockvar s:is_mandala
endif

if ! exists('s:is_mandala_tabs')
	" for output line of :tabs
	let s:is_mandala_tabs = '\m^>\?\s*+\?\s*' . s:is_mandala
	lockvar s:is_mandala_tabs
endif

if ! exists('s:mandala_empty')
	let s:mandala_empty = '\m/wheel/[0-9]\+/empty'
	lockvar s:mandala_empty
endif

" Mandalas options

if ! exists('s:mandala_options')
	let s:mandala_options = [
				\ 'buftype',
				\ 'bufhidden',
				\ 'buflisted',
				\ 'swapfile',
				\ 'cursorline',
				\ 'foldenable',
				\ 'foldmethod',
				\ 'foldmarker',
				\ 'foldtext',
				\ 'foldopen',
				\ 'foldclose',
				\ 'foldlevel',
				\ 'foldminlines',
				\ 'foldcolumn',
				\ ]
	lockvar s:mandala_options
endif

" Mandalas maps

if ! exists('s:normal_map_keys')
	let s:normal_map_keys = [
				\ 'q',
				\ 'j', 'k', '<down>', '<up>',
				\ 'i', 'a',
				\ '<cr>', '<space>', '<tab>',
				\ 't', 's', 'v',
				\ 'S', 'V',
				\ '&', '*', '<bar>',
				\ 'u', '<c-r>',
				\ 'g<cr>',
				\ 'gt', 'gs', 'gv',
				\ 'gS', 'gV',
				\ 'p', 'P',
				\ 'gp', 'gP',
				\ ]
	lockvar s:normal_map_keys
endif

if ! exists('s:insert_map_keys')
	let s:insert_map_keys = [
				\ '<space>', '<c-w>', '<c-u>',
				\ '<esc>', '<cr>',
				\ '<up>', '<down>', '<m-p>', '<m-n>',
				\ '<pageup>', '<pagedown>', '<m-r>', '<m-s>',
				\ ]
	lockvar s:insert_map_keys
endif

if ! exists('s:visual_map_keys')
	let s:visual_map_keys = [
				\ '<cr>',
				\ 'p', 'P',
				\  'g<cr>',
				\ 'gp', 'gP',
				\ ]
	lockvar s:visual_map_keys
endif

if ! exists('s:map_keys')
	let s:map_keys = {
				\ 'normal' : s:normal_map_keys,
				\ 'insert' : s:insert_map_keys,
				\ 'visual' : s:visual_map_keys,
				\ }
	lockvar s:map_keys
endif

" Mandala autocmds

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = 'wheel-mandala'
	lockvar s:mandala_autocmds_group
endif

if ! exists('s:mandala_autocmds_events')
	let s:mandala_autocmds_events = [
				\ 'BufWriteCmd',
				\ ]
	lockvar s:mandala_autocmds_events
endif

" Mandalas variables

if ! exists('s:mandala_vars')
	let s:mandala_vars = [
				\ 'b:wheel_lines',
				\ 'b:wheel_address',
				\ 'b:wheel_selected',
				\ 'b:wheel_settings',
				\ 'b:wheel_reload',
				\ ]
	lockvar s:mandala_vars
endif

" Layer stack in mandalas

if ! exists('s:layer_stack_fields')
	" filename : pseudo filename of the mandala
	" options : local options
	" mappings : mappings
	" autocmds : local autocommands
	" lines : lines mandala content, without filtering
	" filtered : filtered mandala content
	" position : cursor position
	" address : address associated with cursor line
	" selected : selected lines
	" settings : mandala settings
	" reload : reload function
	let s:layer_stack_fields = [
				\ 'filename',
				\ 'options',
				\ 'mappings',
				\ 'autocmds',
				\ 'lines',
				\ 'filtered',
				\ 'position',
				\ 'address',
				\ 'selected',
				\ 'settings',
				\ 'reload',
				\ ]
	lockvar s:layer_stack_fields
endif

" Folds in mandalas

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

" Separators in mandalas

if ! exists('s:separator_field')
	let s:separator_field = ' │ '
	lockvar s:separator_field
endif

if ! exists('s:separator_level')
	let s:separator_level = ' > '
	lockvar s:separator_level
endif

" Selections in mandalas

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
	let s:menu_add = [
				\ ['add a new torus' ,  'wheel#tree#add_torus'],
				\ ['add a new circle' ,  'wheel#tree#add_circle'],
				\ ['add here as new location' ,  'wheel#tree#add_here'],
				\ ['add a new file' ,  'wheel#tree#add_file'],
				\ ['add a new buffer' ,  'wheel#tree#add_buffer'],
				\ ['add files matching glob' ,  'wheel#tree#add_glob'],
				\]
	lockvar s:menu_add
endif

if ! exists('s:menu_rename')
	let s:menu_rename = [
				\ ['rename torus' ,  "wheel#tree#rename('torus')"],
				\ ['rename circle' ,  "wheel#tree#rename('circle')"],
				\ ['rename location' ,  "wheel#tree#rename('location')"],
				\ ['rename file' ,  'wheel#tree#rename_file'],
				\]
	lockvar s:menu_rename
endif

if ! exists('s:menu_delete')
	let s:menu_delete = [
				\ ['delete torus' ,  "wheel#tree#delete('torus')"],
				\ ['delete circle' ,  "wheel#tree#delete('circle')"],
				\ ['delete location' ,  "wheel#tree#delete('location')"],
				\]
	lockvar s:menu_delete
endif

if ! exists('s:menu_disc')
	let s:menu_disc = [
				\ ['save wheel' ,  'wheel#disc#write_all()'],
				\ ['load wheel' ,  'wheel#disc#read_all()'],
				\]
	lockvar s:menu_disc
endif

if ! exists('s:menu_navigation')
	let s:menu_navigation = [
				\ ['go to torus' ,  "wheel#sailing#switch('torus')"],
				\ ['go to circle' ,  "wheel#sailing#switch('circle')"],
				\ ['go to location' ,  "wheel#sailing#switch('location')"],
				\ ['go to location in index' ,  'wheel#sailing#helix'],
				\ ['go to circle in index' ,  'wheel#sailing#grid'],
				\ ['go to element in wheel tree' ,  'wheel#sailing#tree'],
				\ ['go to location in history' ,  'wheel#sailing#history'],
				\ ['go to most recently used file (mru)' ,  'wheel#sailing#attic'],
				\ ['go to locate result' ,  'wheel#sailing#locate'],
				\ ['go to find result' ,  'wheel#sailing#find'],
				\ ['go to async find result' ,  'wheel#sailing#async_find'],
				\ ['go to buffer' ,  'wheel#sailing#buffers'],
				\ ['go to tab & window' ,  'wheel#sailing#tabwins'],
				\ ['go to tab & window (fold tree mode)' ,  'wheel#sailing#tabwins_tree'],
				\ ['go to matching line (occur)' ,  'wheel#sailing#occur'],
				\ ['go to grep result' ,  'wheel#sailing#grep()'],
				\ ['go to outline result' ,  'wheel#sailing#outline()'],
				\ ['go to tag' ,  'wheel#sailing#tags()'],
				\]
	lockvar s:menu_navigation
endif

if ! exists('s:menu_alternate')
	let s:menu_alternate = [
				\ ['alternate anywhere' ,  'wheel#pendulum#alternate_anywhere'],
				\ ['alternate in same torus' ,  'wheel#pendulum#alternate_same_torus'],
				\ ['alternate in same circle' ,  'wheel#pendulum#alternate_same_circle'],
				\ ['alternate in other torus' ,  'wheel#pendulum#alternate_other_torus'],
				\ ['alternate in other circle' ,  'wheel#pendulum#alternate_other_circle'],
				\ ['alternate in same torus, other circle' ,  'wheel#pendulum#alternate_same_torus_other_circle'],
				\]
	lockvar s:menu_alternate
endif

if ! exists('s:menu_reorganize')
	let s:menu_reorganize = [
				\ ['reorder toruses' ,  "wheel#shape#reorder('torus')"],
				\ ['reorder circles' ,  "wheel#shape#reorder('circle')"],
				\ ['reorder locations' ,  "wheel#shape#reorder('location')"],
				\ ['reorganize wheel' ,  'wheel#shape#reorganize'],
				\ ['reorganize tabs & windows' ,  'wheel#shape#reorg_tabwins'],
				\ ['grep in edit mode' ,  'wheel#shape#grep_edit'],
				\ ['undo list' ,  'wheel#delta#undolist'],
				\]
	lockvar s:menu_reorganize
endif

if ! exists('s:menu_command')
	let s:menu_command = [
				\ [':ex or !shell command output', 'wheel#mandala#command'],
				\ ['async shell command output' ,  'wheel#mandala#async'],
				\]
	lockvar s:menu_command
endif

if ! exists('s:menu_yank')
	let s:menu_yank = [
				\ ['yank wheel in list mode' ,  "wheel#clipper#yank('list')"],
				\ ['yank wheel in plain mode' ,  "wheel#clipper#yank('plain')"],
				\]
	lockvar s:menu_yank
endif

if ! exists('s:menu_layout')
	let s:menu_layout = [
				\ ['zoom ,  one tab, one window', 'wheel#mosaic#zoom()'],
				\ ['rotate windows clockwise' ,  'wheel#mosaic#rotate_clockwise()'],
				\ ['rotate windows counter-clockwise' ,  'wheel#mosaic#rotate_counter_clockwise()'],
				\]
	lockvar s:menu_layout
endif

if ! exists('s:menu_layout_tabs')
	let s:menu_layout_tabs = [
				\ ['toruses on tabs' ,  "wheel#mosaic#tabs('torus')"],
				\ ['circles on tabs' ,  "wheel#mosaic#tabs('circle')"],
				\ ['locations on tabs' ,  "wheel#mosaic#tabs('location')"],
				\]
	lockvar s:menu_layout_tabs
endif

if ! exists('s:menu_layout_windows')
	let s:menu_layout_windows = [
				\ ['toruses on horizontal splits' ,  "wheel#mosaic#split('torus')"],
				\ ['circles on horizontal splits' ,  "wheel#mosaic#split('circle')"],
				\ ['locations on horizontal splits' ,  "wheel#mosaic#split('location')"],
				\ ['toruses on vertical splits' ,  "wheel#mosaic#split('torus', 'vertical')"],
				\ ['circles on vertical splits' ,  "wheel#mosaic#split('circle', 'vertical')"],
				\ ['locations on vertical splits' ,  "wheel#mosaic#split('location', 'vertical')"],
				\ ['toruses on splits, main top layout' ,  "wheel#mosaic#split('torus', 'main_top')"],
				\ ['circles on splits, main top layout' ,  "wheel#mosaic#split('circle', 'main_top')"],
				\ ['locations on splits, main top layout' ,  "wheel#mosaic#split('location', 'main_top')"],
				\ ['toruses on splits, main left layout' ,  "wheel#mosaic#split('torus', 'main_left')"],
				\ ['circles on splits, main left layout' ,  "wheel#mosaic#split('circle', 'main_left')"],
				\ ['locations on splits, main left layout' ,  "wheel#mosaic#split('location', 'main_left')"],
				\ ['toruses on splits, grid layout' ,  "wheel#mosaic#split_grid('torus')"],
				\ ['circles on splits, grid layout' ,  "wheel#mosaic#split_grid('circle')"],
				\ ['locations on splits, grid layout' ,  "wheel#mosaic#split_grid('location')"],
				\ ['toruses on splits, transposed grid layout' ,  "wheel#mosaic#split_transposed_grid('torus')"],
				\ ['circles on splits, transposed grid layout' ,  "wheel#mosaic#split_transposed_grid('circle')"],
				\ ['locations on splits, transposed grid layout' ,  "wheel#mosaic#split_transposed_grid('location')"],
				\ ['toruses on splits, golden horizontal' ,  "wheel#mosaic#golden('torus', 'horizontal')"],
				\ ['circles on splits, golden horizontal' ,  "wheel#mosaic#golden('circle', 'horizontal')"],
				\ ['locations on splits, golden horizontal' ,  "wheel#mosaic#golden('location', 'horizontal')"],
				\ ['toruses on splits, golden vertical' ,  "wheel#mosaic#golden('torus', 'vertical')"],
				\ ['circles on splits, golden vertical' ,  "wheel#mosaic#golden('circle', 'vertical')"],
				\ ['locations on splits, golden vertical' ,  "wheel#mosaic#golden('location', 'vertical')"],
				\ ['toruses on splits, golden left layout' ,  "wheel#mosaic#golden('torus', 'main_left')"],
				\ ['circles on splits, golden left layout' ,  "wheel#mosaic#golden('circle', 'main_left')"],
				\ ['locations on splits, golden left layout' ,  "wheel#mosaic#golden('location', 'main_left')"],
				\ ['toruses on splits, golden top layout' ,  "wheel#mosaic#golden('torus', 'main_top')"],
				\ ['circles on splits, golden top layout' ,  "wheel#mosaic#golden('circle', 'main_top')"],
				\ ['locations on splits, golden top layout' ,  "wheel#mosaic#golden('location', 'main_top')"],
				\]
	lockvar s:menu_layout_windows
endif

if ! exists('s:menu_layout_mixed')
	let s:menu_layout_mixed = [
				\ ['mix : toruses on tabs & circles on splits', "wheel#pyramid#steps('torus')"],
				\ ['mix : circles on tabs & locations on splits', "wheel#pyramid#steps('circle')"],
				\]
	lockvar s:menu_layout_mixed
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
				\ 'command',
				\ 'yank',
				\ 'layout',
				\ 'layout_tabs',
				\ 'layout_windows',
				\ 'layout_mixed',
				\]
	lockvar s:menu_list
endif

" Main menu

if ! exists('s:menu_main')
	let s:menu_main = []
	for name in s:menu_list
		call extend(s:menu_main, s:menu_{name})
	endfor
	lockvar s:menu_main
endif

" Meta menu

if ! exists('s:menu_meta')
	let s:menu_meta = [
				\ ['add' ,  "wheel#hub#submenu('add')"],
				\ ['rename' ,  "wheel#hub#submenu('rename')"],
				\ ['delete' ,  "wheel#hub#submenu('delete')"],
				\ ['disc' ,  "wheel#hub#submenu('disc')"],
				\ ['navigation' ,  "wheel#hub#submenu('navigation')"],
				\ ['alternate' ,  "wheel#hub#submenu('alternate')"],
				\ ['reorganize' ,  "wheel#hub#submenu('reorganize')"],
				\ ['command' ,  "wheel#hub#submenu('command')"],
				\ ['yank' ,  "wheel#hub#submenu('yank')"],
				\ ['layouts : generic', "wheel#hub#submenu('layout')"],
				\ ['layouts : tabs', "wheel#hub#submenu('layout_tabs')"],
				\ ['layouts : window', "wheel#hub#submenu('layout_windows')"],
				\ ['layouts : mixed', "wheel#hub#submenu('layout_mixed')"],
				\]
	lockvar s:menu_meta
endif

" Contextual menus

if ! exists('s:context_sailing')
	let s:context_sailing = [
				\ ['open' ,  "wheel#boomerang#sailing('current')"],
				\ ['open in tab(s)' ,  "wheel#boomerang#sailing('tab')"],
				\ ['open in horizontal split(s)' ,  "wheel#boomerang#sailing('horizontal_split')"],
				\ ['open in vertical split(s)' ,  "wheel#boomerang#sailing('vertical_split')"],
				\ ['open in horizontal golden split(s)' ,  "wheel#boomerang#sailing('horizontal_golden')"],
				\ ['open in vertical golden split(s)' ,  "wheel#boomerang#sailing('vertical_golden')"],
				\]
	lockvar s:context_sailing
endif

if ! exists('s:context_buffers')
	let s:context_buffers = s:context_sailing + [
				\ ['delete' ,  "wheel#boomerang#buffers('delete')"],
				\ ['unload' ,  "wheel#boomerang#buffers('unload')"],
				\ ['wipe' ,  "wheel#boomerang#buffers('wipe')"],
				\]
	lockvar s:context_buffers
endif

if ! exists('s:context_tabwins')
	let s:context_tabwins = [
				\ ['open' ,  "wheel#boomerang#tabwins('open')"],
				\ ['new tab' ,  "wheel#boomerang#tabwins('tabnew')"],
				\ ['close tab' ,  "wheel#boomerang#tabwins('tabclose')"],
				\ ['reorganize' ,  'wheel#shape#reorg_tabwins'],
				\]
	lockvar s:context_tabwins
endif

if ! exists('s:context_tabwins_tree')
	let s:context_tabwins_tree = [
				\ ['open' ,  "wheel#boomerang#tabwins_tree('open')"],
				\ ['new tab' ,  "wheel#boomerang#tabwins_tree('tabnew')"],
				\ ['close tab' ,  "wheel#boomerang#tabwins_tree('tabclose')"],
				\ ['reorganize' ,  'wheel#shape#reorg_tabwins'],
				\]
	lockvar s:context_tabwins_tree
endif

if ! exists('s:context_grep')
	let s:context_grep = s:context_sailing + [
				\ ['edit mode' ,  "wheel#shape#grep_edit()"],
				\ ['open quickfix' ,  "wheel#boomerang#grep('quickfix')"],
				\]
	lockvar s:context_grep
endif

if ! exists('s:context_yank_list')
	let s:context_yank_list = [
				\ ['paste before' ,  "wheel#boomerang#yank('before')"],
				\ ['paste after' ,  "wheel#boomerang#yank('after')"],
				\ ['undo' ,  'wheel#mandala#undo()'],
				\ ['redo' ,  'wheel#mandala#redo()'],
				\]
	lockvar s:context_yank_list
endif

if ! exists('s:context_yank_plain')
	let s:context_yank_plain = [
				\ ['linewise paste before' ,  "wheel#boomerang#yank('linewise_before')"],
				\ ['linewise paste after' ,  "wheel#boomerang#yank('linewise_after')"],
				\ ['characterwise paste before' ,  "wheel#boomerang#yank('charwise_before')"],
				\ ['characterwise paste after' ,  "wheel#boomerang#yank('charwise_after')"],
				\ ['undo' ,  'wheel#mandala#undo()'],
				\ ['redo' ,  'wheel#mandala#redo()'],
				\]
	lockvar s:context_yank_plain
endif

" Undo & diff

if ! exists('s:diff_options')
	let s:diff_options = [
				\ 'diff',
				\ 'scrollbind',
				\ 'cursorbind',
				\ 'scrollopt',
				\ 'wrap',
				\ 'foldmethod',
				\ 'foldcolumn',
				\]
	lockvar s:diff_options
endif

" Public Interface

fun! wheel#crystal#clear (varname)
	" Unlet script variable called varname
	let varname = a:varname
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	if varname !~ '\m^s:'
		let varname = 's:' . varname
	endif
	unlet {varname}
	return varname
endfun

fun! wheel#crystal#fetch (varname, ...)
	" Return script variable called varname
	" The leading s: can be omitted
	" If optional argument is 'dict' and varname
	" points to an items list, convert it to a dictionary
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	let varname = a:varname
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	if varname !~ '\m^s:'
		let varname = 's:' . varname
	endif
	if mode ==# 'dict' && wheel#matrix#is_nested_list ({varname})
		return wheel#matrix#items2dict ({varname})
	else
		return {varname}
	endif
endfun

fun! wheel#crystal#rainbow ()
	" Returns list of current script vars
	let position = getcurpos ()
	let command = 'global /^\s*let s:/ print'
	let lines = execute(command)
	call setpos('.', position)
	let varnames = split(lines, '\n')
	call map(varnames, {_,v -> substitute(v, '^.*let ', '', '')})
	call map(varnames, {_,v -> substitute(v, '\s*=.*', '', '')})
	call map(varnames, {_,v -> substitute(v, '^s:', '', '')})
	return wheel#chain#unique (varnames)
endfun
