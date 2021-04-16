" vim: ft=vim fdm=indent:

" Generic wheel special buffers = mandala buffers
"
" A mandala is made of lines, like a buffer
"
" Sane defaults : may be overriden by more specific buffers
"
" Search, Filter
" Select
" Trigger action

" Script vars

if ! exists('s:mandala_empty')
	let s:mandala_empty = wheel#crystal#fetch('mandala/empty')
	lockvar s:mandala_empty
endif

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

" Buffer

" Mandala pseudo folders

fun! wheel#mandala#pseudo_filename (mandala_type)
	" Set buffer filename to pseudo filename /wheel/<buf-id>/<type>
	" Useful as information
	" We also need a name when writing, even with BufWriteCmd
	" Add unique buf id, so (n)vim does not complain about
	" existing filename
	let type = a:mandala_type
	let current = g:wheel_mandalas.current
	let iden = g:wheel_mandalas.iden[current]
	let pseudo_filename = '/wheel/' . iden . '/' . type
	exe 'silent file' pseudo_filename
	return pseudo_filename
endfun

fun! wheel#mandala#empty ()
	" True if mandala is empty, false otherwise
	let filename = expand('%')
	if filename =~ s:mandala_empty
		return v:true
	else
		return v:false
	endif
endfun

fun! wheel#mandala#open (type)
	" Open a mandala buffer
	let type = a:type
	if wheel#cylinder#recall()
		if ! wheel#mandala#empty ()
			call wheel#layer#push ()
			call wheel#layer#fresh ()
		endif
		call wheel#layer#init ()
	else
		new
		call wheel#cylinder#push ('linger')
	endif
	call wheel#mandala#pseudo_filename (type)
	call wheel#mandala#common_options ()
endfun

fun! wheel#mandala#close ()
	" Close the mandala buffer
	" If we are not in a mandala buffer, there is nothing to do
	let bufnum = bufnr('%')
	if index(g:wheel_mandalas.stack, bufnum) < 0
		echomsg 'wheel mandala close : we are not in a mandala buffer.'
		return v:false
	endif
	" Mandala buffer
	if winnr('$') > 1
		" More than one window in tab ? Close it.
		close
	else
		" Only one window in tab ? Jump to last known file in wheel.
		call wheel#vortex#jump ()
		" Go to alternate buffer if only one window
		"buffer #
	endif
	return v:true
endfun

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
		call deletebufline('%', 2, '$')
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
		1 delete _
		silent! 2,$ global /^$/ delete _
		" update b:wheel_lines
		let b:wheel_lines = getline(1, '$')
	endif
	" tell (neo)vim the buffer is unmodified
	setlocal nomodified
	" restore cursor if possible, else place it on line 1
	call wheel#gear#restore_cursor (position, 1)
endfun

fun! wheel#mandala#replace (content, ...)
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
		call deletebufline('%', 2, '$')
	else
		silent! 2,$ delete
	endif
	" Cannot use setline() or append() : does not work with yank lists
	silent put =content
	" first line
	call cursor(1,1)
	if first == 'blank'
		" first lines should already be blank :
		" :put add stuff after current line,
		" which is the first one on a empty buffer
		call setline(1, '')
	elseif first == 'delete'
		1 delete _
	endif
	" delete empty lines from line 2 to end
	silent! 2,$ global /^$/ delete _
	" tell (neo)vim the buffer is unmodified
	setlocal nomodified
	" restore cursor if possible, else place it on line 1
	call wheel#gear#restore_cursor (position, 1)
endfun

fun! wheel#mandala#reload ()
	" Reload current mandala
	" save pseudo filename
	let filename = expand('%')
	" mark the buffer as empty, to avoid pushing a new layer
	call wheel#mandala#pseudo_filename ('empty')
	" delete all lines
	1,$ delete _
	" reload content
	if exists('b:wheel_reload') && ! empty(b:wheel_reload)
		call wheel#gear#call (b:wheel_reload)
	else
		" by default, if b:wheel_reload is not defined or empty,
		" fill the buffer with b:wheel_lines
		call wheel#mandala#fill (b:wheel_lines, 'blank')
		" restore
		exe 'silent file' filename
	endif
	echomsg 'wheel mandala : function reloaded.'
endfun

fun! wheel#mandala#previous ()
	" Go to previous window, before mandala buffer opening
	" Go to alternate buffer if only one window
	if winnr('$') > 1
		wincmd p
	else
		buffer #
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

" Undo, redo

fun! wheel#mandala#undo ()
	" Undo action in previous window
	wincmd p
	undo
	wincmd p
endfun

fun! wheel#mandala#redo ()
	" Redo action in previous window
	wincmd p
	redo
	wincmd p
endfun

" Filter

fun! wheel#mandala#filter (...)
	" Keep lines matching words of first line
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'normal'
	endif
	let lines = wheel#line#filter ()
	call wheel#mandala#replace (lines, 'keep')
	if mode == 'normal'
		if line('$') > 1
			call cursor(2, 1)
		endif
	elseif mode == 'insert'
		call cursor(1, 1)
		startinsert!
	endif
