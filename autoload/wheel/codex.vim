" vim: ft=vim fdm=indent:

" Yank wheel
" Take advantage of TextYankPost event

fun! wheel#codex#add ()
	" Insert most used registers at the beginning of g:wheel_yank
	let yanks = g:wheel_yank
	let register = getreg('"')
	if strchars(register) <= g:wheel_config.max_yank_size
		let index = index(yanks, register)
		call insert(yanks, register)
	endif
	let max = g:wheel_config.max_yanks
	let g:wheel_yanks = g:wheel_yanks[:max - 1]
endfun
