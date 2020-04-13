" vim: ft=vim fdm=indent:

" Mixed layouts of tabs and windows

fun! wheel#pyramid#steps (level, ...)
	" Display one level in tabs and the lower level in split windows
	" level can be torus or circle
	if a:0 > 0
		let Split = a:1
	else
		let Split = function('wheel#mosaic#split')
	endif
	let one = a:level
	let two = wheel#referen#lower_level_name (a:level)
	call wheel#mosaic#tabs (one)
	for tab in range(tabpagenr('$'))
		echomsg tabpagenr()
		if type(Split) == v:t_func
			call Split (two)
		elseif type(Split) == v:t_string
			call {Split} (two)
		else
			echomsg 'Wheel pyramid steps : bad split function'
		endif
		tabnext
		call wheel#vortex#next (one)
	endfor
endfun
