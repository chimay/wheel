" vim: ft=vim fdm=indent:

" Menu in a wheel buffer

fun! wheel#mandala#open ()
	new
	let g:wheel_mandala = []
	setlocal cursorline
	setlocal nobuflisted noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=delete
endfun

fun! wheel#mandala#matches ()
	" Return lines matching words of first line
	let first = getline(1)
	let wordlist = split(first)
	if empty(g:wheel_mandala)
		let linelist = getline(2, '$')
		let g:wheel_mandala = linelist
	else
		let linelist = g:wheel_mandala
	endif
	let candidates = []
	for line in linelist
		let match = 1
		for word in wordlist
			let pattern = '.*' . word . '.*'
			if line !~ pattern
				let match = 0
				break
			endif
		endfor
		if match
			let candidates = add(candidates, line)
		endif
	endfor
	return candidates
endfu

fun! wheel#mandala#filter ()
	" Keep lines matching words of first line
	let lines = wheel#mandala#matches ()
	2,$delete
	put =lines
	if line('$') > 1
		2
	endif
endfu

fun! wheel#mandala#insert_maps ()
	" Define local insert maps in menu buffer
	nnoremap <buffer> i ggA
	nnoremap <buffer> a ggA
	inoremap <buffer> <space> <esc>:call wheel#mandala#filter()<cr>ggA<space>
	inoremap <buffer> <esc> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <c-c> <esc>:call wheel#mandala#filter()<cr>
	inoremap <buffer> <cr> <esc>:call wheel#mandala#filter()<cr>
endfu

fun! wheel#mandala#close ()
	let g:wheel_mandala = []
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
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#torus('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#torus('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#insert_maps ()
endfun

fun! wheel#mandala#circles ()
	" Choose a circle to swith to in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let torus = wheel#referen#torus()
	let names = torus.glossary
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#circle('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#circle('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#insert_maps ()
endfun

fun! wheel#mandala#locations ()
	" Choose a location to swith to in a buffer
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let circle = wheel#referen#circle()
	let names = circle.glossary
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#location('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#location('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#insert_maps ()
endfun

fun! wheel#mandala#helix ()
	" Choose a location coordinate to swith to in a buffer
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
	call wheel#mandala#insert_maps ()
endfun

fun! wheel#mandala#grid ()
	" Choose a circle coordinate to swith to in a buffer
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
	call wheel#mandala#insert_maps ()
endfun

fun! wheel#mandala#history ()
	" Choose a location coordinate in history
	" Each coordinate = [torus, circle, location]
	call wheel#vortex#update ()
	call wheel#mandala#open ()
	let names = wheel#pendulum#locations ()
	let content = join(names, "\n")
	put =content
	norm! gg
	nnoremap <buffer> <tab> :call wheel#line#history('open')<cr>
	nnoremap <buffer> <cr> :call wheel#line#history('close')<cr>
	nnoremap <buffer> q :call wheel#mandala#close()<cr>
	call wheel#mandala#insert_maps ()
endfun
