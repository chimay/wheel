" vim: set ft=vim fdm=indent iskeyword&:

" Mandala
"
" Generic wheel dedicated buffers = mandala buffers
"
" A mandala is made of lines, like a buffer
"
" Sane defaults : may be overriden by more specific buffers
"
" Search, Filter
" Select
" Trigger action

" ---- script constants

if exists('s:map_keys')
	unlockvar s:map_keys
endif
let s:map_keys = wheel#crystal#fetch('map/keys')
lockvar s:map_keys

if exists('s:mandala_autocmds_group')
	unlockvar s:mandala_autocmds_group
endif
let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
lockvar s:mandala_autocmds_group

if exists('s:mandala_autocmds_events')
	unlockvar s:mandala_autocmds_events
endif
let s:mandala_autocmds_events = wheel#crystal#fetch('mandala/autocmds/events')
lockvar s:mandala_autocmds_events

if exists('s:mandala_vars')
	unlockvar s:mandala_vars
endif
let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
lockvar s:mandala_vars

" ---- init

fun! wheel#mandala#init ()
	" Init mandala buffer variables
	" -- general qualities
	if ! exists('b:wheel_nature')
		let b:wheel_nature = {}
		let b:wheel_nature.empty = v:true
		let b:wheel_nature.class = 'generic'
		let b:wheel_nature.type = 'empty'
		let b:wheel_nature.is_treeish = v:false
		let b:wheel_nature.is_writable = v:false
		let b:wheel_nature.has_filter = v:false
		let b:wheel_nature.has_selection = v:false
		let b:wheel_nature.has_preview = v:false
		let b:wheel_nature.has_navigation = v:false
	endif
	" -- related buffer
	if ! exists('b:wheel_related')
		let b:wheel_related = {}
		let b:wheel_related.tabnum = 'undefined'
		let b:wheel_related.winum = 'undefined'
		let b:wheel_related.winiden = 'undefined'
		let b:wheel_related.bufnum = 'undefined'
	endif
	" -- all original lines
	if ! exists('b:wheel_lines')
		let b:wheel_lines = []
	endif
	" -- all original full information
	" -- useful for treeish buffers
	if ! exists('b:wheel_full')
		let b:wheel_full = []
	endif
	" -- filter
	if ! exists('b:wheel_filter')
		let b:wheel_filter = {}
		let b:wheel_filter.words = []
		let b:wheel_filter.indexes = []
		let b:wheel_filter.lines = []
	endif
	" -- selection
	if ! exists('b:wheel_selection')
		let b:wheel_selection = {}
		let b:wheel_selection.indexes = []
		let b:wheel_selection.components = []
	endif
	" -- preview
	if ! exists('b:wheel_preview')
		let b:wheel_preview = {}
		let b:wheel_preview.used = v:false
		let b:wheel_preview.follow = v:false
		let b:wheel_preview.original = {}
	endif
	" -- settings for action on line
	if ! exists('b:wheel_settings')
		let b:wheel_settings = {}
	endif
	" -- reload function
	if ! exists('b:wheel_reload')
		let b:wheel_reload = ''
	endif
	" -- leaf ring
	call wheel#book#init ()
endfun

" ---- refresh

fun! wheel#mandala#refresh ()
	" Refresh mandala buffer : unfilter & deselect all
	" e.g. when reloading
	" -- filter
	let b:wheel_filter = {}
	let b:wheel_filter.words = []
	let b:wheel_filter.indexes = []
	let b:wheel_filter.lines = []
	" -- selection
	let b:wheel_selection = {}
	let b:wheel_selection.indexes = []
	let b:wheel_selection.components = []
endfun

" ---- wrap

fun! wheel#mandala#wrap_up ()
	" Line up, or line 1 -> end of file
	" If fold is closed, take the first line of it
	if &l:foldenable
		let line = foldclosed('.')
		if line < 0
			let line = line('.')
		endif
	else
		let line = line('.')
	endif
	" Wrap
	if line == 1
		call cursor(line('$'), 1)
	else
		normal! k
	endif
	if ! wheel#cylinder#is_mandala ()
		" can also be mapped in regular buffer
		return v:true
	endif
	if b:wheel_preview.follow
		call wheel#orbiter#preview ()
	endif
	return v:true
