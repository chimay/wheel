" vim: ft=vim fdm=indent:

" Special Buffer menus
" Filter and choose an element

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

fun! wheel#mandala#filter ()
	" Keep lines matching words of first line
	let lines = wheel#line#filter ()
	2,$delete _
	put =lines
	if line('$') > 1
		2
	endif
endfu

fun! wheel#mandala#common_maps ()
	" Define local common maps in menu buffer
	" Normal maps
	nnoremap <buffer> i ggA
	nnoremap <buffer> a ggA
	" Insert maps
	inoremap <buffer> <space> <esc>:call wheel#mandala#filter()<cr>ggA<space>
	inoremap <buffer> <c-w> <c-w><esc>:call wheel#mandala#filter()<cr>ggA
	inoremap <buffer> <c-u> <c-u><esc>:call wheel#mandala#filter()<cr>ggA
	inoremap <buffer> <esc> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <c-c> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
endfu

fun! wheel#mandala#close ()
	" Close the wheel buffer
	if winnr('$') > 1
		quit!
	else
		bdelete!
	endif
endfun

fun! wheel#mandala#toruses ()
	" Choose a torus to switch to in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = g:wheel.glossary
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#jump('torus', 'open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#jump('torus', 'close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#circles ()
	" Choose a circle to switch to in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let torus = wheel#referen#torus()
	let names = torus.glossary
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#jump('circle', 'open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#jump('circle', 'close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#locations ()
	" Choose a location to switch to in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let circle = wheel#referen#circle()
	let names = circle.glossary
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#jump('location', 'open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#jump('location', 'close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#helix ()
	" Choose a location coordinate to switch to in a buffer
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#helix#locations ()
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#helix('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#helix('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#grid ()
	" Choose a circle coordinate to switch to in a buffer
	" Each coordinate = [torus, circle]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#helix#circles ()
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#grid('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#grid('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#pendulum#sorted ()
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#history('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#history('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#reorder_toruses ()
	" Reorder toruses in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorder')
	let names = g:wheel.glossary
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
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
	norm! gg
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#common_maps ()
endfun

fun! wheel#mandala#reorder_locations ()
	" Reorder locations in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-reorder')
	let names = wheel#helix#locations ()
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#common_maps ()
endfun
