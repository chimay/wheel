" vim: set ft=vim fdm=indent iskeyword&:

" Quartz
"
" Internal Constants for menus in mandalas

" Dictionaries are defined as list of items to preserve the order
" of keys.
"
" Useful for menus & context menus

" ---- submenus

if exists('s:menu_help')
	unlockvar! s:menu_help
endif
let s:menu_help = [
			\ ['inline help', 'wheel#guru#help'],
			\ ['current prefix mappings', 'wheel#guru#mappings'],
			\ ['available mappings (plugs)', 'wheel#guru#plugs'],
			\ ['meta command and subcommands', 'wheel#guru#meta_command'],
			\ ['autocommands', 'wheel#guru#autocommands'],
			\ ['dedicated buffer help', 'wheel#guru#mandala'],
			\ ['local maps', 'wheel#guru#mandala_mappings'],
			\ ]
lockvar! s:menu_help

if exists('s:menu_status')
	unlockvar! s:menu_status
endif
let s:menu_status = [
			\ ['dashboard', 'wheel#status#dashboard'],
			\ ['jump to current wheel location', 'wheel#vortex#jump'],
			\ ['find closest wheel location to cursor', 'wheel#projection#follow'],
			\ ]
lockvar! s:menu_status

if exists('s:menu_save_and_load')
	unlockvar! s:menu_save_and_load
endif
let s:menu_save_and_load = [
			\ ['save wheel', 'wheel#disc#write_wheel'],
			\ ['load wheel', 'wheel#disc#read_wheel'],
			\ ['save session', 'wheel#disc#write_session'],
			\ ['load session', 'wheel#disc#read_session'],
			\ ]
lockvar! s:menu_save_and_load

if exists('s:menu_wheel_navigation')
	unlockvar! s:menu_wheel_navigation
endif
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
			\ ['newer location in history' ,  'wheel#waterclock#newer'],
			\ ['older location in history' ,  'wheel#waterclock#older'],
			\ ['newer location in same circle' ,  "wheel#waterclock#newer('circle')"],
			\ ['older location in same circle' ,  "wheel#waterclock#older('circle')"],
			\ ['newer location in same torus' ,  "wheel#waterclock#newer('torus')"],
			\ ['older location in same torus' ,  "wheel#waterclock#older('torus')"],
			\ ['alternate anywhere' ,  "wheel#caduceus#alternate('anywhere')"],
			\ ['alternate in same torus' ,  "wheel#caduceus#alternate('same_torus')"],
			\ ['alternate in same circle' ,  "wheel#caduceus#alternate('same_circle')"],
			\ ['alternate in other torus' ,  "wheel#caduceus#alternate('other_torus')"],
			\ ['alternate in other circle' ,  "wheel#caduceus#alternate('other_circle')"],
			\ ['alternate in same torus, other circle' ,  "wheel#caduceus#alternate('same_torus_other_circle')"],
			\ ['go to location in history' ,  'wheel#whirl#history'],
			\ ['go to location in frecency' ,  'wheel#whirl#frecency'],
			\ ]
lockvar! s:menu_wheel_navigation

if exists('s:menu_native_navigation')
	unlockvar! s:menu_native_navigation
endif
let s:menu_native_navigation = [
			\ ['go to buffer' ,  'wheel#frigate#buffer'],
			\ ['go to buffer (include unlisted)' ,  "wheel#frigate#buffer('all')"],
			\ ['go to tab & window' ,  'wheel#frigate#tabwin'],
			\ ['go to tab & window (fold tree mode)' ,  'wheel#frigate#tabwin_tree'],
			\ ['go to marker' ,  'wheel#frigate#marker()'],
			\ ['go to jump' ,  'wheel#frigate#jump()'],
			\ ['go to change' ,  'wheel#frigate#change()'],
			\ ['go to tag' ,  'wheel#frigate#tag()'],
			\ ]
lockvar! s:menu_native_navigation

if exists('s:menu_organize_wheel')
	unlockvar! s:menu_organize_wheel
endif
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
			\ ['rename locations & filenames' ,  'wheel#yggdrasil#rename_file'],
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
			\ ]
lockvar! s:menu_organize_wheel

if exists('s:menu_organize_native')
	unlockvar! s:menu_organize_native
endif
let s:menu_organize_native = [
			\ ['reorganize tabs & windows' ,  'wheel#mirror#reorg_tabwin'],
			\ ]
lockvar! s:menu_organize_native

if exists('s:menu_refactoring')
	unlockvar! s:menu_refactoring
endif
let s:menu_refactoring = [
			\ ['grep in edit mode' ,  'wheel#shadow#grep_edit'],
			\ ['narrow current file' ,  'wheel#shadow#narrow_file'],
			\ ['narrow all files in circle' ,  'wheel#shadow#narrow_circle'],
			\ ]
lockvar! s:menu_refactoring

if exists('s:menu_search_file')
	unlockvar! s:menu_search_file
endif
let s:menu_search_file = [
			\ ['go to most recently used file (mru)' ,  'wheel#frigate#mru'],
			\ ['go to locate result' ,  'wheel#frigate#locate'],
			\ ['go to find result' ,  'wheel#frigate#find'],
			\ ['go to async find result' ,  'wheel#frigate#async_find'],
			\ ]
