" vim: set ft=vim fdm=indent iskeyword&:

" Crystal
"
" Internal Constants made crystal clear

" Dictionaries are defined as list of items to preserve the order
" of keys.
"
" Useful for menus & context menus

" ---- wheel levels

if ! exists('s:referen_levels')
	if exists(':const')
		const s:referen_levels = ['wheel', 'torus', 'circle', 'location']
	else
		let s:referen_levels = ['wheel', 'torus', 'circle', 'location']
		lockvar! s:referen_levels
	endif
endif

if ! exists('s:referen_coordinates_levels')
	let s:referen_coordinates_levels = ['torus', 'circle', 'location']
	lockvar! s:referen_coordinates_levels
endif

if ! exists('s:referen_list_keys')
	let s:referen_list_keys = {
				\ 'wheel' : 'toruses',
				\ 'torus' : 'circles',
				\ 'circle' : 'locations',
				\ }
	lockvar! s:referen_list_keys
endif

" ---- golden ratio

if ! exists('s:golden_ratio')
	let s:golden_ratio = 1.618034
	"let s:golden_ratio = (1 + sqrt(5)) / 2
	lockvar! s:golden_ratio
endif

" ---- vim modes

if ! exists('s:modes_letters')
	let s:modes_letters = {
				\ 'normal'   : 'n',
				\ 'insert'   : 'i',
				\ 'replace'  : 'r',
				\ 'visual'   : 'v',
				\ 'operator' : 'o',
				\ 'command'  : 'c',
				\ }
	lockvar! s:modes_letters
endif

if ! exists('s:letters_modes')
	let s:letters_modes = {
				\ 'n' : 'normal',
				\ 'i' : 'insert',
				\ 'r' : 'replace' ,
				\ 'v' : 'visual',
				\ 'o' : 'operator',
				\ 'c' : 'command' ,
				\ }
	lockvar! s:letters_modes
endif

" ---- register

