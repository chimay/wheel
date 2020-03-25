" vim: ft=vim fdm=indent:

" Enter the void of initialization

fun! wheel#void#init ()
	call wheel#disc#read_all()
	if ! exists('g:wheel')
		call wheel#void#reset()
	endif
	call wheel#centre#commands ()
	call wheel#centre#mappings ()
	call wheel#vortex#jump ()
endfu

fun! wheel#void#exit ()
	call wheel#disc#write_all()
endfu

fun! wheel#void#reset ()
	let g:wheel = {}
endfu
