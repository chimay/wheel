" vim: ft=vim fdm=indent:

" Yank wheel buffers

fun! wheel#clipper#yank (mode)
	" Choose a yank wheel element to paste
	let mode = a:mode
	call wheel#vortex#update ()
	call wheel#mandala#open ('wheel-yank-' . mode)
	let settings = {'mode' : mode}
	call wheel#mandala#template('yank', settings)
	let lines = wheel#perspective#yank (mode)
	" Appendbufline does not work with lists of list
	put =lines
	setlocal nomodified
	call cursor(1,1)
endfun
