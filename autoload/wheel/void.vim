" vim: set filetype=vim:

" Enter the void of initialization

fun! wheel#void#init ()
	call wheel#disc#read(g:wheel_config['file'])
	if ! exists("g:wheel")
		call wheel#void#reset()
	endif
endfu

fun! wheel#void#exit ()
	call wheel#disc#write('g:wheel', g:wheel_config['file'])
endfu

fun! wheel#void#reset ()
	let g:wheel = {}
endfu