lockvar! s:menu_search_file

if exists('s:menu_search_inside_file')
	unlockvar! s:menu_search_inside_file
endif
let s:menu_search_inside_file = [
			\ ['go to matching line (occur)' ,  'wheel#frigate#occur'],
			\ ['go to grep result' ,  'wheel#frigate#grep()'],
			\ ['go to outline result' ,  'wheel#frigate#outline()'],
			\ ]
lockvar! s:menu_search_inside_file

if exists('s:menu_yank')
	unlockvar! s:menu_yank
endif
let s:menu_yank = [
			\ ['yank wheel in list mode' ,  "wheel#clipper#yank('list')"],
			\ ['yank wheel in plain mode' ,  "wheel#clipper#yank('plain')"],
			\ ]
lockvar! s:menu_yank

if exists('s:menu_undo')
	unlockvar! s:menu_undo
endif
let s:menu_undo = [
			\ ['undo list' ,  'wheel#triangle#undolist'],
			\ ]
lockvar! s:menu_undo

if exists('s:menu_command')
	unlockvar! s:menu_command
endif
let s:menu_command = [
			\ [':ex or !shell command output', 'wheel#mandala#command'],
			\ ['async shell command output' ,  'wheel#mandala#async'],
			\ ]
lockvar! s:menu_command

if exists('s:menu_dedicated_buffers')
	unlockvar! s:menu_dedicated_buffers
endif
let s:menu_dedicated_buffers = [
			\ ['add new dedicated buffer', 'wheel#cylinder#add()'],
			\ ['delete current dedicated buffer', 'wheel#cylinder#add()'],
			\ ['switch dedicated buffer', 'wheel#cylinder#switch()'],
			\ ]
lockvar! s:menu_dedicated_buffers

if exists('s:menu_layout')
	unlockvar! s:menu_layout
endif
let s:menu_layout = [
			\ ['zoom ,  one tab, one window', 'wheel#mosaic#zoom()'],
			\ ['rotate windows clockwise' ,  'wheel#mosaic#rotate_clockwise()'],
			\ ['rotate windows counter-clockwise' ,  'wheel#mosaic#rotate_counter_clockwise()'],
			\ ]
lockvar! s:menu_layout

if exists('s:menu_layout_tabs')
	unlockvar! s:menu_layout_tabs
endif
let s:menu_layout_tabs = [
			\ ['toruses on tabs' ,  "wheel#mosaic#tabs('torus')"],
			\ ['circles on tabs' ,  "wheel#mosaic#tabs('circle')"],
			\ ['locations on tabs' ,  "wheel#mosaic#tabs('location')"],
			\ ]
lockvar! s:menu_layout_tabs

if exists('s:menu_layout_windows')
	unlockvar! s:menu_layout_windows
endif
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
			\ ]
lockvar! s:menu_layout_windows

if exists('s:menu_layout_mixed')
	unlockvar! s:menu_layout_mixed
endif
let s:menu_layout_mixed = [
			\ ['mix : toruses on tabs & circles on splits', "wheel#pyramid#steps('torus')"],
			\ ['mix : circles on tabs & locations on splits', "wheel#pyramid#steps('circle')"],
			\ ]
lockvar! s:menu_layout_mixed

" ---- list of submenus variables

if exists('s:menu_list')
	unlockvar! s:menu_list
endif
let s:menu_list = [
			\ 'help',
			\ 'status',
			\ 'save and load',
			\ 'wheel navigation',
			\ 'native navigation',
			\ 'organize wheel',
			\ 'organize native',
			\ 'refactoring',
			\ 'search file',
			\ 'search inside file',
			\ 'yank',
			\ 'undo',
			\ 'command',
			\ 'layout',
			\ 'layout tabs',
			\ 'layout windows',
			\ 'layout mixed',
			\ ]
lockvar! s:menu_list

" ---- main menu

if exists('s:menu_main')
	unlockvar! s:menu_main
endif
let s:menu_main = []
for s:name in s:menu_list
	let s:formated = substitute(s:name, ' ', '_', 'g')
	eval s:menu_main->extend(s:menu_{s:formated})
endfor
lockvar! s:menu_main

" ---- meta menu

if exists('s:menu_meta')
	unlockvar! s:menu_meta
endif
let s:menu_meta = []
for s:name in s:menu_list
	let s:formated = substitute(s:name, ' ', '_', 'g')
	let s:function = 'wheel#helm#submenu(' .. string(s:formated) .. ')'
	eval s:menu_meta->add([s:name, s:function])
endfor
lockvar! s:menu_meta

" ---- contextual menus

if exists('s:context_navigation')
	unlockvar! s:context_navigation
endif
let s:context_navigation = [
			\ ['open' ,  "wheel#boomerang#navigation('here')"],
			\ ['open in tab(s)' ,  "wheel#boomerang#navigation('tab')"],
			\ ['open in horizontal split(s)' ,  "wheel#boomerang#navigation('horizontal_split')"],
			\ ['open in vertical split(s)' ,  "wheel#boomerang#navigation('vertical_split')"],
			\ ['open in horizontal golden split(s)' ,  "wheel#boomerang#navigation('horizontal_golden')"],
			\ ['open in vertical golden split(s)' ,  "wheel#boomerang#navigation('vertical_golden')"],
			\ ]
