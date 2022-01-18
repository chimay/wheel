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

" Init

fun! wheel#mandala#init (mode = 'default')
	" Init mandala buffer variables
	let mode = a:mode
	if mode == 'refresh'
		" deselect e.g. when reloading
		let b:wheel_address = ''
		let b:wheel_selected = []
	endif
	" mandala nature
	if ! exists('b:wheel_nature')
		let b:wheel_nature = {}
		let b:wheel_nature.empty = v:true
		let b:wheel_nature.type = 'empty'
		let b:wheel_nature.has_filter = v:false
	endif
	" related buffer
	if ! exists('b:wheel_related_buffer')
		let b:wheel_related_buffer = 'undefined'
	endif
	" lines
	if ! exists('b:wheel_lines')
		let b:wheel_lines = []
	endif
	if ! exists('b:wheel_address')
		let b:wheel_address = ''
	endif
	if ! exists('b:wheel_selected')
		let b:wheel_selected = []
	endif
	" settings
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

" Clearing things

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

" Mandala pseudo filename

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
	execute 'silent file' wheel#mandala#pseudo (type)
	" should be false when called
	" set to true in wheel#mandala#set_empty
	let b:wheel_nature.empty = v:false
endfun

fun! wheel#mandala#type ()
	" Type of a mandala buffer
	return b:wheel_nature.type
endfun

" Nature

fun! wheel#mandala#set_empty ()
	" Tell wheel to consider this mandala as an empty buffer
	call wheel#mandala#filename ('empty')
	" has to be placed after mandala#filename
	let b:wheel_nature.empty = v:true
endfun

fun! wheel#mandala#is_empty ()
	" Return true if mandala is empty, false otherwise
	return b:wheel_nature.empty
endfun

fun! wheel#mandala#has_filter ()
	" Return true if mandala has filter in first line, false otherwise
	return b:wheel_nature.has_filter
endfun

" Window & buffer

fun! wheel#mandala#open (type)
	" Open a mandala buffer
	let type = a:type
	call wheel#vortex#update ()
	let related_buffer = bufnr('%')
	if ! wheel#cylinder#recall()
		" first mandala
		" split is done in the routine
		call wheel#cylinder#first ('linger')
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
		" only one window in tab ? go to related buffer
		let related_buffer = b:wheel_related_buffer
		call wheel#rectangle#goto_or_load (related_buffer)
	endif
	call wheel#status#clear ()
	return v:true
endfun

" Content

fun! wheel#mandala#fill (content, ...)
	" Fill mandala buffer with content
	" Content can be :
	" - a monoline string
	" - a list of lines
	" Optional argument handle the first line filtering input :
	" - keep : keep input
	" - blank : blank input
	" - delete : delete first line
	if ! wheel#cylinder#is_mandala ()
		echomsg 'wheel mandala fill : not in mandala buffer.'
	endif
	" disable folding
	let ampersand = &foldenable
	set nofoldenable
	" arg
	let content = a:content
	if a:0 > 0
		let first = a:1
	else
		let first = 'keep'
	endif
	" cursor
	let position = getcurpos()
	" delete old content
	if exists('*deletebufline')
		silent! call deletebufline('%', 2, '$')
	else
		silent! 2,$ delete
	endif
	" Cannot use setline() or append() : does not work with yank lists
	silent put =content
	" new lines
	call cursor(1,1)
	if first == 'keep'
		" delete empty lines from line 2 to end
		silent! 2,$ global /^$/ delete _
		" update b:wheel_lines
		let b:wheel_lines = getline(2, '$')
	elseif first == 'blank'
		" first lines should already be blank :
		" :put add stuff after current line,
		" which is the first one on a empty buffer
		call setline(1, '')
		silent! 2,$ global /^$/ delete _
		" update b:wheel_lines
		let b:wheel_lines = getline(2, '$')
	elseif first == 'delete'
		silent 1 delete _
		silent! 2,$ global /^$/ delete _
		" update b:wheel_lines
		let b:wheel_lines = getline(1, '$')
	endif
	" tell (neo)vim the buffer is unmodified
	setlocal nomodified
	" restore cursor if possible, else place it on line 1
	call wheel#gear#restore_cursor (position, 1)
	" restore foldenable value
	let &foldenable = ampersand
	" update leaf ring
	call wheel#book#syncup ()
	call wheel#status#mandala_leaf ()
