" vim: ft=vim fdm=indent:

" Yank wheel
" Take advantage of TextYankPost event

fun! wheel#codex#register (register, ...)
	" Add register to yank wheel
	" If mode == begin and register content is already in yank wheel,
	" move it at the beginning of the list
	if a:0 > 0
		let mode = a:1
	else
		let mode = 'default'
	endif
	let yanks = g:wheel_yank
	let content = getreg(a:register)
	if strchars(content) > g:wheel_config.max_yank_size
		return
	endif
	let content = substitute(content, "'", '\\\0', 'g')
	let content = split(content, "\n")
	let index = index(yanks, content)
	if index < 0
		call insert(yanks, content)
	else
		if mode == 'begin'
			call remove(yanks, index)
			call insert(yanks, content)
		endif
	endif
endfun

fun! wheel#codex#add ()
	" Insert most used registers in yank wheel
	call wheel#codex#register ('"', 'begin')
	call wheel#codex#register ('+')
	call wheel#codex#register ('*')
	let max = g:wheel_config.max_yanks
	let g:wheel_yank = g:wheel_yank[:max - 1]
endfun
