" vim: ft=vim fdm=indent:

" Windows

fun! wheel#square#glasses (filename)
	" Return list of window(s) id(s) displaying filename
	return win_findbuf(bufnr(a:filename))
endfun

" Not working
fun! wheel#square#window ()
	" Return closest candidate amongst windows displaying current location
	" Return 0 if no window display filename
	let filename = wheel#referen#location().file
	let glasses = wheel#square#glasses (filename)
	" Get cursor line in window id ?
	if ! empty (glasses)
		return glasses[0]
	else
		return []
	endif
endfun

fun! wheel#square#tour ()
	" Return closest candidate amongst windows displaying current location
	" by exploring each one
	" Return 0 if no window display filename
	let original = win_getid()
	let location = wheel#referen#location()
	let filename = location.file
	let line = location.line
	let glasses = wheel#square#glasses (filename)
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
			else
				call win_gotoid(old)
			endif
		endfor
		call win_gotoid(original)
		return old
	endif
endfun
