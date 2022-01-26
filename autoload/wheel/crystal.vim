" vim: set ft=vim fdm=indent iskeyword&:

" Internal Constants made crystal clear

" Dictionaries are defined as list of items to preserve the order
" of keys.
"
" Useful for menus & context menus

" unicode store
"
" enter unicode : in insert mode :
"
"   - ctrl-v u 12ab
"   - ctrl-v U 12ab34cd
"
" see :
"
"   - :help i_CTRL-V_digit
"   - https://unicode-table.com/en/
"
" ☯ 𑇍 ᚛ ⊗ ⊛ ✶ 🗸 𐄂

" wheel levels

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

" modes

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

" golden ratio

if ! exists('s:golden_ratio')
	let s:golden_ratio = (1 + sqrt(5)) / 2
	lockvar s:golden_ratio
endif

" signs

if ! exists('s:sign_name')
	let s:sign_name = 'wheel-sign-name'
	lockvar s:sign_name
endif

if ! exists('s:sign_group')
	let s:sign_group = 'wheel-sign-group'
	lockvar s:sign_group
endif

if ! exists('s:sign_text')
	let s:sign_text = '☯'
	" sign text must be 2 chars or a space will be added by vim
	" an extra space is added by chakra#define to avoid confusion
	lockvar s:sign_text
endif

if ! exists('s:sign_settings')
	let s:sign_settings = #{
				\ text : s:sign_text,
				\ }
	lockvar s:sign_settings
endif

" highlight groups for sign
" 				\ texthl : 'Normal',
" 				\ numhl : 'Normal',
" 				\ linehl : 'Normal',

" mandala prompt

if ! exists('s:mandala_prompt')
	let s:mandala_prompt = '☯ '
	lockvar s:mandala_prompt
endif

" mandala patterns

if ! exists('s:is_mandala_file')
	" mandala filename pattern
	let s:is_mandala_file = '\m^/wheel/[0-9]\+/'
	lockvar s:is_mandala_file
endif

if ! exists('s:is_buffer_tabs')
	" for output line of :tabs
	let s:is_buffer_tabs = '\m^\%(\s\|>\|#\)'
	lockvar s:is_buffer_tabs
endif

if ! exists('s:is_mandala_tabs')
	" for output line of :tabs
	let s:is_mandala_tabs = '\m^>\?\s*+\?\s*' .. s:is_mandala_file
	lockvar s:is_mandala_tabs
endif

if ! exists('s:mandala_empty')
	let s:mandala_empty = '\m/wheel/[0-9]\+/empty'
	lockvar s:mandala_empty
endif

" mandalas options