endfun

fun! wheel#mandala#wrap_down ()
	" Line down, or line end of file -> 1
	" If fold is closed, take the last line of it
	if &l:foldenable
		let line = foldclosedend('.')
		if line < 0
			let line = line('.')
		endif
	else
		let line = line('.')
	endif
	if line == line('$')
		call cursor(1, 1)
	else
		normal! j
	endif
	if ! wheel#cylinder#is_mandala ()
		" can also be mapped in regular buffer
		return v:true
	endif
	if b:wheel_preview.follow
		call wheel#orbiter#preview ()
	endif
	return v:true
endfun

" ---- nature

fun! wheel#mandala#is_empty ()
	" Whether mandala is empty
	return b:wheel_nature.empty
endfun

fun! wheel#mandala#type ()
	" Type of a mandala buffer
	return b:wheel_nature.type
endfun

" ---- clearing things

fun! wheel#mandala#clear_options ()
	" Clear mandala local options
	setlocal nofoldenable
endfun

fun! wheel#mandala#clear_maps ()
	" Clear mandala local maps
	call wheel#ouroboros#unmap(s:map_keys)
endfun

fun! wheel#mandala#clear_autocmds ()
	" Clear mandala local autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	call wheel#ouroboros#clear_autocmds (group, events)
endfun

fun! wheel#mandala#clear_vars ()
	" Clear mandala local variables, except the leaves ring
	call wheel#ouroboros#unlet (s:mandala_vars)
endfun

fun! wheel#mandala#clear ()
	" Clear mandala
	" -- clear state
	call wheel#mandala#clear_options ()
	call wheel#mandala#clear_maps ()
	call wheel#mandala#clear_autocmds ()
	call wheel#mandala#clear_vars ()
	" -- clear lines
	call wheel#mandala#unlock ()
	call wheel#gear#delete (1, '$')
	call wheel#mandala#lock ()
	" -- init vars
	call wheel#mandala#init ()
endfun

" ---- mandala type

fun! wheel#mandala#set_type (type)
	" Set mandala type
	let type = a:type
	let b:wheel_nature.type = type
	if type ==# 'empty'
		let b:wheel_nature.empty = v:true
	else
		let b:wheel_nature.empty = v:false
		call wheel#cylinder#update_type ()
	endif
endfun

" ---- related buffer

fun! wheel#mandala#guess_related ()
	" Guess related buffer
	if wheel#cylinder#is_mandala ()
		return wheel#rectangle#previous ()
	endif
	let related = {}
	let related.tabnum = tabpagenr()
	let related.winum = winnr()
	let related.winiden = win_getid()
	let related.bufnum = bufnr('%')
	return related
endfun

fun! wheel#mandala#goto_related ()
	" Go to window of related buffer if visible, or edit it in first window of tab
	" optional argument :
	"   - buffer number
	"   - default : related buffer number
	" if no optional argument and no related buffer : go to previous window
	if ! wheel#cylinder#is_mandala ()
		return v:false
	endif
	let bufnum = b:wheel_related.bufnum
	if bufnum ==# 'undefined'
		wincmd p
		return 'undefined'
	endif
	call wheel#rectangle#find_or_load (bufnum)
	return bufnum
endfun

" ---- options

fun! wheel#mandala#unlock ()
	" Set local options to be able to edit mandala
	setlocal noreadonly
	setlocal modifiable
endfun

fun! wheel#mandala#lock ()
	" Set local options to prevent mandala edition
	setlocal readonly
	setlocal nomodifiable
endfun

fun! wheel#mandala#post_edit (lock = 'lock')
	" Restore local options after edition
	"   Optional argument :
	"   - lock : relock if not writable
	"   - dont-lock : don't lock
	let lock = a:lock
	if lock ==# 'dont-lock'
		return v:true
	endif
	if ! wheel#polyphony#is_writable ()
		call wheel#mandala#lock ()
	endif
	return v:true
endfun

fun! wheel#mandala#common_options ()
	" Set local common options
	setlocal filetype=wheel
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal nobuflisted
	setlocal noswapfile
	setlocal cursorline
	setlocal nofoldenable
	" non writable by default
	call wheel#mandala#lock ()
endfun

" ---- mappings

