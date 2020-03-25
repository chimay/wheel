" vim: ft=vim fdm=indent:

" Enter the void of initialization

fun! wheel#void#reset ()
	let g:wheel = {}
	let g:wheel_history = {}
endfu

fun! wheel#void#init ()
	call wheel#void#reset ()
	call wheel#disc#read_all ()
	call wheel#centre#commands ()
	call wheel#centre#mappings ()
	call wheel#vortex#jump ()
endfu

fun! wheel#void#exit ()
	call wheel#disc#write_all()
endfu