lockvar! s:context_navigation

if exists('s:context_buffer')
	unlockvar! s:context_buffer
endif
let s:context_buffer = s:context_navigation + [
			\ ['delete' ,  "wheel#boomerang#buffer('delete')"],
			\ ['unload' ,  "wheel#boomerang#buffer('unload')"],
			\ ['wipe' ,  "wheel#boomerang#buffer('wipe')"],
			\ ['delete hidden buffers' ,  "wheel#boomerang#buffer('delete_hidden')"],
			\ ['wipe hidden buffers' ,  "wheel#boomerang#buffer('wipe_hidden')"],
			\ ]
lockvar! s:context_buffer

if exists('s:context_buffer_all')
	unlockvar! s:context_buffer_all
endif
let s:context_buffer_all = s:context_navigation + [
			\ ['delete' ,  "wheel#boomerang#buffer('delete')"],
			\ ['unload' ,  "wheel#boomerang#buffer('unload')"],
			\ ['wipe' ,  "wheel#boomerang#buffer('wipe')"],
			\ ['delete hidden buffers' ,  "wheel#boomerang#buffer('delete_hidden')"],
			\ ['wipe hidden buffers' ,  "wheel#boomerang#buffer('wipe_hidden')"],
			\ ['wipe all hidden buffers, including unlisted ones' ,  "wheel#boomerang#buffer('wipe_all_hidden')"],
			\ ]
lockvar! s:context_buffer_all

if exists('s:context_tabwin')
	unlockvar! s:context_tabwin
endif
let s:context_tabwin = [
			\ ['open' ,  "wheel#boomerang#tabwin('open')"],
			\ ['new tab' ,  "wheel#boomerang#tabwin('tabnew')"],
			\ ['close tab' ,  "wheel#boomerang#tabwin('tabclose')"],
			\ ['reorganize' ,  'wheel#mirror#reorg_tabwin'],
			\ ]
lockvar! s:context_tabwin

if exists('s:context_tabwin_tree')
	unlockvar! s:context_tabwin_tree
endif
let s:context_tabwin_tree = [
			\ ['open' ,  "wheel#boomerang#tabwin_tree('open')"],
			\ ['new tab' ,  "wheel#boomerang#tabwin_tree('tabnew')"],
			\ ['close tab' ,  "wheel#boomerang#tabwin_tree('tabclose')"],
			\ ['reorganize' ,  'wheel#mirror#reorg_tabwin'],
			\ ]
lockvar! s:context_tabwin_tree

if exists('s:context_grep')
	unlockvar! s:context_grep
endif
let s:context_grep = s:context_navigation + [
			\ ['edit mode' ,  "wheel#shadow#grep_edit()"],
			\ ['open quickfix' ,  "wheel#boomerang#grep('quickfix')"],
			\ ]
lockvar! s:context_grep

if exists('s:context_yank_list')
	unlockvar! s:context_yank_list
endif
let s:context_yank_list = [
			\ ['linewise paste before' ,  "wheel#boomerang#yank('linewise-before')"],
			\ ['linewise paste after' ,  "wheel#boomerang#yank('linewise-after')"],
			\ ['characterwise paste before' ,  "wheel#boomerang#yank('charwise-before')"],
			\ ['characterwise paste after' ,  "wheel#boomerang#yank('charwise-after')"],
			\ ['undo' ,  'wheel#codex#undo()'],
			\ ['redo' ,  'wheel#codex#redo()'],
			\ ]
lockvar! s:context_yank_list

if exists('s:context_yank_plain')
	unlockvar! s:context_yank_plain
endif
let s:context_yank_plain = [
			\ ['linewise paste before' ,  "wheel#boomerang#yank('linewise-before')"],
			\ ['linewise paste after' ,  "wheel#boomerang#yank('linewise-after')"],
			\ ['characterwise paste before' ,  "wheel#boomerang#yank('charwise-before')"],
			\ ['characterwise paste after' ,  "wheel#boomerang#yank('charwise-after')"],
			\ ['undo' ,  'wheel#codex#undo()'],
			\ ['redo' ,  'wheel#codex#redo()'],
			\ ]
lockvar! s:context_yank_plain

" ---- public interface

fun! wheel#quartz#fetch (varname, conversion = 'no-conversion')
	" Return script variable called varname
	" The leading s: can be omitted
	" Optional argument :
	"   - no-conversion : simply returns the asked variable, dont convert anything
	"   - dict : if varname points to an items list, convert it to a dictionary
	let varname = a:varname
	let conversion = a:conversion
	" ---- variable name
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	let varname = substitute(varname, ' ', '_', 'g')
	if varname !~ '\m^s:'
		let varname = 's:' .. varname
	endif
	" ---- raw or conversion
	if conversion ==# 'dict'
		return wheel#matrix#items2dict ({varname})
	else
		return {varname}
	endif
endfun