fun! wheel#mandala#common_maps ()
	" Define mandala common maps
	" ---- normal mode
	" -- help
	nnoremap <buffer> <nowait> <f1> <cmd>call wheel#guru#mandala()<cr>
	nnoremap <buffer> <nowait> <f2> <cmd>call wheel#guru#mandala_mappings()<cr>
	" -- quit
	nnoremap <buffer> q      <cmd>call wheel#cylinder#close()<cr>
	" -- movement
	nnoremap <buffer> j      <cmd>call wheel#mandala#wrap_down()<cr>
	nnoremap <buffer> k      <cmd>call wheel#mandala#wrap_up()<cr>
	nnoremap <buffer> <down> <cmd>call wheel#mandala#wrap_down()<cr>
	nnoremap <buffer> <up>   <cmd>call wheel#mandala#wrap_up()<cr>
	" -- reload mandala
	nnoremap <buffer> r      <cmd>call wheel#mandala#reload ()<cr>
	" -- rename mandala
	nnoremap <buffer> <m-n>  <cmd>call wheel#cylinder#rename ()<cr>
	" -- navigate in leaf ring
	nnoremap <buffer> <m-j>       <cmd>call wheel#book#forward ()<cr>
	nnoremap <buffer> <m-k>       <cmd>call wheel#book#backward ()<cr>
	nnoremap <buffer> <m-down>    <cmd>call wheel#book#forward ()<cr>
	nnoremap <buffer> <m-up>      <cmd>call wheel#book#backward ()<cr>
	nnoremap <buffer> <m-l>       <cmd>call wheel#book#switch ()<cr>
	nnoremap <buffer> <c-down>    <cmd>call wheel#book#switch ()<cr>
	nnoremap <buffer> <backspace> <cmd>call wheel#book#delete ()<cr>
endfun

" ---- template

fun! wheel#mandala#template (...)
	" Template with filter & input history
	" No selection, preview or fold
	if a:0 > 0
		let b:wheel_settings = a:1
	endif
	call wheel#mandala#common_maps ()
	" filter
	call wheel#teapot#mappings ()
	" input history
	call wheel#scroll#mappings ()
endfun

" ---- blank sheet

fun! wheel#mandala#blank (type)
	" Open a mandala buffer, add new blank leaf if needed
	let type = a:type
	" ---- create / open current mandala
	if ! wheel#cylinder#recall()
		call wheel#cylinder#first ()
	endif
	" ---- add new leaf, clear mandala, set type & options
	call wheel#book#add ('clear')
	call wheel#mandala#set_type (type)
	call wheel#mandala#common_options ()
	" ---- set related buffer
	let b:wheel_related = wheel#mandala#guess_related ()
endfun

" ---- content

fun! wheel#mandala#set_var_lines ()
	" Set lines in local mandala variables, from visible lines
	" Affected :
	"   - b:wheel_lines
	let start = wheel#teapot#first_data_line ()
	let lines = getline(start, '$')
	let b:wheel_lines = lines
	return v:true
endfun

fun! wheel#mandala#replace (content, first = 'empty-prompt-first', lock = 'lock')
	" Replace mandala buffer with content
	" Content can be :
	"   - a monoline string
	"   - a list of lines
	" Optional arguments :
	"   - first handle the first line filtering input :
	"     + empty-prompt-first (default) : blank first line with just a prompt
	"     + prompt-first : keep input, add prompt if not present
	"     + keep-first  : keep first line
	"     + delete-first : delete first line
	"   - lock :
	"     + lock : relock if not writable
	"     + dont-lock : don't lock
	if ! wheel#cylinder#is_mandala ()
		echomsg 'wheel mandala fill : not in mandala buffer'
	endif
	" ---- arguments
	let content = a:content
	let first = a:first
	let lock = a:lock
	" ---- cursor
	let position = getcurpos()
	" ---- options to edit
	call wheel#mandala#unlock ()
	" ---- delete old content
	call wheel#gear#delete (2, '$')
	" ---- append content
	call cursor(1, 1)
	call append('.', content)
	" ---- first line
	if first ==# 'prompt-first'
		call wheel#teapot#set_prompt (getline(1), lock)
	elseif first ==# 'empty-prompt-first'
		call wheel#teapot#set_prompt ('', lock)
	elseif  first ==# 'keep-first'
		call wheel#mandala#post_edit (lock)
	elseif first ==# 'delete-first'
		call wheel#gear#delete (1)
		call wheel#mandala#post_edit (lock)
	endif
	" ---- tell (neo)vim the buffer is unmodified
	setlocal nomodified
	" ---- restore cursor if possible, else place it on line 1
	call wheel#gear#restore_cursor (position, 1)
