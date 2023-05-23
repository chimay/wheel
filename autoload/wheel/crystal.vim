" vim: set ft=vim fdm=indent iskeyword&:

" Crystal
"
" Internal Constants made crystal clear

" Dictionaries are defined as list of items to preserve the order
" of keys.
"
" Useful for menus & context menus

" ---- golden ratio

if exists('s:golden_ratio')
	unlockvar! s:golden_ratio
endif
let s:golden_ratio = 1.618034
"let s:golden_ratio = (1 + sqrt(5)) / 2
lockvar! s:golden_ratio

" ---- various patterns

if exists('s:pattern_vowels')
	unlockvar! s:pattern_vowels
endif
let s:pattern_vowels = '[[=a=][=e=][=i=][=o=][=u=][=y=]]'
lockvar! s:pattern_vowels

" ---- wheel levels

if exists('s:referen_levels')
	unlockvar! s:referen_levels
endif
let s:referen_levels = ['wheel', 'torus', 'circle', 'location']
lockvar! s:referen_levels

if exists('s:referen_coordinates_levels')
	unlockvar! s:referen_coordinates_levels
endif
let s:referen_coordinates_levels = ['torus', 'circle', 'location']
lockvar! s:referen_coordinates_levels

if exists('s:referen_list_keys')
	unlockvar! s:referen_list_keys
endif
let s:referen_list_keys = {
			\ 'wheel' : 'toruses',
			\ 'torus' : 'circles',
			\ 'circle' : 'locations',
			\ }
lockvar! s:referen_list_keys

" ---- vim modes

if exists('s:modes_letters')
	unlockvar! s:modes_letters
endif
let s:modes_letters = {
			\ 'normal'   : 'n',
			\ 'insert'   : 'i',
			\ 'replace'  : 'r',
			\ 'visual'   : 'v',
			\ 'operator' : 'o',
			\ 'command'  : 'c',
			\ }
lockvar! s:modes_letters

if exists('s:letters_modes')
	unlockvar! s:letters_modes
endif
let s:letters_modes = {
			\ 'n' : 'normal',
			\ 'i' : 'insert',
			\ 'r' : 'replace' ,
			\ 'v' : 'visual',
			\ 'o' : 'operator',
			\ 'c' : 'command' ,
			\ }
lockvar! s:letters_modes

" ---- register

if exists('s:registers_symbols')
	unlockvar! s:registers_symbols
endif
let s:registers_symbols = [
			\ ['unnamed'    , '"'] ,
			\ ['clipboard'  , '+'] ,
			\ ['primary'    , '*'] ,
			\ ['small'      , '-'] ,
			\ ['inserted'   , '.'] ,
			\ ['search'     , '/'] ,
			\ ['command'    , ':'] ,
			\ ['expression' , '='] ,
			\ ['file'       , '%'] ,
			\ ['alternate'  , '#'] ,
			\ ]
lockvar! s:registers_symbols

if exists('s:symbols_registers')
	unlockvar! s:symbols_registers
endif
let s:symbols_registers = [
			\ ['"' , 'unnamed'    ] ,
			\ ['+' , 'clipboard'  ] ,
			\ ['*' , 'primary'    ] ,
			\ ['-' , 'small'      ] ,
			\ ['.' , 'inserted'   ] ,
			\ ['/' , 'search'     ] ,
			\ [':' , 'command'    ] ,
			\ ['=' , 'expression' ] ,
			\ ['%' , 'file'       ] ,
			\ ['#' , 'alternate'  ] ,
			\ ]
lockvar! s:symbols_registers

" ---- signs

if exists('s:sign_name')
	unlockvar! s:sign_name
endif
let s:sign_name = 'wheel-sign-location'
lockvar! s:sign_name

if exists('s:sign_name_native')
	unlockvar! s:sign_name_native
endif
let s:sign_name_native = 'wheel-sign-native'
lockvar! s:sign_name_native

if exists('s:sign_group')
	unlockvar! s:sign_group
endif
let s:sign_group = 'wheel-sign-group-location'
lockvar! s:sign_group

if exists('s:sign_group_native')
	unlockvar! s:sign_group_native
endif
let s:sign_group_native = 'wheel-sign-group-native'
lockvar! s:sign_group_native

if exists('s:sign_text')
	unlockvar! s:sign_text
endif
let s:sign_text = '☯'
" sign text must be 2 chars or a space will be added by vim
" an extra space is added by chakra#define to avoid confusion
lockvar! s:sign_text

if exists('s:sign_text_native')
	unlockvar! s:sign_text_native
endif
let s:sign_text_native = '✻'
lockvar! s:sign_text_native

if exists('s:sign_settings')
	unlockvar! s:sign_settings
endif
let s:sign_settings = #{
			\ text : s:sign_text,
			\ }
lockvar! s:sign_settings

if exists('s:sign_settings_native')
	unlockvar! s:sign_settings_native
endif
let s:sign_settings_native = #{
			\ text : s:sign_text_native,
			\ }
lockvar! s:sign_settings_native

" ---- functions

