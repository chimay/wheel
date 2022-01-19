" vim: set ft=vim fdm=indent iskeyword&:

" Generic wheel dedicated buffers = mandala buffers
"
" A mandala is made of lines, like a buffer
"
" Sane defaults : may be overriden by more specific buffers
"
" Search, Filter
" Select
" Trigger action

" Script constants

if ! exists('s:map_keys')
	let s:map_keys = wheel#crystal#fetch('map/keys')
	lockvar s:map_keys
endif

if ! exists('s:mandala_autocmds_group')
	let s:mandala_autocmds_group = wheel#crystal#fetch('mandala/autocmds/group')
	lockvar s:mandala_autocmds_group
endif

if ! exists('s:mandala_autocmds_events')
	let s:mandala_autocmds_events = wheel#crystal#fetch('mandala/autocmds/events')
	lockvar s:mandala_autocmds_events
endif

if ! exists('s:mandala_vars')
	let s:mandala_vars = wheel#crystal#fetch('mandala/vars')
	lockvar s:mandala_vars
endif

if ! exists('s:is_mandala_file')
	let s:is_mandala_file = wheel#crystal#fetch('is_mandala_file')
	lockvar s:is_mandala_file
endif

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

" wrap

fun! wheel#mandala#wrap_up ()
	" Line up, or line 1 -> end of file
	" If fold is closed, take the first line of it
	if &foldenable
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
endfun

fun! wheel#mandala#wrap_down ()
	" Line down, or line end of file -> 1
	" If fold is closed, take the last line of it
	if &foldenable
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
endfun

" mandala pseudo filename

fun! wheel#mandala#pseudo (type)
	" Return pseudo filename /wheel/<buf-id>/<type>
	let current = g:wheel_mandalas.current
	let iden = g:wheel_mandalas.iden[current]
	let type = a:type
	let pseudo = '/wheel/' .. iden .. '/' .. type
	return pseudo
endfun

fun! wheel#mandala#filename (type)
	" Set type & buffer filename to pseudo filename
	" Useful as information
	" We also need a name when writing, even with BufWriteCmd
	let type = a:type
	let b:wheel_nature.type = type
	" Add unique buf id, so (n)vim does not complain about existing filename
	let pseudo = wheel#mandala#pseudo (type)
	if bufexists(pseudo)
		" almost certainly an old mandala, it should be safe to wipe it
		execute 'silent bwipe' pseudo
	endif
	execute 'silent file' pseudo
	if type != 'empty'
		" should be false when called
		" set to true in wheel#mandala#set_empty
		let b:wheel_nature.empty = v:false
	endif
endfun

" nature

fun! wheel#mandala#set_empty ()
	" Tell wheel to consider this mandala as an empty buffer
	call wheel#mandala#filename ('empty')
	" has to be placed after mandala#filename
	let b:wheel_nature.empty = v:true
endfun

fun! wheel#mandala#is_empty ()
	" Whether mandala is empty
	return b:wheel_nature.empty
endfun

fun! wheel#mandala#type ()
	" Type of a mandala buffer
	return b:wheel_nature.type
endfun

" init

fun! wheel#mandala#init ()
	" Init mandala buffer variables
	" -- general qualities
	if ! exists('b:wheel_nature')
		let b:wheel_nature = {}
		let b:wheel_nature.empty = v:true
		let b:wheel_nature.type = 'empty'
		let b:wheel_nature.has_filter = v:false
		let b:wheel_nature.has_selection = v:false
		call wheel#mandala#filename ('empty')
	endif
	" -- related buffer
	if ! exists('b:wheel_related_buffer')
		let b:wheel_related_buffer = 'undefined'
	endif
	" -- all original lines
	if ! exists('b:wheel_lines')
		let b:wheel_lines = []
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
		let b:wheel_selection.addresses = []
	endif
	" -- settings for action on line
	if ! exists('b:wheel_settings')
		let b:wheel_settings = {}
	endif
	" reload function
	if ! exists('b:wheel_reload')
		let b:wheel_reload = ''
	endif
	" leaf ring
	call wheel#book#init ()
endfun

