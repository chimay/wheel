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

if ! exists('s:fold_markers')
	let s:fold_markers = wheel#crystal#fetch('fold/markers')
	let s:fold_markers = join(s:fold_markers, ',')
	lockvar s:fold_markers
endif

" Buffer

fun! wheel#mandala#open (...)
	" Open a mandala buffer
	if a:0 > 0
		let type = a:1
	else
		let type = 'default'
	endif
	if wheel#cylinder#recall ()
		call wheel#layer#push ()
		call wheel#layer#fresh ()
	else
		new
		call wheel#cylinder#push ('linger')
	endif
	call wheel#mandala#common_options (type)
endfun

fun! wheel#mandala#close ()
	" Close the mandala buffer
	" If we are not in a mandala buffer, there is nothing to do
	let bufnum = bufnr('%')
	if index(g:wheel_buffers.stack, bufnum) < 0
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

fun! wheel#mandala#fill (content)
	" Fill buffer with content
	" Content can be :
	" - a monoline string
	" - a list of lines
	let content = a:content
	"call append(1, content)
	" Cannot use setline or append : does not work with yanks
	silent put =content
	call cursor(1,1)
	let b:wheel_lines = getline(2, '$')
endfun

fun! wheel#mandala#replace (content, ...)
	" Replace buffer lines with content
	" Optional argument handle the first line filtering input :
	" - keep : keep input
	" - blank : blank input
	" - delete : delete first line
	if a:0 > 0
		let first = a:1
	else
		let first = 'keep'
	endif
	let position = getcurpos()
	let content = a:content
	if exists('*deletebufline')
		call deletebufline('%', 2, '$')
	else
		silent! 2,$ delete _
	endif
	" Cannot use setline or append : does not work with yanks
	put =content
	if first == 'blank'
		call setline(1, '')
	elseif first == 'delete'
		1 delete _
	endif
	silent! 2,$ global /^$/ delete _
	setlocal nomodified
	call wheel#gear#restore_cursor (position, 1)
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
	call wheel#mandala#replace(lines)
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

fun! wheel#mandala#common_options (type)
	" Set local common options
	let type = a:type
	setlocal cursorline
	setlocal nobuflisted
	setlocal noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=hide
	" wheel or type argument
	let &filetype = 'wheel'
	" Useful as information
	" We also need a name when writing, even with BufWriteCmd
	" Add unique buf id, so (n)vim does not complain about
	" existing file name
	let current = g:wheel_buffers.current
	let iden = g:wheel_buffers.iden[current]
	let pseudo_folders = '/wheel/' . iden . '/' . type
	exe 'silent file' pseudo_folders
endfun

" Maps

fun! wheel#mandala#common_maps ()
	" Define local common maps
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	nnoremap <buffer> j :call wheel#mandala#wrap_down()<cr>
	nnoremap <buffer> k :call wheel#mandala#wrap_up()<cr>
	nnoremap <buffer> <down> :call wheel#mandala#wrap_down()<cr>
	nnoremap <buffer> <up> :call wheel#mandala#wrap_up()<cr>
endfu

fun! wheel#mandala#filter_maps ()
	" Define local filter maps
	" Normal mode
	nnoremap <buffer> i ggA
	nnoremap <buffer> a ggA
	" Insert mode
	inoremap <buffer> <space> <esc>:call wheel#mandala#filter('insert')<cr><space>
	inoremap <buffer> <c-w> <c-w><esc>:call wheel#mandala#filter('insert')<cr>
	inoremap <buffer> <c-u> <c-u><esc>:call wheel#mandala#filter('insert')<cr>
	inoremap <buffer> <esc> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
	" <C-c> is not mapped, in case you need a regular esc
endfun

fun! wheel#mandala#input_history_maps ()
	" Define local input history maps
	" Use Up / Down & M-p / M-n
	" C-p / C-n is taken by (neo)vim completion
	inoremap <buffer> <up> <esc>:call wheel#scroll#older()<cr>
	inoremap <buffer> <down> <esc>:call wheel#scroll#newer()<cr>
	inoremap <buffer> <M-p> <esc>:call wheel#scroll#older()<cr>
	inoremap <buffer> <M-n> <esc>:call wheel#scroll#newer()<cr>
	" PageUp / PageDown & M-r / M-s : next / prev matching line
	inoremap <buffer> <PageUp> <esc>:call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <PageDown> <esc>:call wheel#scroll#filtered_newer()<cr>
	inoremap <buffer> <M-r> <esc>:call wheel#scroll#filtered_older()<cr>
	inoremap <buffer> <M-s> <esc>:call wheel#scroll#filtered_newer()<cr>
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
	let map  =  'nnoremap <buffer> '
	if has('nvim')
		let callme  = ' :call wheel#wave#stop()<cr>'
	else
		let callme  = ' :call wheel#ripple#stop()<cr>'
	endif
	exe map . '<c-s>' . callme
endfun