if exists('s:function_generator_wheel')
	unlockvar! s:function_generator_wheel
endif
let s:function_generator_wheel = [
			\ 'execute',
			\ 'element',
			\ 'rename',
			\ 'rename_file',
			\ 'helix',
			\ 'grid',
			\ 'tree',
			\ 'reorganize',
			\ 'history',
			\ 'history_circuit',
			\ 'frecency',
			\ ]
lockvar! s:function_generator_wheel

if exists('s:function_generator_native')
	unlockvar! s:function_generator_native
endif
let s:function_generator_native = [
			\ 'tabwin',
			\ 'tabwin_tree',
			\ 'find',
			\ 'locate',
			\ 'mru',
			\ 'occur',
			\ 'marker',
			\ 'jump',
			\ 'change',
			\ 'grep',
			\ 'narrow_file',
			\ 'narrow_circle',
			\ 'tag',
			\ 'yank_prompt',
			\ 'yank_mandala',
			\ 'undolist',
			\ ]
lockvar! s:function_generator_native

if exists('s:function_write_wheel')
	unlockvar! s:function_write_wheel
endif
let s:function_write_wheel = [
			\ 'reorder',
			\ 'rename',
			\ 'rename_file',
			\ 'delete',
			\ 'copy_move',
			\ 'reorganize',
			\ ]
lockvar! s:function_write_wheel

if exists('s:function_write_native')
	unlockvar! s:function_write_native
endif
let s:function_write_native = [
			\ 'grep_edit',
			\ 'narrow_file',
			\ 'narryow_circle',
			\ 'reorg_tabwin',
			\ ]
lockvar! s:function_write_native

if exists('s:function_pattern_navigation')
	unlockvar! s:function_pattern_navigation
endif
let s:function_pattern_navigation = [
			\ '\m#vortex#',
			\ '\m#waterclock#',
			\ '\m#whirl#',
			\ '\m#sailing#',
			\ '\m#frigate#',
			\ '\m#pendulum#',
			\ ]
lockvar! s:function_pattern_navigation

if exists('s:function_pattern_mandala_opens')
	unlockvar! s:function_pattern_mandala_opens
endif
let s:function_pattern_mandala_opens = [
			\ '\m#mandala#',
			\ '\m#helm#',
			\ '\m#guru#',
			\ '\m#whirl#',
			\ '\m#frigate#',
			\ '\m#yggdrasil#',
			\ '\m#mirror#',
			\ '\m#shadow#',
			\ '\m#codex#',
			\ '\m#clipper#',
			\ '\m#triangle#',
			\ ]
" functions that uses mandala
lockvar! s:function_pattern_mandala_opens

if exists('s:function_pattern_mandala_needs')
	unlockvar! s:function_pattern_mandala_needs
endif
let s:function_pattern_mandala_needs = [
			\ '\m#boomerang#\%(navigation\|tabwin\)\@!',
			\ "\m#boomerang#tabwin('tabclose')",
			\ ]
lockvar! s:function_pattern_mandala_needs

" ---- mandalas

" -- mandala prompt

if exists('s:mandala_prompt')
	unlockvar! s:mandala_prompt
endif
let s:mandala_prompt = '☯ '
lockvar! s:mandala_prompt

if exists('s:mandala_prompt_writable')
	unlockvar! s:mandala_prompt_writable
endif
let s:mandala_prompt_writable = '☈ '
lockvar! s:mandala_prompt_writable

" -- mandala patterns

if exists('s:is_mandala_file')
	unlockvar! s:is_mandala_file
endif
let s:is_mandala_file = '\m^/wheel/[0-9]\+'
lockvar! s:is_mandala_file

if exists('s:is_buffer_tabs')
	unlockvar! s:is_buffer_tabs
endif
" for output line of :tabs
let s:is_buffer_tabs = '\m^\%(\s\|>\|#\)'
lockvar! s:is_buffer_tabs

if exists('s:is_mandala_tabs')
	unlockvar! s:is_mandala_tabs
endif
" for output line of :tabs
let s:is_mandala_tabs = '\m^>\?\s*+\?\s*' .. s:is_mandala_file
lockvar! s:is_mandala_tabs

" -- mandalas options

if exists('s:mandala_options')
	unlockvar! s:mandala_options
