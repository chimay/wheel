" vim: set filetype=vim:

" Enter the void of initialization

fun! wheel#void#init ()
	if ! exists("g:wheel")
		call wheel#void#reset()
	endif
endfu

fun! wheel#void#reset ()
	let g:wheel = {}
endfu
