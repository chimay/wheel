" vim: ft=vim fdm=indent:

" Menu in a wheel buffer

fun! wheel#mandala#open ()
	new
	setlocal nobuflisted noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=delete
endfun

fun! wheel#mandala#close ()
	quit!
endfun

fun! wheel#mandala#torus_line ()
	let torus_name = getline('.')
	call wheel#mandala#close ()
	call wheel#vortex#switch_torus(torus_name)
endfun

fun! wheel#mandala#toruses ()
	call wheel#mandala#open ()
	let names = g:wheel.glossary
	let content = join(names, "\n")
	put =content
	nnoremap <buffer> <cr> :call wheel#mandala#torus_line()<cr>
endfun

fun! wheel#mandala#circles ()
endfun

fun! wheel#mandala#locations ()
endfun

fun! wheel#mandala#helix ()
endfun
