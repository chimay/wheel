" vim: ft=vim fdm=indent:

" Tabs & Windows

" Buffers & Windows

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

" Helpers

fun! wheel#mosaic#one_tab ()
	" One tab
	if tabpagenr('$') > 1
		let prompt = 'Remove all tabs except current one ?'
		let confirm = confirm(prompt, "&Yes\n&No", 2)
		if confirm == 1
			tabonly
		endif
	endif
	let g:wheel_shelve.layout.tab = 'none'
endfun

fun! wheel#mosaic#one_window ()
	" One window
	if winnr('$') > 1
		let prompt = 'Remove all windows except current one ?'
		let confirm = confirm(prompt, "&Yes\n&No", 2)
		if confirm == 1
			only
		endif
	endif
	let g:wheel_shelve.layout.window = 'none'
	let g:wheel_shelve.layout.split = 'none'
endfun

" Layouts

fun! wheel#mosaic#zoom (...)
	" One tab, one window
	call wheel#mosaic#one_tab ()
	call wheel#mosaic#one_window ()
endfun

fun! wheel#mosaic#tabs (level)
	" One level element per tab
	let level = a:level
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let length = len(elements)
	call wheel#mosaic#one_tab ()
	call wheel#vortex#jump ()
	for index in range(length - 1)
		tabnew
		call wheel#vortex#next (level)
	endfor
	tabrewind
	call wheel#vortex#next (level)
	let g:wheel_shelve.layout.tab = level
endfun

fun! wheel#mosaic#split (level, ...)
	" One level element per horizontal split
	if a:0 > 0
		let action = a:1
	else
		let action = 'horizontal'
	endif
	let level = a:level
	let upper = wheel#referen#upper (level)
	let elements = wheel#referen#elements (upper)
	let length = len(elements)
	call wheel#mosaic#one_window ()
	call wheel#vortex#jump ()
	for index in range(length - 1)
		call wheel#mosaic#{action} (level)
		call wheel#vortex#next (level)
	endfor
	wincmd t
	call wheel#vortex#next (level)
	let g:wheel_shelve.layout.window = level
	let g:wheel_shelve.layout.split = action
endfun

fun! wheel#mosaic#horizontal (level)
	" Horizontal split
	split
endfun

fun! wheel#mosaic#vertical (level)
	" Vertical split
	vsplit
endfun

fun! wheel#mosaic#grid (level)
	" One window of level per window : grid split
	" TODO
	let width = winwidth(0)
	let height = winheight(0)
	" nr2float ?
	let ratio = round(width) / round(height)
	let g:wheel_shelve.layout.window = level
	let g:wheel_shelve.layout.split = 'grid'
endfun
