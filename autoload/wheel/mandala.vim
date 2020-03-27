" vim: ft=vim fdm=indent:

" Menu in a wheel buffer

fun! wheel#mandala#open ()
	new
	setlocal cursorline
	setlocal nobuflisted noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=delete
endfun

fun! wheel#mandala#close ()
	if winnr('$') > 1
		quit!
	else
		bdelete!
	endif
endfun

fun! wheel#mandala#toruses ()
	" Choose a torus to swith to in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = g:wheel.glossary
	let content = join(names, "\n")
	put =content
	norm gg
	nnoremap <buffer> <tab> :call wheel#line#torus('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#torus('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
endfun

fun! wheel#mandala#circles ()
	" Choose a circle to swith to in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let torus = wheel#referen#torus()
	let names = torus.glossary
	let content = join(names, "\n")
	put =content
	norm gg
	nnoremap <buffer> <tab> :call wheel#line#circle('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#circle('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
endfun

fun! wheel#mandala#locations ()
	" Choose a location to swith to in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let circle = wheel#referen#circle()
	let names = circle.glossary
	let content = join(names, "\n")
	put =content
	norm gg
	nnoremap <buffer> <tab> :call wheel#line#location('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#location('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
endfun

fun! wheel#mandala#helix ()
	" Choose a location coordinate to swith to in a buffer
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#helix#locations ()
	let content = join(names, "\n")
	put =content
	norm gg
	nnoremap <buffer> <tab> :call wheel#line#helix('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#helix('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
endfun

fun! wheel#mandala#grid ()
	" Choose a circle coordinate to swith to in a buffer
	" Each coordinate = [torus, circle]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#helix#circles ()
	let content = join(names, "\n")
	put =content
	norm gg
	nnoremap <buffer> <tab> :call wheel#line#grid('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#grid('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
endfun

fun! wheel#mandala#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#pendulum#locations ()
	let content = join(names, "\n")
	put =content
	norm gg
	nnoremap <buffer> <tab> :call wheel#line#history('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#history('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
endfun
