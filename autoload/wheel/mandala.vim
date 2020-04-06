" vim: ft=vim fdm=indent:

" Special Buffer menus
" Filter and choose an element

" Special Buffer

fun! wheel#mandala#open (...)
	" Open a wheel buffer
	let type = 'wheel'
	if a:0 > 0
		let type = a:1
	endif
	new
	setlocal cursorline
	setlocal nobuflisted
	setlocal noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=delete
	let &filetype = type
endfun

fun! wheel#mandala#close ()
	" Close the wheel buffer
	if winnr('$') > 1
		quit!
	else
		bdelete!
	endif
endfun

fun! wheel#mandala#filter ()
	" Keep lines matching words of first line
	let lines = wheel#line#filter ()
	2,$ delete _
	put =lines
	setlocal nomodified
	if line('$') > 1
		2
	endif
endfu

" Maps

fun! wheel#mandala#common_maps (...)
	" Define local common maps in wheel buffer
	nnoremap <buffer> i ggA
	nnoremap <buffer> a ggA
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
endfu

fun! wheel#mandala#filter_maps ()
	" Define local filter maps in wheel buffer
	inoremap <buffer> <space> <esc>:call wheel#mandala#filter()<cr>ggA<space>
	inoremap <buffer> <c-w> <c-w><esc>:call wheel#mandala#filter()<cr>ggA
	inoremap <buffer> <c-u> <c-u><esc>:call wheel#mandala#filter()<cr>ggA
	inoremap <buffer> <esc> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
	" <C-c> is not mapped, in case you need a regular esc
endfun

fun! wheel#mandala#input_history_maps ()
	" Define local input history maps in wheel buffer
	" Use Up / Down & M-p / M-n
	" C-p / C-n is taken by (neo)vim completion
endfun

fun! wheel#mandala#jump_maps (level)
	" Define maps to jump to element in current line
	let string = "nnoremap <buffer> <tab> :call wheel#line#jump('"
	let string .= a:level . "', 'open')<cr>"
	exe string
	let string = "nnoremap <buffer> <cr> :call wheel#line#jump('"
	let string .= a:level . "', 'close')<cr>"
	exe string
endfun

fun! wheel#mandala#reorder_maps ()
	" Define local reorder maps in wheel buffer
endfun

fun! wheel#mandala#reorder_write (level)
	" Define reorder autocommands in wheel buffer
	setlocal buftype=
	let string = "autocmd BufWriteCmd <buffer> call wheel#cuboctahedron#reorder ('"
	let string .= a:level . "')"
	" Need a name when writing, even with BufWriteCmd
	file /wheel/reorder
	augroup wheel
		autocmd!
		exe string
	augroup END
endfun

" Folding

fun! wheel#mandala#folding_options ()
	" Folding options for wheel buffers
	setlocal foldenable
	setlocal foldminlines=1
	setlocal foldlevel=0
	setlocal foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo
	setlocal foldclose=
	setlocal foldmethod=marker
	setlocal foldmarker=>,<
	setlocal foldcolumn=2
	setlocal foldtext=wheel#mandala#folding_text()
endfun

fun! wheel#mandala#folding_text ()
	" Folding text for wheel buffers
	let numlines = v:foldend - v:foldstart
	let line = getline(v:foldstart)
	if v:foldlevel == 1
		let level = 'torus'
	elseif v:foldlevel == 2
		let level = 'circle'
	elseif v:foldlevel == 3
		let level = 'location'
	endif
	let repl = ':: ' . level
	let line = substitute(line, '\m>[12]', repl, '')
	let text = line . ' :: ' . numlines . ' lines ' . v:folddashes
	return text
endfun

" Choose

fun! wheel#mandala#choose (level)
	" Choose an element of level to switch to
	let level = a:level
	call wheel#vortex#update ()
	let string = 'wheel-choose-' . level
	call wheel#mandala#open (string)
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
	call wheel#mandala#jump_maps (level)
	let upper = wheel#referen#upper (level)
	if ! empty(upper) && ! empty(upper.glossary)
		let names = upper.glossary
		let content = join(names, "\n")
		put =content
		setlocal nomodified
		normal! gg
	else
		echomsg 'Wheel mandala choose : empty or incomplete' level
	endif
endfun

fun! wheel#mandala#toruses ()
	" Choose a torus to switch to
	call wheel#mandala#choose ('torus')
endfun

fun! wheel#mandala#circles ()
	" Choose a circle to switch to
	call wheel#mandala#choose ('circle')
endfun

fun! wheel#mandala#locations ()
	" Choose a location to switch to
	call wheel#mandala#choose ('location')
endfun

fun! wheel#mandala#helix ()
	" Choose a location coordinate to switch to
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-location-index')
	let names = wheel#helix#locations ()
	let content = join(names, "\n")
	put =content
	setlocal nomodified
	normal! gg
	nnoremap <buffer> <tab> :call wheel#line#helix('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#helix('close')<cr>
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
endfun

fun! wheel#mandala#grid ()
	" Choose a circle coordinate to switch to
	" Each coordinate = [torus, circle]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-circle-index')
	let names = wheel#helix#circles ()
	let content = join(names, "\n")
	put =content
	setlocal nomodified
	normal! gg
	nnoremap <buffer> <tab> :call wheel#line#grid('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#grid('close')<cr>
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
endfun

fun! wheel#mandala#tree ()
	" Choose an element in the wheel tree
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-tree')
	call wheel#mandala#folding_options ()
	let names = wheel#helix#tree ()
	let content = join(names, "\n")
	put =content
	setlocal nomodified
	normal! gg
	nnoremap <buffer> <tab> :call wheel#line#tree('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#tree('close')<cr>
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
endfun

fun! wheel#mandala#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#pendulum#sorted ()
	let content = join(names, "\n")
	put =content
	setlocal nomodified
	normal! gg
	nnoremap <buffer> <tab> :call wheel#line#history('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#history('close')<cr>
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
endfun

" Reorder

fun! wheel#mandala#reorder (level)
	" Reorder level elements in a buffer
	let level = a:level
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorder')
	call wheel#mandala#common_maps ()
	call wheel#mandala#reorder_write (level)
	let upper = wheel#referen#upper(level)
	if ! empty(upper) && ! empty(upper.glossary)
		let names = upper.glossary
		let elements = wheel#referen#elements(upper)
		let content = join(names, "\n")
		put =content
		1 delete _
		setlocal nomodified
		normal! gg
	else
		echomsg 'Wheel mandala reorder : empty or incomplete' level
	endif
endfun

fun! wheel#mandala#reorder_toruses ()
	" Reorder toruses in a buffer
	call wheel#mandala#reorder ('torus')
endfun

fun! wheel#mandala#reorder_circles ()
	" Reorder circles in a buffer
	call wheel#mandala#reorder ('circle')
endfun

fun! wheel#mandala#reorder_locations ()
	" Reorder locations in a buffer
	call wheel#mandala#reorder ('location')
endfun