endif
let s:mandala_options = [
			\ 'filetype',
			\ 'buftype',
			\ 'bufhidden',
			\ 'buflisted',
			\ 'swapfile',
			\ 'cursorline',
			\ 'readonly',
			\ 'modifiable',
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
lockvar! s:mandala_options

" -- mandalas maps

if exists('s:normal_map_keys')
	unlockvar! s:normal_map_keys
endif
let s:normal_map_keys = [
			\ '<f1>', 'r', 'q',
			\ '<cr>', 'g<cr>',
			\ 'j', 'k', '<down>', '<up>',
			\ '<space>', '=', '#', '*', '<bar>',
			\ 'i', 'a', '<m-i>', '<ins>', 'cc', 'dd', '<m-d>',
			\ 'f',
			\ '<m-j>', '<m-k>', '<m-l>',
			\ '<tab>',
			\ 't', 'h', 'v', 'H', 'V',
			\ 'gt', 'gh', 'gv', 'gH', 'gV',
			\ '<leader>w', '<leader>W',
			\ '<m-t>', '<m-h>', '<m-v>', '<m-s-h>', '<m-s-v>',
			\ 'g<m-t>', 'g<m-h>', 'g<m-v>', 'g<m-s-h>', 'g<m-s-v>',
			\ '<m-s>', '<m-r>',
			\ '<m-c>', 'o', 'O', '<m-y>', '<m-z>', '^', '$',
			\ 's', 'p', 'P', 'gp', 'gP',
			\ 'u', '<c-r>', '+', '-', '<kplus>', '<kminus>', 'D', 'x',
			\ '<c-s>',
			\ ]
lockvar! s:normal_map_keys

if exists('s:insert_map_keys')
	unlockvar! s:insert_map_keys
endif
let s:insert_map_keys = [
			\ '<space>', '<c-w>', '<c-u>',
			\ '<m-f>', '<m-b>', '<c-a>', '<c-e>', '<m-a>', '<m-e>',
			\ '<esc>', '<cr>',
			\ '<up>', '<down>', '<m-p>', '<m-n>',
			\ '<pageup>', '<pagedown>', '<m-r>', '<m-s>',
			\ ]
lockvar! s:insert_map_keys

if exists('s:visual_map_keys')
	unlockvar! s:visual_map_keys
endif
let s:visual_map_keys = [
			\ '<cr>',
			\ 'p', 'P',
			\  'g<cr>',
			\ 'gp', 'gP',
			\ ]
lockvar! s:visual_map_keys

if exists('s:map_keys')
	unlockvar! s:map_keys
endif
let s:map_keys = {
			\ 'normal' : s:normal_map_keys,
			\ 'insert' : s:insert_map_keys,
			\ 'visual' : s:visual_map_keys,
			\ }
lockvar! s:map_keys

" -- mandala autocmds

if exists('s:mandala_autocmds_group')
	unlockvar! s:mandala_autocmds_group
endif
let s:mandala_autocmds_group = 'wheel-mandala'
lockvar! s:mandala_autocmds_group

if exists('s:mandala_autocmds_events')
	unlockvar! s:mandala_autocmds_events
endif
let s:mandala_autocmds_events = [
			\ 'BufWriteCmd',
			\ ]
lockvar! s:mandala_autocmds_events

" -- mandalas variables

if exists('s:mandala_vars')
	unlockvar! s:mandala_vars
endif
let s:mandala_vars = [
			\ 'b:wheel_nature',
			\ 'b:wheel_related',
			\ 'b:wheel_lines',
			\ 'b:wheel_full',
			\ 'b:wheel_filter',
			\ 'b:wheel_selection',
			\ 'b:wheel_settings',
			\ 'b:wheel_reload',
			\ ]
lockvar! s:mandala_vars

" -- folds in mandalas

if exists('s:fold_markers')
	unlockvar! s:fold_markers
endif
let s:fold_markers = ['▷', '◁']
"let s:fold_markers = ['>', '<']
lockvar! s:fold_markers

if exists('s:fold_one')
	unlockvar! s:fold_one
endif
let s:fold_one = ' ' .. s:fold_markers[0] .. '1'
lockvar! s:fold_one

if exists('s:fold_two')
	unlockvar! s:fold_two
endif
let s:fold_two = ' ' .. s:fold_markers[0] .. '2'
lockvar! s:fold_two

if exists('s:fold_pattern')
	unlockvar! s:fold_pattern
endif
let s:fold_pattern = '\m' .. s:fold_markers[0] .. '[12]$'
lockvar! s:fold_pattern

" -- separators

if exists('s:separator_field')
	unlockvar! s:separator_field
endif
let s:separator_field = ' │ '
" digraph : in insert mode : ctrl-k vv -> │ != usual | == <bar>
lockvar! s:separator_field

if exists('s:separator_field_bar')
	unlockvar! s:separator_field_bar
endif
let s:separator_field_bar = '│'
" digraph : ctrl-k vv ->
lockvar! s:separator_field_bar

if exists('s:separator_level')
	unlockvar! s:separator_level
endif
let s:separator_level = ' ⧽ '
lockvar! s:separator_level

" -- selections in mandalas

if exists('s:selection_mark')
	unlockvar! s:selection_mark
endif
let s:selection_mark = '☰ '
lockvar! s:selection_mark

" -- targets in mandalas

if exists('s:mandala_targets')
	unlockvar! s:mandala_targets
endif
let s:mandala_targets = [
			\ 'here',
			\ 'tab',
			\ 'horizontal_split',
			\ 'vertical_split',
			\ 'horizontal_golden',
			\ 'vertical_golden',
			\ ]
lockvar! s:mandala_targets

" ---- public interface

fun! wheel#crystal#clear (varname)
	" Unlet script variable called varname
	let varname = a:varname
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	let varname = substitute(varname, ' ', '_', 'g')
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