endfun

fun! wheel#mandala#fill (content, first = 'empty-prompt-first')
	" Fill mandala buffer with content
	" Arguments : see mandala#replace
	" ---- replace old content, fill if empty
	call wheel#mandala#replace(a:content, a:first)
	" -- fill b:wheel_lines
	call wheel#mandala#set_var_lines ()
	" ---- cursor on first data line
	let first_data_line = wheel#teapot#first_data_line ()
	if line('$') > 1
		call cursor(first_data_line, 1)
	endif
	" ---- folding, to save with syncup
	call wheel#origami#close ()
	call wheel#origami#view_cursor ()
	" ---- sync mandala -> leaf ring
	call wheel#book#syncup ()
	call wheel#status#mandala_leaf ()
endfun

" ---- relaad

fun! wheel#mandala#reload_string (function, ...)
	" Reload string
	let function = a:function
	let arguments = a:000
	" ---- no argument
	if empty(arguments)
		let reload = function
		return reload
	endif
	" ---- with argument(s)
	let length = len(arguments)
	let reload = function .. '('
	for index in range(length - 1)
		let reload ..= string(arguments[index]) .. ', '
	endfor
	let reload ..= string(arguments[-1]) .. ')'
	return reload
endfun

fun! wheel#mandala#set_reload(...)
	" Set reload in local variable
	if a:0 == 0
		echomsg 'wheel mandala set_reload : need at least one argument'
		return ''
	endif
	let reload = call('wheel#mandala#reload_string', a:000)
	let b:wheel_reload = reload
	return reload
endfun

fun! wheel#mandala#reload ()
	" Reload current mandala
	" ---- save type
	let type = b:wheel_nature.type
	" ---- mark the buffer as empty, to avoid adding a leaf in mandala#blank
	call wheel#mandala#set_type ('empty')
	" ---- reinitialize buffer vars
	call wheel#mandala#refresh ()
	" ---- reload content
	if ! empty(b:wheel_reload)
		let function = b:wheel_reload
		call wheel#metafun#call (function)
		call wheel#status#message('wheel :', function, 'reloaded')
	else
		" if b:wheel_reload is empty, replace the buffer with b:wheel_lines
		call wheel#mandala#replace (b:wheel_lines)
		" restore type
		call wheel#mandala#set_type (type)
		echomsg 'wheel : content reloaded'
	endif
endfun

" ---- generic commands

fun! wheel#mandala#command (...)
	" Generic ex or shell command
	" for shell command, just begin with !
	if a:0 > 0
		let command = a:1
	else
		let command = input('Ex or !shell command : ')
	endif
	if command[0] ==# '!'
		let command = command[1:]
		let current = getreg('%')
		let alter = getreg('#')
		let command = substitute(command, ' %', ' ' .. current, 'g')
		let command = substitute(command, ' #', ' ' .. alter, 'g')
		let command = substitute(command, '\~', $HOME, 'g')
		let lines = wheel#flower#execute (command, 'system')
	else
		let lines = wheel#flower#execute (command)
	endif
	call wheel#mandala#blank ('command')
	call wheel#mandala#template ()
	call wheel#mandala#fill (lines)
endfun

fun! wheel#mandala#async ()
	" Async command with output in wheel buffer
	if a:0 > 0
		let command = a:1
	else
		let prompt = 'async shell command : '
		let complete = 'customlist,wheel#complete#file'
		let command = input(prompt, '', complete)
	endif
	if empty(command)
		return v:false
	endif
	let current = getreg('%')
	let alter = getreg('#')
	let command = substitute(command, ' %', ' ' .. current, 'g')
	let command = substitute(command, ' #', ' ' .. alter, 'g')
	let command = substitute(command, '\~', $HOME, 'g')
	if has('nvim')
		let job = wheel#wave#start(command)
	else
		let job = wheel#ripple#start(command)
	endif
	return v:true
endfun
