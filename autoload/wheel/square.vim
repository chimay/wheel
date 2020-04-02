" vim: ft=vim fdm=indent:

" Alternate locations, circles, toruses

fun! wheel#square#tour (filename)
	" Return list of window(s) id(s) displaying filename
	return win_findbuf(bufnr(a:filename))
endfun

fun! wheel#square#window (...)
	" Return best candidate amongst window(s) id(s) displaying filename
	" filename is passed as argument or defaults to current location
	if a:0 > 0
		let filename = a:1
	else
		let filename = wheel#referen#location().file
	endif
	let windows = wheel#square#tour (filename)
	" Cursor line in windows ?
	if ! empty (windows)
		return windows[0]
	else
		return 0
	endif
endfun
