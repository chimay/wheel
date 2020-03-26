" vim: ft=vim fdm=indent:

" Menu in a wheel buffer

fun! wheel#mandala#torus_line ()
	let torus_name = getline('.')
	quit!
	call wheel#vortex#switch_torus(torus_name)
endfun

fun! wheel#mandala#toruses ()
	new
	let names = g:wheel.glossary
	let content = join(names, "\n")
	put =content
	setlocal nobuflisted noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=delete
	nnoremap <buffer> <cr> :call wheel#mandala#torus_line()<cr>
endfun
