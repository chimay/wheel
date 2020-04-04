" vim: ft=vim fdm=indent:

" Special Buffer menus
" Filter and choose an element

" Special Buffer

fun! wheel#mandala#open (...)
	" Open a wheel buffer
	let type = 'wheel-jump'
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
	2,$delete _
	put =lines
	if line('$') > 1
		2
	endif
endfu

" Maps

fun! wheel#mandala#common_maps (...)
	" Define local common maps in menu buffer
	nnoremap <buffer> i ggA
	nnoremap <buffer> a ggA
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
endfu

fun! wheel#mandala#filter_maps ()
	" Define local filter maps in menu buffer
	inoremap <buffer> <space> <esc>:call wheel#mandala#filter()<cr>ggA<space>
	inoremap <buffer> <c-w> <c-w><esc>:call wheel#mandala#filter()<cr>ggA
	inoremap <buffer> <c-u> <c-u><esc>:call wheel#mandala#filter()<cr>ggA
	inoremap <buffer> <esc> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <c-c> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
endfun

" Jump

fun! wheel#mandala#choose (level)
	" Choose an element of level to switch to in a buffer
	let level = a:level
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
	let upper = wheel#referen#upper (level)
	if ! empty(upper) && ! empty(upper.glossary)
		let names = upper.glossary
		let content = join(names, "\n")
		put =content
		normal! gg
		let string = "nnoremap <buffer> <tab> :call wheel#line#jump('"
		let string .= level . "', 'open')<cr>"
		exe string
		let string = "nnoremap <buffer> <cr> :call wheel#line#jump('"
		let string .= level . "', 'close')<cr>"
		exe string
	else
		echomsg 'Wheel mandala choose : empty or incomplete' level
	endif
endfun

fun! wheel#mandala#toruses ()
	" Choose a torus to switch to in a buffer
	call wheel#mandala#choose ('torus')
endfun

fun! wheel#mandala#circles ()
	" Choose a circle to switch to in a buffer
	call wheel#mandala#choose ('circle')
endfun

fun! wheel#mandala#locations ()
	" Choose a location to switch to in a buffer
	call wheel#mandala#choose ('location')
endfun

fun! wheel#mandala#helix ()
	" Choose a location coordinate to switch to in a buffer
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#helix#locations ()
	let content = join(names, "\n")
	put =content
	normal! gg
	nnoremap <buffer> <tab> :call wheel#line#helix('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#helix('close')<cr>
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
endfun

fun! wheel#mandala#grid ()
	" Choose a circle coordinate to switch to in a buffer
	" Each coordinate = [torus, circle]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#helix#circles ()
	let content = join(names, "\n")
	put =content
	normal! gg
	nnoremap <buffer> <tab> :call wheel#line#grid('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#grid('close')<cr>
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
	normal! gg
	nnoremap <buffer> <tab> :call wheel#line#history('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#history('close')<cr>
	call wheel#mandala#common_maps ()
	call wheel#mandala#filter_maps ()
endfun

" Reorder

fun! wheel#mandala#reorder_toruses ()
	" Reorder toruses in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorder')
	let names = g:wheel.glossary
	let content = join(names, "\n")
	put =content
	normal! gg
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#reorder_circles ()
	" Reorder circles in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorder')
	let torus = wheel#referen#torus()
	let names = torus.glossary
	let content = join(names, "\n")
	put =content
	normal! gg
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#reorder_locations ()
	" Reorder locations in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorder')
	let circle = wheel#referen#circle()
	let names = circle.glossary
	let content = join(names, "\n")
	put =content
	normal! gg
	call wheel#mandala#common_maps ()
endfun