" refresh

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
	let b:wheel_selection.addresses = []
endfun

" clearing things

fun! wheel#mandala#clear_options ()
	" Clear mandala local options
	setlocal nofoldenable
endfun

fun! wheel#mandala#clear_maps ()
	" Clear mandala local maps
	call wheel#gear#unmap(s:map_keys)
endfun

fun! wheel#mandala#clear_autocmds ()
	" Clear mandala local autocommands
	let group = s:mandala_autocmds_group
	let events = s:mandala_autocmds_events
	call wheel#gear#clear_autocmds (group, events)
endfun

fun! wheel#mandala#clear_vars ()
	" Clear mandala local variables, except the leaves ring
	call wheel#gear#unlet (s:mandala_vars)
endfun

fun! wheel#mandala#clear ()
	" Clear mandala
	" -- clear state
	call wheel#mandala#clear_options ()
	call wheel#mandala#clear_maps ()
	call wheel#mandala#clear_autocmds ()
	call wheel#mandala#clear_vars ()
	" -- clear lines
	" delete lines -> underscore _ = no storing register
	silent! 1,$ delete _
	" -- init vars
	call wheel#mandala#init ()
endfun

" window & buffer

fun! wheel#mandala#open (type)
	" Open a mandala buffer
	let type = a:type
	call wheel#vortex#update ()
	let related_buffer = bufnr('%')
	if ! wheel#cylinder#recall()
		" first mandala
		" split is done in the routine
		call wheel#cylinder#first ('split')
	endif
	" add new leaf, clear mandala, init vars
	call wheel#book#add ('clear')
	call wheel#mandala#filename (type)
	call wheel#mandala#common_options ()
	" set related buffer
	if related_buffer != bufnr('%')
		let b:wheel_related_buffer = related_buffer
	else
		" related buffer == mandala buffer :
		" happens when mandala is already opened at the start of this function
		" in that case, the related buffer is considered the same as
		" that of the previous leaf in the ring
		let b:wheel_related_buffer = wheel#book#previous('related_buffer')
	endif
endfun

fun! wheel#mandala#close ()
	" Close the mandala buffer
	" -- if we are not in a mandala buffer,
	" -- go to its window if it is visible
	if ! wheel#cylinder#is_mandala()
		call wheel#cylinder#goto ()
	endif
	" -- if we are still not in a mandala buffer,
	" -- none is visible and there is nothing to do
	if ! wheel#cylinder#is_mandala()
		return v:false
	endif
	" -- mandala buffer
	if winnr('$') > 1
		" more than one window in tab ? close it.
		close
	else
		" only one window in tab ? jump to current wheel location
		call wheel#vortex#jump ()
	endif
	call wheel#status#clear ()
	return v:true
endfun

fun! wheel#mandala#related ()
	" Go to window of related buffer if visible, or edit it in first window of tab
	" optional argument :
	"   - buffer number
	"   - default : related buffer number
	" if no optional argument and no related buffer : go to previous window
	if ! wheel#cylinder#is_mandala ()
		return v:false
	endif
	let bufnum = b:wheel_related_buffer
	if bufnum == 'undefined'
		wincmd p
		return 'undefined'
	endif
	call wheel#rectangle#goto_or_load (bufnum)
	return bufnum
endfun

" content

fun! wheel#mandala#replace (content, first = 'keep-first')
	" Replace mandala buffer with content
	" Content can be :
	" - a monoline string
	" - a list of lines
	" Optional argument handle the first line filtering input :
	" - keep-first : keep input
	" - blank-first : blank input
	" - delete-first : delete first line
	if ! wheel#cylinder#is_mandala ()
		echomsg 'wheel mandala fill : not in mandala buffer.'
	endif
	" -- disable folding
	" if fold is enabled during replacement, we lose the first line
	let ampersand = &foldenable
	set nofoldenable
	" -- arguments
	let content = a:content
	let first = a:first
	" -- cursor
	let position = getcurpos()
	" -- delete old content
	if exists('*deletebufline')
		silent! call deletebufline('%', 2, '$')
	else
		silent! 2,$ delete
	endif
	" -- new content
	" ============================================================
	" alternative : use :silent put =content
	" setline() or append() did not used to work with yank lists
	" note : append() / :put add stuff after current line
	" ============================================================
	call cursor(1, 1)
	call append('.', content)
	" -- first line
	if first == 'blank-first'
		call setline(1, '')
	elseif first == 'delete-first'
		silent 1 delete _
	endif
	" -- tell (neo)vim the buffer is unmodified
	setlocal nomodified
	" -- restore cursor if possible, else place it on line 1
	call wheel#gear#restore_cursor (position, 1)
	" -- restore folding
	let &foldenable = ampersand