endfun

fun! wheel#mandala#replace (content, first = 'keep-first')
	" Replace mandala buffer with content
	" Similar as wheel#mandala#fill, but do not update mandala variables
	" Content can be :
	" - a monoline string
	" - a list of lines
	" Optional argument handle the first line filtering input :
	" - keep : keep input
	" - blank : blank input
	" - delete : delete first line
	if ! wheel#cylinder#is_mandala ()
		echomsg 'wheel mandala fill : not in mandala buffer.'
	endif
	" disable folding
	" if fold is enabled during replacement, we lose the first line
	let ampersand = &foldenable
	set nofoldenable
	" arguments
	let content = a:content
	let first = a:first
	" cursor
	let position = getcurpos()
	" delete old content
	if exists('*deletebufline')
		silent! call deletebufline('%', 2, '$')
	else
		silent! 2,$ delete
	endif
	" Cannot use setline() or append() : does not work with yank lists
	silent put =content
	" first line
	call cursor(1,1)
	if first == 'blank-first'
		" first line should already be blank :
		" :put add stuff after current line,
		" which is the first one on a empty buffer
		call setline(1, '')
	elseif first == 'delete-first'
		silent 1 delete _
	endif
	" delete empty lines from line 2 to end
	silent! 2,$ global /^$/ delete _
	" tell (neo)vim the buffer is unmodified
	setlocal nomodified
	" restore cursor if possible, else place it on line 1
	call wheel#gear#restore_cursor (position, 1)
	" restore foldenable value
	let &foldenable = ampersand
endfun

fun! wheel#mandala#reload ()
	" Reload current mandala
	" -- save pseudo filename
	let filename = expand('%')
	" -- mark the buffer as empty, to avoid adding a leaf in wheel#mandala#open
	call wheel#mandala#set_empty ()
	" -- reinitialize buffer vars
	call wheel#mandala#init ('refresh')
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
		call wheel#mandala#fill (b:wheel_lines, 'blank')
		" restore
		execute 'silent file' filename
		echomsg 'wheel : content reloaded.'
	endif
endfun

" Wrap

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

" Related buffer

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

" Undo, redo

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

" Filter

fun! wheel#mandala#filter (mode = 'normal')
	" Keep lines matching words of first line
	let mode = a:mode
	let lines = wheel#kyusu#line ()
	call wheel#mandala#replace (lines, 'keep-first')
	if mode == 'normal'
		if line('$') > 1
			call cursor(2, 1)
		endif
	elseif mode == 'insert'
		call cursor(1, 1)
		startinsert!
	endif
endfun

fun! wheel#mandala#first_data_line ()
	" First data line is 1 if mandala has no filter, 2 otherwise
	if ! wheel#mandala#has_filter ()
		return 1
	else
		return 2
	endif
endfun

" Options

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

" Maps

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
endfu

fun! wheel#mandala#filter_maps ()
	" Define local filter maps
	" normal mode
	nnoremap <silent> <buffer> i ggA
	nnoremap <silent> <buffer> a ggA
	" insert mode
	inoremap <silent> <buffer> <space> <esc>:call wheel#mandala#filter('insert')<cr><space>
	inoremap <silent> <buffer> <c-w> <c-w><esc>:call wheel#mandala#filter('insert')<cr>
	inoremap <silent> <buffer> <c-u> <c-u><esc>:call wheel#mandala#filter('insert')<cr>
	inoremap <silent> <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
	inoremap <silent> <buffer> <esc> <esc>:call wheel#mandala#filter()<cr>
	" <C-c> is not mapped, in case you need a regular escape
	let b:wheel_nature.has_filter = v:true
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

" Folding

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

" Template

fun! wheel#mandala#template (...)
	" Template with filter & input history
	if a:0 > 0
		let b:wheel_settings = a:1
	endif
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
	call wheel#mandala#input_history_maps ()
	" By default, tell wheel#line#address it’s not a tree buffer
	" Overridden by folding_options
	setlocal nofoldenable
endfun

" Generic commands

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