if ! exists('s:mandala_options')
	let s:mandala_options = [
				\ 'filetype',
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

" mandalas maps

if ! exists('s:normal_map_keys')
	let s:normal_map_keys = [
				\ 'q',
				\ 'j', 'k', '<down>', '<up>',
				\ 'i', 'a',
				\ '<m-i>', '<ins>',
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
				\ '<c-s>',
				\ '<m-s>', 'o', 'O', '<m-y>', '<m-z>',
				\ '+', '-', '<kplus>', '<kminus>'
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

" mandala autocmds

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

" mandalas variables

if ! exists('s:mandala_vars')
	let s:mandala_vars = [
				\ 'b:wheel_nature',
				\ 'b:wheel_related_buffer',
				\ 'b:wheel_lines',
				\ 'b:wheel_filter',
				\ 'b:wheel_selection',
				\ 'b:wheel_settings',
				\ 'b:wheel_reload',
				\ ]
	lockvar s:mandala_vars
endif

" leaf : layer fields in mandalas

if ! exists('s:layer_fields')
	" filename : pseudo filename of the mandala
	" options : local options
	" mappings : mappings
	" autocmds : local autocommands
	" nature : general qualities ; empty mandala ? has_filter ?
	" related_buffer : bufnum of related buffer
	" lines : all mandala lines, without filtering
	" filter : filtered mandala content
	" selection : selected indexes & lines
	" preview
	" cursor : selection & position
	" settings : mandala settings
	" reload : reload function
	let s:layer_fields = [
				\ 'filename',
				\ 'options',
				\ 'mappings',
				\ 'autocmds',
				\ 'nature',
				\ 'related_buffer',
				\ 'lines',
				\ 'filter',
				\ 'selection',
				\ 'preview',
				\ 'cursor',
				\ 'settings',
				\ 'reload',
				\ ]
	lockvar s:layer_fields
endif

" folds in mandalas

if ! exists('s:fold_markers')
	let s:fold_markers = ['⧽', '⧼']
	lockvar s:fold_markers
endif

if ! exists('s:fold_one')
	let s:fold_one = ' ' .. s:fold_markers[0] .. '1'
	lockvar s:fold_one
endif

if ! exists('s:fold_two')
	let s:fold_two = ' ' .. s:fold_markers[0] .. '2'
	lockvar s:fold_two
endif

if ! exists('s:fold_pattern')
	let s:fold_pattern = '\m' .. s:fold_markers[0] .. '[12]$'
	lockvar s:fold_pattern
endif

" separators in mandalas

if ! exists('s:separator_field')
	let s:separator_field = ' │ '
	" digraph : in insert mode : ctrl-k vv -> │ != usual | == <bar>
	lockvar s:separator_field
endif

if ! exists('s:separator_field_bar')
	" digraph : ctrl-k vv ->
	let s:separator_field_bar = '│'
	lockvar s:separator_field_bar
endif

if ! exists('s:separator_level')
	let s:separator_level = ' ⧽ '
	lockvar s:separator_level
endif

" selections in mandalas

if ! exists('s:selection_mark')
	let s:selection_mark = '☰ '
	lockvar s:selection_mark
endif

" targets in mandalas

if ! exists('s:mandala_targets')
	let s:mandala_targets = [
				\ 'current',
				\ 'tab',
				\ 'horizontal_split',
				\ 'vertical_split',
				\ 'horizontal_golden',
				\ 'vertical_golden',
				\]
	lockvar s:mandala_targets
endif

" menus

if ! exists('s:menu_help')
	let s:menu_help = [
				\ ['inline help', 'wheel#guru#help'],
				\ ['current mappings', 'wheel#guru#mappings'],
				\ ['available mappings (plugs)', 'wheel#guru#plugs'],
				\ ['autocommands', 'wheel#guru#autocomands'],
				\]
	lockvar s:menu_help
endif

if ! exists('s:menu_status')
	let s:menu_status = [
				\ ['dashboard', 'wheel#status#dashboard'],
				\ ['jump to current wheel location', 'wheel#vortex#jump'],
				\ ['find closest wheel location to cursor', 'wheel#projection#follow'],
				\]
	lockvar s:menu_status
endif

if ! exists('s:menu_save_and_load')
	let s:menu_save_and_load = [
				\ ['save wheel', 'wheel#disc#write_all'],
				\ ['load wheel', 'wheel#disc#read_all'],
				\ ['save session', 'wheel#disc#write_session'],
				\ ['load session', 'wheel#disc#read_session'],
				\]
	lockvar s:menu_save_and_load
endif

if ! exists('s:menu_wheel_navigation')
	let s:menu_wheel_navigation = [
				\ ['previous location' ,  "wheel#vortex#previous('location')"],
				\ ['next location' ,  "wheel#vortex#next('location')"],
				\ ['previous circle' ,  "wheel#vortex#previous('circle')"],
				\ ['next circle' ,  "wheel#vortex#next('circle')"],
				\ ['previous torus' ,  "wheel#vortex#previous('torus')"],
				\ ['next torus' ,  "wheel#vortex#next('torus')"],
				\ ['go to torus' ,  "wheel#whirl#switch('torus')"],
				\ ['go to circle' ,  "wheel#whirl#switch('circle')"],
				\ ['go to location' ,  "wheel#whirl#switch('location')"],
				\ ['go to location in index' ,  'wheel#whirl#helix'],
				\ ['go to circle in index' ,  'wheel#whirl#grid'],
				\ ['go to element in wheel tree' ,  'wheel#whirl#tree'],
				\ ['newer location in history' ,  'wheel#pendulum#newer'],
				\ ['older location in history' ,  'wheel#pendulum#older'],
				\ ['newer location in same circle' ,  "wheel#pendulum#newer('circle')"],
				\ ['older location in same circle' ,  "wheel#pendulum#older('circle')"],
				\ ['newer location in same torus' ,  "wheel#pendulum#newer('torus')"],
				\ ['older location in same torus' ,  "wheel#pendulum#older('torus')"],
				\ ['alternate anywhere' ,  "wheel#pendulum#alternate('anywhere')"],
				\ ['alternate in same torus' ,  "wheel#pendulum#alternate('same_torus')"],
				\ ['alternate in same circle' ,  "wheel#pendulum#alternate('same_circle')"],
				\ ['alternate in other torus' ,  "wheel#pendulum#alternate('other_torus')"],
				\ ['alternate in other circle' ,  "wheel#pendulum#alternate('other_circle')"],
				\ ['alternate in same torus, other circle' ,  "wheel#pendulum#alternate('same_torus_other_circle')"],
				\ ['go to location in history' ,  'wheel#whirl#history'],
				\]
	lockvar s:menu_wheel_navigation
endif

if ! exists('s:menu_native_navigation')
	let s:menu_native_navigation = [
				\ ['go to buffer' ,  'wheel#frigate#buffers'],
				\ ['go to buffer (include unlisted)' ,  "wheel#frigate#buffers('all')"],
				\ ['go to tab & window' ,  'wheel#frigate#tabwins'],
				\ ['go to tab & window (fold tree mode)' ,  'wheel#frigate#tabwins_tree'],
				\ ['go to marker' ,  'wheel#frigate#markers()'],
				\ ['go to jump' ,  'wheel#frigate#jumps()'],
				\ ['go to change' ,  'wheel#frigate#changes()'],
				\ ['go to tag' ,  'wheel#frigate#tags()'],
				\]
	lockvar s:menu_native_navigation
endif

if ! exists('s:menu_organize_wheel')
	let s:menu_organize_wheel = [
				\ ['add a new torus' ,  'wheel#tree#add_torus'],
				\ ['add a new circle' ,  'wheel#tree#add_circle'],
				\ ['add new location at cursor' ,  'wheel#tree#add_here'],
				\ ['add a new file' ,  'wheel#tree#add_file'],
				\ ['add a new buffer' ,  'wheel#tree#add_buffer'],
				\ ['add files matching glob' ,  'wheel#tree#add_glob'],
				\ ['reorder toruses' ,  "wheel#yggdrasil#reorder('torus')"],
				\ ['reorder circles' ,  "wheel#yggdrasil#reorder('circle')"],
				\ ['reorder locations' ,  "wheel#yggdrasil#reorder('location')"],
				\ ['rename torus' ,  "wheel#tree#rename('torus')"],
				\ ['rename circle' ,  "wheel#tree#rename('circle')"],
				\ ['rename location' ,  "wheel#tree#rename('location')"],
				\ ['rename file & location' ,  'wheel#tree#rename_file'],
				\ ['rename toruses' ,  "wheel#yggdrasil#rename('torus')"],
				\ ['rename circles' ,  "wheel#yggdrasil#rename('circle')"],
				\ ['rename locations' ,  "wheel#yggdrasil#rename('location')"],
				\ ['rename locations & filenames' ,  'wheel#yggdrasil#rename_files'],
				\ ['delete torus' ,  "wheel#tree#delete('torus')"],
				\ ['delete circle' ,  "wheel#tree#delete('circle')"],
				\ ['delete location' ,  "wheel#tree#delete('location')"],
				\ ['move circle' ,  "wheel#tree#move('circle')"],
				\ ['move location' ,  "wheel#tree#move('location')"],
				\ ['copy torus' ,  "wheel#tree#copy('torus')"],
				\ ['copy circle' ,  "wheel#tree#copy('circle')"],
				\ ['copy location' ,  "wheel#tree#copy('location')"],
				\ ['copy or move toruses' ,  "wheel#yggdrasil#copy_move('torus')"],
				\ ['copy or move circles' ,  "wheel#yggdrasil#copy_move('circle')"],
				\ ['copy or move locations' ,  "wheel#yggdrasil#copy_move('location')"],
				\ ['reorganize wheel' ,  'wheel#yggdrasil#reorganize'],
				\]
	lockvar s:menu_organize_wheel
endif

if ! exists('s:menu_organize_native')
	let s:menu_organize_native = [
				\ ['reorganize tabs & windows' ,  'wheel#shape#reorg_tabwins'],
				\]
	lockvar s:menu_organize_native
endif

if ! exists('s:menu_refactor')
	let s:menu_refactor = [
				\ ['grep in edit mode' ,  'wheel#shape#grep_edit'],
				\ ['narrow current file' ,  'wheel#polyphony#operator'],
				\ ['narrow all files in circle' ,  'wheel#shape#narrow_circle'],
				\]
	lockvar s:menu_refactor
endif

if ! exists('s:menu_search_file')
	let s:menu_search_file = [
				\ ['go to most recently used file (mru)' ,  'wheel#frigate#mru'],
				\ ['go to locate result' ,  'wheel#frigate#locate'],
				\ ['go to find result' ,  'wheel#frigate#find'],
				\ ['go to async find result' ,  'wheel#frigate#async_find'],
				\]
	lockvar s:menu_search_file
endif

if ! exists('s:menu_search_inside_file')
	let s:menu_search_inside_file = [
				\ ['go to matching line (occur)' ,  'wheel#frigate#occur'],
				\ ['go to grep result' ,  'wheel#frigate#grep()'],
				\ ['go to outline result' ,  'wheel#frigate#outline()'],
				\]
	lockvar s:menu_search_inside_file
endif

if ! exists('s:menu_yank')
	let s:menu_yank = [
				\ ['yank wheel in list mode' ,  "wheel#clipper#yank('list')"],
				\ ['yank wheel in plain mode' ,  "wheel#clipper#yank('plain')"],
				\]
	lockvar s:menu_yank
endif

if ! exists('s:menu_undo')
	let s:menu_undo = [
				\ ['undo list' ,  'wheel#triangle#undolist'],
				\]
	lockvar s:menu_undo
endif

if ! exists('s:menu_command')
	let s:menu_command = [
				\ [':ex or !shell command output', 'wheel#mandala#command'],
				\ ['async shell command output' ,  'wheel#mandala#async'],
				\]
	lockvar s:menu_command
endif

if ! exists('s:menu_dedicated_buffers')
	let s:menu_dedicated_buffers = [
				\ ['add new dedicated buffer', 'wheel#cylinder#add()'],
				\ ['delete current dedicated buffer', 'wheel#cylinder#add()'],
				\ ['switch dedicated buffer', 'wheel#cylinder#switch()'],
				\]
	lockvar s:menu_dedicated_buffers
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

" list of menu variables

if ! exists('s:menu_list')
	let s:menu_list = [
				\ 'help',
				\ 'status',
				\ 'save and load',
				\ 'wheel navigation',
				\ 'native navigation',
				\ 'organize wheel',
				\ 'organize native',
				\ 'refactor',
				\ 'search file',
				\ 'search inside file',
				\ 'yank',
				\ 'undo',
				\ 'command',
				\ 'layout',
				\ 'layout_tabs',
				\ 'layout_windows',
				\ 'layout_mixed',
				\]
	lockvar s:menu_list
endif

" main menu

if ! exists('s:menu_main')
	let s:menu_main = []
	for name in s:menu_list
		let s:short_name = substitute(name, ' ', '_', 'g')
		call extend(s:menu_main, s:menu_{s:short_name})
	endfor
	lockvar s:menu_main
endif

" meta menu

if ! exists('s:menu_meta')
	let s:menu_meta = []
	for name in s:menu_list
		let s:short_name = substitute(name, ' ', '_', 'g')
		let s:function = "wheel#helm#submenu('" .. s:short_name .. "')"
		call add(s:menu_meta, [name, s:function])
	endfor
	lockvar s:menu_meta
endif

" contextual menus

if ! exists('s:context_navigation')
	let s:context_navigation = [
				\ ['open' ,  "wheel#boomerang#navigation('current')"],
				\ ['open in tab(s)' ,  "wheel#boomerang#navigation('tab')"],
				\ ['open in horizontal split(s)' ,  "wheel#boomerang#navigation('horizontal_split')"],
				\ ['open in vertical split(s)' ,  "wheel#boomerang#navigation('vertical_split')"],
				\ ['open in horizontal golden split(s)' ,  "wheel#boomerang#navigation('horizontal_golden')"],
				\ ['open in vertical golden split(s)' ,  "wheel#boomerang#navigation('vertical_golden')"],
				\]
	lockvar s:context_navigation
endif

if ! exists('s:context_buffers')
	let s:context_buffers = s:context_navigation + [
				\ ['delete' ,  "wheel#boomerang#buffers('delete')"],
				\ ['unload' ,  "wheel#boomerang#buffers('unload')"],
				\ ['wipe' ,  "wheel#boomerang#buffers('wipe')"],
				\ ['delete hidden buffers' ,  "wheel#boomerang#buffers('delete_hidden')"],
				\ ['wipe hidden buffers' ,  "wheel#boomerang#buffers('wipe_hidden')"],
				\]
	lockvar s:context_buffers
endif

if ! exists('s:context_buffers_all')
	let s:context_buffers_all = s:context_navigation + [
				\ ['delete' ,  "wheel#boomerang#buffers('delete')"],
				\ ['unload' ,  "wheel#boomerang#buffers('unload')"],
				\ ['wipe' ,  "wheel#boomerang#buffers('wipe')"],
				\ ['delete hidden buffers' ,  "wheel#boomerang#buffers('delete_hidden')"],
				\ ['wipe hidden buffers' ,  "wheel#boomerang#buffers('wipe_hidden')"],
				\ ['wipe all hidden buffers, including unlisted ones' ,  "wheel#boomerang#buffers('wipe_all_hidden')"],
				\]
	lockvar s:context_buffers_all
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
	let s:context_grep = s:context_navigation + [
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

" undo & diff

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

" public interface

fun! wheel#crystal#clear (varname)
	" Unlet script variable called varname
	let varname = a:varname
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	if varname !~ '\m^s:'
		let varname = 's:' .. varname
	endif
	unlet {varname}
	return varname
endfun

fun! wheel#crystal#fetch (varname, conversion = 'no-conversion')
	" Return script variable called varname
	" The leading s: can be omitted
	" Optional argument :
	"   - no-conversion : simply returns the asked variable, dont convert anything
	"   - dict : if varname points to an items list, convert it to a dictionary
	let varname = a:varname
	let conversion = a:conversion
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	let varname = substitute(varname, ' ', '_', 'g')
	if varname !~ '\m^s:'
		let varname = 's:' .. varname
	endif
	if conversion ==# 'dict' && wheel#matrix#is_nested_list ({varname})
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
	eval varnames->map({ _, val -> substitute(val, '^.*let ', '', '') })
	eval varnames->map({ _, val -> substitute(val, '\s*=.*', '', '') })
	eval varnames->map({ _, val -> substitute(val, '^s:', '', '') })
	return wheel#chain#unique (varnames)
endfun
