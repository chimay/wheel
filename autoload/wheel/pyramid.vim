" vim: set ft=vim fdm=indent iskeyword&:

" Mixed layouts of tabs and windows

fun! wheel#pyramid#steps (level, ...)
	" Display one level in tabs and the lower level in split windows
	" level can be torus or circle
	" Use optional argument as split function for wheel#mosaic#split
	if a:0 > 0
		let fun = a:1
	else
		let fun = 'main_left'
	endif
	let one = a:level
	let two = wheel#referen#lower_level_name (a:level)
	call wheel#mosaic#tabs (one)
	let tabnum = tabpagenr('$')
	for tabind in range(tabnum - 1)
		call wheel#mosaic#split(two, fun)
		tabnext
		call wheel#projection#follow ()
	endfor
	call wheel#mosaic#split(two, fun)
	tabrewind
	call wheel#projection#follow ()
endfun