endfun

fun! wheel#mandala#update_var_lines ()
	" Update b:wheel_lines from mandala lines
	let start = wheel#teapot#first_data_line ()
	let lines = getline(start, '$')
	let b:wheel_lines = lines
	return lines
endfun

fun! wheel#mandala#fill (content, first = 'keep-first')
	" Fill mandala buffer with content
	" Content can be :
	" - a monoline string
	" - a list of lines
	" Optional argument handle the first line filtering input :
	" - keep-first : keep input
	" - blank-first : blank input
	" - delete-first : delete first line
	" ---- replace old content, fill if empty
	call wheel#mandala#replace(a:content, a:first)
	" -- update b:wheel_lines
	call wheel#mandala#update_var_lines ()
	" ---- update leaf ring
	call wheel#book#syncup ()
	call wheel#status#mandala_leaf ()
endfun

fun! wheel#mandala#reload ()
	" Reload current mandala
	" -- save pseudo filename
	let filename = expand('%')
	" -- mark the buffer as empty, to avoid adding a leaf in wheel#mandala#open
	call wheel#mandala#set_empty ()
	" -- reinitialize buffer vars
	call wheel#mandala#refresh ()
	" -- delete all lines
	silent 1,$ delete _
	" -- reload content
	call wheel#status#clear ()
	if ! empty(b:wheel_reload)
		call wheel#gear#call (b:wheel_reload)
		let fun = b:wheel_reload
		echomsg 'wheel : ' fun 'reloaded.'
	else
		" by default, if b:wheel_reload is not defined or empty,
		" fill the buffer with b:wheel_lines
		call wheel#mandala#fill (b:wheel_lines, 'blank-first')
		" restore
		execute 'silent file' filename
		echomsg 'wheel : content reloaded.'
	endif
endfun

" undo, redo

fun! wheel#mandala#undo ()
	" Undo action in previous window
	call wheel#mandala#related ()
	undo
	call wheel#cylinder#recall ()
endfun

fun! wheel#mandala#redo ()
	" Redo action in previous window
	call wheel#mandala#related ()
	redo
	call wheel#cylinder#recall ()
endfun

" options

fun! wheel#mandala#common_options ()
	" Set local common options
	setlocal filetype=wheel
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal nobuflisted
	setlocal noswapfile
	setlocal cursorline
	setlocal nofoldenable
endfun

" mappings

fun! wheel#mandala#common_maps ()
	" Define local common maps
	nnoremap <buffer> q <cmd>call wheel#mandala#close()<cr>
	nnoremap <buffer> j <cmd>call wheel#mandala#wrap_down()<cr>
	nnoremap <buffer> k <cmd>call wheel#mandala#wrap_up()<cr>
	nnoremap <buffer> <down> <cmd>call wheel#mandala#wrap_down()<cr>
	nnoremap <buffer> <up> <cmd>call wheel#mandala#wrap_up()<cr>
	" Reload mandala
	nnoremap <buffer> r <cmd>call wheel#mandala#reload ()<cr>
	" Navigate in layer ring
	nnoremap <buffer> H <cmd>call wheel#book#backward ()<cr>
	nnoremap <buffer> L <cmd>call wheel#book#forward ()<cr>
	nnoremap <buffer> <m-l> <cmd>call wheel#book#switch ()<cr>
	nnoremap <buffer> <backspace> <cmd>call wheel#book#delete ()<cr>
endfun

