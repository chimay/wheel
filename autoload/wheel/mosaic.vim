" vim: ft=vim fdm=indent:

" Windows & Tabs

fun! wheel#mosaic#glasses (filename)
	" Return list of window(s) id(s) displaying filename
	return win_findbuf(bufnr(a:filename))
endfun

fun! wheel#mosaic#tour ()
	" Return closest candidate amongst windows displaying current location
	" by exploring each one
	" Return 0 if no window display filename
	let original = win_getid()
	let location = wheel#referen#location()
	let filename = location.file
	let line = location.line
	let glasses = wheel#mosaic#glasses (filename)
	if empty(glasses)
		return 0
	else
		let old = glasses[0]
		call win_gotoid(old)
		let old_delta = abs(line - line('.'))
		for index in range(1, len(glasses) - 1)
			let new = glasses[index]
			call win_gotoid(new)
			let new_delta = abs(line - line('.'))
			if new_delta < old_delta
				let old_delta = new_delta
				let old = new
			endif
		endfor
		call win_gotoid(original)
		return old
	endif
endfun

fun! wheel#mosaic#grid (level)
	" One window of level per window : grid split
	let width = winwidth(0)
	let height = winheight(0)
	" nr2float ?
	let ratio = round(width) / round(height)
endfun

fun! wheel#mosaic#tabs (level)
	" One element of level per tab
	let level = a:level
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let length = len(elements)
	for index in range(length)
		tabnew
		call wheel#vortex#next(level)
	endfor
endfun