endfu

" Options

fun! wheel#mandala#common_options ()
	" Set local common options
	setlocal cursorline
	setlocal nobuflisted
	setlocal noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=hide
	" wheel or type argument
	let &filetype = 'wheel'
endfun

" Maps

fun! wheel#mandala#common_maps ()
	" Define local common maps
	nnoremap <silent> <buffer> q :call wheel#mandala#close()<cr>
	nnoremap <silent> <buffer> j :call wheel#mandala#wrap_down()<cr>
	nnoremap <silent> <buffer> k :call wheel#mandala#wrap_up()<cr>
	nnoremap <silent> <buffer> <down> :call wheel#mandala#wrap_down()<cr>
	nnoremap <silent> <buffer> <up> :call wheel#mandala#wrap_up()<cr>
	" Reload mandala
	nnoremap <silent> <buffer> r :call wheel#mandala#reload ()<cr>
	" Navigate in layer stack
	nnoremap <silent> <buffer> H :call wheel#layer#backward ()<cr>
	nnoremap <silent> <buffer> L :call wheel#layer#forward ()<cr>
	nnoremap <silent> <buffer> <backspace> :call wheel#layer#pop ()<cr>
endfu

fun! wheel#mandala#filter_maps ()
	" Define local filter maps
	" Normal mode
	nnoremap <silent> <buffer> i ggA
	nnoremap <silent> <buffer> a ggA
	" Insert mode
	inoremap <silent> <buffer> <space> <esc>:call wheel#mandala#filter('insert')<cr><space>
	inoremap <silent> <buffer> <c-w> <c-w><esc>:call wheel#mandala#filter('insert')<cr>
	inoremap <silent> <buffer> <c-u> <c-u><esc>:call wheel#mandala#filter('insert')<cr>
	inoremap <silent> <buffer> <esc> <esc>:call wheel#mandala#filter()<cr>
	inoremap <silent> <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
	" <C-c> is not mapped, in case you need a regular esc
endfun

fun! wheel#mandala#input_history_maps ()
	" Define local input history maps
	" Use Up / Down & M-p / M-n
	" C-p / C-n is taken by (neo)vim completion
	inoremap <silent> <buffer> <up> <esc>:call wheel#scroll#older()<cr>
	inoremap <silent> <buffer> <down> <esc>:call wheel#scroll#newer()<cr>
	inoremap <silent> <buffer> <M-p> <esc>:call wheel#scroll#older()<cr>
	inoremap <silent> <buffer> <M-n> <esc>:call wheel#scroll#newer()<cr>
	" PageUp / PageDown & M-r / M-s : next / prev matching line
	inoremap <silent> <buffer> <PageUp> <esc>:call wheel#scroll#filtered_older()<cr>
	inoremap <silent> <buffer> <PageDown> <esc>:call wheel#scroll#filtered_newer()<cr>
	inoremap <silent> <buffer> <M-r> <esc>:call wheel#scroll#filtered_older()<cr>
	inoremap <silent> <buffer> <M-s> <esc>:call wheel#scroll#filtered_newer()<cr>
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
	exe 'setlocal foldtext=wheel#mandala#' . textfun . '()'
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
	let pattern = '\m' . marker . '[12]'
	let repl = ':: ' . level
	let line = substitute(line, pattern, repl, '')
	let text = line . ' :: ' . numlines . ' lines ' . v:folddashes
	return text
endfun

fun! wheel#mandala#tabwins_folding_text ()
	" Folding text for mandala buffers
	let numlines = v:foldend - v:foldstart
	let line = getline(v:foldstart)
	let marker = s:fold_markers[0]
	let pattern = '\m ' . marker . '[12]'
	let repl = ''
	let line = substitute(line, pattern, repl, '')
	let text = line . ' :: ' . numlines . ' lines ' . v:folddashes
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
		let command = substitute(command, ' %', ' ' . current, 'g')
		let command = substitute(command, ' #', ' ' . alter, 'g')
		let lines = wheel#perspective#execute (command, 'system')
	else
		let lines = wheel#perspective#execute (command)
	endif
	call wheel#vortex#update ()
	call wheel#mandala#open ('command')
	call wheel#mandala#template ()
	call wheel#mandala#fill (lines)
endfun

fun! wheel#mandala#async ()
	" Async command with output in wheel buffer
	if a:0 > 0
		let command = a:1
	else
		let command = input('async shell command : ', '', 'file_in_path')
	endif
	call wheel#vortex#update ()
	let current = getreg('%')
	let alter = getreg('#')
	let command = substitute(command, ' %', ' ' . current, 'g')
	let command = substitute(command, ' #', ' ' . alter, 'g')
	if has('nvim')
		let job = wheel#wave#start(command)
	else
		let job = wheel#ripple#start(command)
	endif
	" Map to stop the job
	let map  =  'nnoremap <silent> <buffer> '
	if has('nvim')
		let callme  = ' :call wheel#wave#stop()<cr>'
	else
		let callme  = ' :call wheel#ripple#stop()<cr>'
	endif
	exe map . '<c-s>' . callme
endfun