fun! wheel#mandala#input_history_maps ()
	" Define local input history maps
	" Use Up / Down & M-p / M-n
	" C-p / C-n is taken by (neo)vim completion
	inoremap <buffer> <up> <cmd>call wheel#scroll#older()<cr>
	inoremap <buffer> <down> <cmd>call wheel#scroll#newer()<cr>
	inoremap <buffer> <M-p> <cmd>call wheel#scroll#older()<cr>
	inoremap <buffer> <M-n> <cmd>call wheel#scroll#newer()<cr>
	" PageUp / PageDown & M-r / M-s : next / prev matching line
	inoremap <buffer> <PageUp> <cmd>call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <PageDown> <cmd>call wheel#scroll#filtered_newer()<cr>
	inoremap <buffer> <M-r> <cmd>call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <M-s> <cmd>call wheel#scroll#filtered_newer()<cr>
endfun

" folding

fun! wheel#mandala#folding_options (...)
	" Folding options for mandala buffers
	if a:0 > 0
		let textfun = a:1
	else
		let textfun = 'folding_text'
	endif
	setlocal foldenable
	setlocal foldminlines=1
	setlocal foldlevel=0
	setlocal foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
	setlocal foldclose=
	setlocal foldmethod=marker
	let &foldmarker = s:fold_markers
	setlocal foldcolumn=2
	execute 'setlocal foldtext=wheel#mandala#' .. textfun .. '()'
endfun

fun! wheel#mandala#folding_text ()
	" Folding text for mandala buffers
	let numlines = v:foldend - v:foldstart
	let line = getline(v:foldstart)
	if v:foldlevel == 1
		let level = 'torus'
	elseif v:foldlevel == 2
		let level = 'circle'
	elseif v:foldlevel == 3
		let level = 'location'
	else
		let level = 'none'
	endif
	let marker = s:fold_markers[0]
	let pattern = '\m' .. marker .. '[12]'
	let repl = ':: ' .. level
	let line = substitute(line, pattern, repl, '')
	let text = line .. ' :: ' .. numlines .. ' lines ' .. v:folddashes
	return text
endfun

fun! wheel#mandala#tabwins_folding_text ()
	" Folding text for mandala buffers
	let numlines = v:foldend - v:foldstart
	let line = getline(v:foldstart)
	let marker = s:fold_markers[0]
	let pattern = '\m ' .. marker .. '[12]'
	let repl = ''
	let line = substitute(line, pattern, repl, '')
	let text = line .. ' :: ' .. numlines .. ' lines ' .. v:folddashes
	return text
endfun

" template

fun! wheel#mandala#template (...)
	" Template with filter & input history
	if a:0 > 0
		let b:wheel_settings = a:1
	endif
	call wheel#mandala#common_maps ()
	call wheel#teapot#mappings ()
	call wheel#mandala#input_history_maps ()
	" By default, tell wheel#line#address it’s not a tree buffer
	" Overridden by folding_options
	setlocal nofoldenable
endfun

" generic commands

fun! wheel#mandala#command (...)
	" Generic ex or shell command
	" for shell command, just begin with !
	if a:0 > 0
		let command = a:1
	else
		let command = input('Ex or !shell command : ')
	endif
	if command[0] == '!'
		let command = command[1:]
		let current = getreg('%')
		let alter = getreg('#')
		let command = substitute(command, ' %', ' ' .. current, 'g')
		let command = substitute(command, ' #', ' ' .. alter, 'g')
		let lines = wheel#perspective#execute (command, 'system')
	else
		let lines = wheel#perspective#execute (command)
	endif
	call wheel#mandala#open ('command')
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
	let current = getreg('%')
	let alter = getreg('#')
	let command = substitute(command, ' %', ' ' .. current, 'g')
	let command = substitute(command, ' #', ' ' .. alter, 'g')
	if has('nvim')
		let job = wheel#wave#start(command)
	else
		let job = wheel#ripple#start(command)
	endif
	" Map to stop the job
	let map = 'nnoremap <silent> <buffer>'
	if has('nvim')
		let callme = '<cmd>call wheel#wave#stop()<cr>'
	else
		let callme = '<cmd>call wheel#ripple#stop()<cr>'
	endif
	execute map '<c-s>' callme
endfun