if ! exists('s:registers_symbols')
	let s:registers_symbols = [
				\ ['default'    , '"'] ,
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
endif

if ! exists('s:symbols_registers')
	let s:symbols_registers = [
				\ ['"' , 'default'    ] ,
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
endif

" ---- signs

if ! exists('s:sign_name')
	let s:sign_name = 'wheel-sign-name'
	lockvar! s:sign_name
endif

if ! exists('s:sign_group')
	let s:sign_group = 'wheel-sign-group'
	lockvar! s:sign_group
endif

if ! exists('s:sign_text')
	let s:sign_text = '☯'
	" sign text must be 2 chars or a space will be added by vim
	" an extra space is added by chakra#define to avoid confusion
	lockvar! s:sign_text
endif

if ! exists('s:sign_settings')
	let s:sign_settings = #{
				\ text : s:sign_text,
				\ }
	lockvar! s:sign_settings
endif

" ---- functions

if ! exists('s:function_pattern_navigation')
	let s:function_pattern_navigation = [
				\ '\m#vortex#',
				\ '\m#whirl#',
				\ '\m#sailing#',
				\ '\m#frigate#',
				\ '\m#pendulum#',
				\]
	lockvar! s:function_pattern_navigation
endif

if ! exists('s:function_pattern_mandala_opens')
	let s:function_pattern_mandala_opens = [
				\ '\m#mandala#',
				\ '\m#helm#',
				\ '\m#guru#',
				\ '\m#whirl#',
				\ '\m#frigate#',
				\ '\m#yggdrasil#',
				\ '\m#mirror#',
				\ '\m#shadow#',
				\ '\m#clipper#',
				\ '\m#triangle#',
				\]
	" functions that uses mandala
	lockvar! s:function_pattern_mandala_opens
endif

if ! exists('s:function_pattern_mandala_needs')
	let s:function_pattern_mandala_needs = [
				\ '\m#boomerang#\%(navigation\|tabwin\)\@!',
				\ "\m#boomerang#tabwin('tabclose')",
				\]
	lockvar! s:function_pattern_mandala_needs
endif

" ---- mandalas

" -- mandala prompt

if ! exists('s:mandala_prompt')
	let s:mandala_prompt = '☯ '
	lockvar! s:mandala_prompt
endif

if ! exists('s:mandala_prompt_writable')
	let s:mandala_prompt_writable = '☈ '
	lockvar! s:mandala_prompt_writable
endif

" -- mandala patterns

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = '\m^/wheel/[0-9]\+'
	lockvar! s:is_mandala_file
endif

if ! exists('s:is_buffer_tabs')
	" for output line of :tabs
	let s:is_buffer_tabs = '\m^\%(\s\|>\|#\)'
	lockvar! s:is_buffer_tabs
endif

if ! exists('s:is_mandala_tabs')
	" for output line of :tabs
	let s:is_mandala_tabs = '\m^>\?\s*+\?\s*' .. s:is_mandala_file
	lockvar! s:is_mandala_tabs
endif

" -- mandalas options

if ! exists('s:mandala_options')
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
endif

" -- mandalas maps

if ! exists('s:normal_map_keys')
	let s:normal_map_keys = [
				\ '<f1>', 'r', 'q',
				\ '<cr>', 'g<cr>',
				\ 'j', 'k', '<down>', '<up>',
				\ '<space>', '=', '#', '*', '<bar>',
				\ 'i', 'a', '<m-i>', '<ins>', 'cc', 'dd',
				\ 'f',
				\ '<m-j>', '<m-k>', '<m-l>',
				\ '<tab>',
				\ 't', 'h', 'v', 'H', 'V',
				\ 'gt', 'gh', 'gv', 'gH', 'gV',
				\ '<leader>w', '<leader>W',
				\ '<m-t>', '<m-h>', '<m-v>', '<m-s-h>', '<m-s-v>',
				\ 'g<m-t>', 'g<m-h>', 'g<m-v>', 'g<m-s-h>', 'g<m-s-v>',
				\ '<m-s>', '<m-r>',
				\ 'o', 'O', '<m-y>', '<m-z>', '^', '$',
				\ 's', 'p', 'P', 'gp', 'gP',
				\ 'u', '<c-r>', '+', '-', '<kplus>', '<kminus>', 'D', 'x',
				\ '<c-s>',
				\ ]
	lockvar! s:normal_map_keys
endif

if ! exists('s:insert_map_keys')
	let s:insert_map_keys = [
				\ '<space>', '<c-w>', '<c-u>',
				\ '<esc>', '<cr>',
				\ '<up>', '<down>', '<m-p>', '<m-n>',
				\ '<pageup>', '<pagedown>', '<m-r>', '<m-s>',
				\ ]
	lockvar! s:insert_map_keys
endif

if ! exists('s:visual_map_keys')
	let s:visual_map_keys = [
				\ '<cr>',
				\ 'p', 'P',
				\  'g<cr>',
				\ 'gp', 'gP',
				\ ]
	lockvar! s:visual_map_keys
endif

if ! exists('s:map_keys')
	let s:map_keys = {
				\ 'normal' : s:normal_map_keys,
				\ 'insert' : s:insert_map_keys,
				\ 'visual' : s:visual_map_keys,
				\ }
	lockvar! s:map_keys
endif

" -- mandala autocmds

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = 'wheel-mandala'
	lockvar! s:mandala_autocmds_group
endif

if ! exists('s:mandala_autocmds_events')
	let s:mandala_autocmds_events = [
				\ 'BufWriteCmd',
				\ ]
	lockvar! s:mandala_autocmds_events
endif

" -- mandalas variables

if ! exists('s:mandala_vars')
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
endif

" -- folds in mandalas

if ! exists('s:fold_markers')
	let s:fold_markers = ['▷', '◁']
	lockvar! s:fold_markers
endif

if ! exists('s:fold_one')
	let s:fold_one = ' ' .. s:fold_markers[0] .. '1'
	lockvar! s:fold_one
endif

if ! exists('s:fold_two')
	let s:fold_two = ' ' .. s:fold_markers[0] .. '2'
	lockvar! s:fold_two
endif

if ! exists('s:fold_pattern')
	let s:fold_pattern = '\m' .. s:fold_markers[0] .. '[12]$'
	lockvar! s:fold_pattern
endif

" -- separators in mandalas

if ! exists('s:separator_field')
	let s:separator_field = ' │ '
	" digraph : in insert mode : ctrl-k vv -> │ != usual | == <bar>
	lockvar! s:separator_field
endif

if ! exists('s:separator_field_bar')
	let s:separator_field_bar = '│'
	" digraph : ctrl-k vv ->
	lockvar! s:separator_field_bar
endif

if ! exists('s:separator_level')
	let s:separator_level = ' ⧽ '
	lockvar! s:separator_level
endif

" -- selections in mandalas

if ! exists('s:selection_mark')
	let s:selection_mark = '☰ '
	lockvar! s:selection_mark
endif

" -- targets in mandalas

if ! exists('s:mandala_targets')
	let s:mandala_targets = [
				\ 'current',
				\ 'tab',
				\ 'horizontal_split',
				\ 'vertical_split',
				\ 'horizontal_golden',
				\ 'vertical_golden',
				\]
	lockvar! s:mandala_targets
endif

" ---- undo & diff

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
	lockvar! s:diff_options
endif

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
	" ---- delegate to quartz for mandala menus
	if ! exists(varname)
		return wheel#quartz#fetch (varname, conversion)
	endif
	" ---- raw or conversion
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
