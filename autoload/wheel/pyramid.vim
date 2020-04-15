" vim: ft=vim fdm=indent:

" Mixed layouts of tabs and windows

fun! wheel#pyramid#steps (level, ...)
	" Display one level in tabs and the lower level in split windows
	" level can be torus or circle
	" Use optional argument as split function for wheel#mosaic#split
	if a:0 > 0
		let fun = a:1
	else
		let fun = 'horizontal'
	endif
	let one = a:level
	let two = wheel#referen#lower_level_name (a:level)
	call wheel#mosaic#tabs (one)
	for tab in range(tabpagenr('$'))
		call wheel#mosaic#split(two, fun)
		tabnext
		call wheel#vortex#next (one, 'new')
	endfor
endfun
